--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: donations; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.donations (
    donation_id integer NOT NULL,
    user_id integer,
    amount numeric(10,2) NOT NULL,
    message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT donations_amount_check CHECK ((amount > (0)::numeric))
);



--
-- Name: donations_donation_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.donations_donation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: donations_donation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.donations_donation_id_seq OWNED BY public.donations.donation_id;


--
-- Name: orderitems; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.orderitems (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2),
    CONSTRAINT orderitems_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT orderitems_unit_price_check CHECK ((unit_price >= (0)::numeric))
);



--
-- Name: orderitems_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.orderitems_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: orderitems_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.orderitems_order_item_id_seq OWNED BY public.orderitems.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id integer,
    total_price numeric(10,2),
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'paid'::character varying, 'shipped'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT orders_total_price_check CHECK ((total_price >= (0)::numeric))
);



--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.payments (
    payment_id integer NOT NULL,
    order_id integer,
    method character varying(30),
    status character varying(20),
    transaction_ref character varying(100),
    paid_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY ((ARRAY['card'::character varying, 'paypal'::character varying, 'bank_transfer'::character varying, 'cash'::character varying])::text[]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['success'::character varying, 'failed'::character varying, 'pending'::character varying])::text[])))
);



--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(50),
    description text,
    price numeric(10,2) NOT NULL,
    stock integer NOT NULL,
    image_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT products_stock_check CHECK ((stock >= 0))
);



--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: riyabasak_15
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash text NOT NULL,
    role character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'customer'::character varying])::text[])))
);



--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: riyabasak_15
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riyabasak_15
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: donations donation_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.donations ALTER COLUMN donation_id SET DEFAULT nextval('public.donations_donation_id_seq'::regclass);


--
-- Name: orderitems order_item_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orderitems ALTER COLUMN order_item_id SET DEFAULT nextval('public.orderitems_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (donation_id);


--
-- Name: orderitems orderitems_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orderitems
    ADD CONSTRAINT orderitems_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: products unique_product_name; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT unique_product_name UNIQUE (name);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: donations donations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: orderitems orderitems_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orderitems
    ADD CONSTRAINT orderitems_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: orderitems orderitems_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orderitems
    ADD CONSTRAINT orderitems_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riyabasak_15
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: TABLE donations; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.donations TO admin_user;
GRANT SELECT,INSERT ON TABLE public.donations TO customer_user;


--
-- Name: SEQUENCE donations_donation_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.donations_donation_id_seq TO admin_user;


--
-- Name: TABLE orderitems; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.orderitems TO admin_user;
GRANT SELECT,INSERT ON TABLE public.orderitems TO customer_user;


--
-- Name: SEQUENCE orderitems_order_item_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.orderitems_order_item_id_seq TO admin_user;


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.orders TO admin_user;
GRANT SELECT,INSERT ON TABLE public.orders TO customer_user;


--
-- Name: SEQUENCE orders_order_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.orders_order_id_seq TO admin_user;


--
-- Name: TABLE payments; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.payments TO admin_user;


--
-- Name: SEQUENCE payments_payment_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.payments_payment_id_seq TO admin_user;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.products TO admin_user;
GRANT SELECT,INSERT ON TABLE public.products TO customer_user;


--
-- Name: SEQUENCE products_product_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.products_product_id_seq TO admin_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON TABLE public.users TO admin_user;
GRANT SELECT,INSERT ON TABLE public.users TO customer_user;


--
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: public; Owner: riyabasak_15
--

GRANT ALL ON SEQUENCE public.users_user_id_seq TO admin_user;


--
-- PostgreSQL database dump complete
--

