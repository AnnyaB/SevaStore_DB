const apiBase = window.location.origin;;
let jwtToken = '';
let currentUser = null;

// Fetch products and display
async function fetchProducts() {
  const res = await fetch(`${apiBase}/products`);
  const products = await res.json();
  const list = document.getElementById('productList');
  list.innerHTML = '';
  products.forEach(p => {
    const item = document.createElement('li');
    item.textContent = `ID ${p.product_id} - ${p.name} - ₹${p.price}`;
    list.appendChild(item);
  });
}
fetchProducts();

// Signup handler
const signupForm = document.getElementById('signupForm');
signupForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const body = {
    username: document.getElementById('signupUsername').value,
    email: document.getElementById('signupEmail').value,
    password: document.getElementById('signupPassword').value
  };
  const res = await fetch(`${apiBase}/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
  const data = await res.json();
  document.getElementById('signupStatus').textContent = res.ok ? '✅ Signup successful!' : `❌ ${data.error}`;
});

// Login handler
const loginForm = document.getElementById('loginForm');
loginForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('loginEmail').value;
  const password = document.getElementById('loginPassword').value;

  const res = await fetch(`${apiBase}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  const data = await res.json();
  if (res.ok) {
    jwtToken = data.token;
    currentUser = data.user;
    document.getElementById('loginStatus').textContent = '✅ Login successful';

    // Show admin panel or order section based on role
    if (currentUser.role === 'admin') {
      document.getElementById('admin').style.display = 'block';
      document.getElementById('orderSection').style.display = 'none';
    } else {
      document.getElementById('orderSection').style.display = 'block';
      document.getElementById('admin').style.display = 'none';
    }
  } else {
    document.getElementById('loginStatus').textContent = `❌ ${data.error}`;
  }
});

// Admin add product
const productForm = document.getElementById('productForm');
productForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  if (!jwtToken) {
    alert("Please login as admin first.");
    return;
  }

  const body = {
    name: document.getElementById('productName').value,
    category: document.getElementById('productCategory').value,
    description: document.getElementById('productDesc').value,
    price: parseFloat(document.getElementById('productPrice').value),
    stock: parseInt(document.getElementById('productStock').value),
    image_url: document.getElementById('productImage').value
  };

  const res = await fetch(`${apiBase}/admin/add_product`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${jwtToken}`
    },
    body: JSON.stringify(body)
  });

  const result = await res.json();
  alert(result.message || result.error);
  fetchProducts();
});

// Customer place order
const orderForm = document.getElementById('orderForm');
orderForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  if (!jwtToken || !currentUser) {
    alert("Please login to place orders.");
    return;
  }

  const product_id = parseInt(document.getElementById('orderProductId').value);
  const quantity = parseInt(document.getElementById('orderQuantity').value);

  const res = await fetch(`${apiBase}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${jwtToken}`
    },
    body: JSON.stringify({
      user_id: currentUser.user_id,
      items: [{ product_id, quantity }]
    })
  });

  const data = await res.json();
  document.getElementById('orderStatus').textContent = res.ok
    ? `✅ Order placed! Order ID: ${data.order_id}`
    : `❌ ${data.error || "Invalid product ID or out of stock"}`;
});

// Reset password handler
const resetPasswordForm = document.getElementById('resetPasswordForm');
resetPasswordForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const email = document.getElementById('resetEmail').value;
  const new_password = document.getElementById('resetNewPassword').value;

  const res = await fetch(`${apiBase}/reset_password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, new_password })
  });

  const data = await res.json();
  const statusEl = document.getElementById('resetStatus');

  if (res.ok) {
    statusEl.textContent = '✅ Password reset successful! Please login with your new password.';
    statusEl.className = 'message success';
    resetPasswordForm.reset();
  } else {
    statusEl.textContent = `❌ ${data.error || 'Failed to reset password'}`;
    statusEl.className = 'message error';
  }
});

productForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  if (!jwtToken) {
    alert("Please login as admin first.");
    return;
  }

  const body = {
    name: document.getElementById('productName').value.trim(),
    category: document.getElementById('productCategory').value.trim(),
    description: document.getElementById('productDesc').value.trim(),
    price: parseFloat(document.getElementById('productPrice').value),
    stock: parseInt(document.getElementById('productStock').value),
    image_url: document.getElementById('productImage').value.trim()
  };

  try {
    const res = await fetch(`${apiBase}/admin/add_product`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${jwtToken}`
      },
      body: JSON.stringify(body)
    });

    const result = await res.json();

    if (res.ok) {
      alert("✅ Product added successfully!");
      productForm.reset();
      fetchProducts();
    } else {
      alert(`❌ Error: ${result.error || 'Failed to add product'}`);
    }
  } catch (error) {
    alert(`❌ Network error: ${error.message}`);
  }
});
