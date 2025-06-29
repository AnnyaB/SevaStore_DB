import jwt
import datetime
from functools import wraps
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import hashlib

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_super_secret_key_here'
CORS(app)

from functools import wraps

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if "Authorization" in request.headers:
            token = request.headers["Authorization"].split(" ")[1]  # Bearer <token>

        if not token:
            return jsonify({"error": "Token is missing!"}), 401

        try:
            data = jwt.decode(token, app.config["SECRET_KEY"], algorithms=["HS256"])
            request.user = data  # Attach user data to the request
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expired!"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token!"}), 401

        return f(*args, **kwargs)
    return decorated


# PostgreSQL connection config
conn = psycopg2.connect(
    dbname="sevastore_db",
    user="riyabasak_15",
    password="",  # Add your password here if any
    host="localhost",
    port=5432
)

# Render frontend HTML file
@app.route("/")
def home():
    return render_template("index.html")


# Get all products
@app.route("/products", methods=["GET"])
def get_products():
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM Products;")
        products = cur.fetchall()
    return jsonify(products)


# Place a new order
@app.route("/orders", methods=["POST"])
def add_order():
    data = request.json
    user_id = data.get("user_id")
    items = data.get("items")

    if not user_id or not items:
        return jsonify({"error": "user_id and items are required"}), 400

    with conn.cursor() as cur:
        total_price = 0
        # Validate all items before processing
        for item in items:
            cur.execute("SELECT price FROM Products WHERE product_id = %s;", (item["product_id"],))
            row = cur.fetchone()
            if row is None:
                return jsonify({"error": f"Incorrect product id: {item['product_id']}"}), 400
            price = row[0]
            total_price += price * item["quantity"]

        # Insert order
        cur.execute(
            "INSERT INTO Orders (user_id, total_price, status) VALUES (%s, %s, 'pending') RETURNING order_id;",
            (user_id, total_price)
        )
        order_id = cur.fetchone()[0]

        # Insert order items
        for item in items:
            cur.execute(
                """INSERT INTO OrderItems (order_id, product_id, quantity, unit_price)
                   VALUES (%s, %s, %s, (SELECT price FROM Products WHERE product_id = %s));""",
                (order_id, item["product_id"], item["quantity"], item["product_id"])
            )

        conn.commit()

    return jsonify({"order_id": order_id, "total_price": total_price})


# Hash passwords for local use
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


# User registration
@app.route("/signup", methods=["POST"])
def signup():
    data = request.json
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")
    role = data.get("role", "customer")

    if not all([username, email, password]):
        return jsonify({"error": "Missing fields"}), 400

    with conn.cursor() as cur:
        try:
            cur.execute(
                "INSERT INTO Users (username, email, password_hash, role) VALUES (%s, %s, %s, %s);",
                (username, email, hash_password(password), role)
            )
            conn.commit()
            return jsonify({"message": "User registered successfully!"})
        except psycopg2.errors.UniqueViolation:
            conn.rollback()
            return jsonify({"error": "User already exists"}), 409


# Login endpoint
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            "SELECT * FROM Users WHERE email = %s AND password_hash = %s;",
            (email, hash_password(password))
        )
        user = cur.fetchone()

        if user:
            # Create JWT token
            payload = {
                "user_id": user["user_id"],
                "email": user["email"],
                "role": user["role"],
                "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=2)
            }
            token = jwt.encode(payload, app.config["SECRET_KEY"], algorithm="HS256")

            return jsonify({
                "message": "Login successful!",
                "token": token,
                "user": user
            })
        else:
            return jsonify({"error": "Invalid credentials"}), 401




# Donation endpoint
@app.route("/donate", methods=["POST"])
def donate():
    data = request.json
    user_id = data.get("user_id")
    amount = data.get("amount")
    message = data.get("message")

    if not user_id or not amount:
        return jsonify({"error": "user_id and amount are required"}), 400

    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO Donations (user_id, amount, message) VALUES (%s, %s, %s);",
            (user_id, amount, message)
        )
        conn.commit()
    return jsonify({"message": "Donation received!"})


# **New admin add product endpoint**
@app.route("/admin/add_product", methods=["POST"])
@token_required
def add_product():
    if request.user["role"] != "admin":
        return jsonify({"error": "Admin access only"}), 403

    data = request.json
    name = data.get("name")
    category = data.get("category")
    description = data.get("description")
    price = data.get("price")
    stock = data.get("stock")
    image_url = data.get("image_url", "")

    if not all([name, category, price is not None, stock is not None]):
        return jsonify({"error": "Missing required fields"}), 400

    with conn.cursor() as cur:
        cur.execute("SELECT product_id FROM Products WHERE name = %s;", (name,))
        if cur.fetchone():
            return jsonify({"error": "Product with this name already exists."}), 409

        cur.execute(
            "INSERT INTO Products (name, category, description, price, stock, image_url) VALUES (%s, %s, %s, %s, %s, %s) RETURNING product_id;",
            (name, category, description, price, stock, image_url)
        )
        product_id = cur.fetchone()[0]
        conn.commit()

    return jsonify({"message": f"Product added with id {product_id}"})




if __name__ == "__main__":
    app.run(debug=True)
