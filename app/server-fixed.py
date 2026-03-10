"""
Defender for DevOps Demo — FIXED Flask API
============================================
This is the remediated version of server.py. Every issue is resolved:

  1. SQL Injection   → parameterised queries
  2. CORS            → restricted to specific origins
  3. Hardcoded secret → read from environment variable
  4. Command Injection → subprocess with list args, no shell
  5. Debug mode      → disabled
"""

import os
import sqlite3
import subprocess

from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)

# FIX 2: Restrict CORS to known origins only
CORS(app, resources={r"/*": {"origins": ["https://portal.azure.com"]}})

# FIX 3: Read connection string from environment variable
STORAGE_CONNECTION_STRING = os.environ.get("STORAGE_CONNECTION_STRING", "")

# Database setup (in-memory for demo)
def get_db():
    db = sqlite3.connect(":memory:")
    db.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)")
    db.execute("INSERT OR IGNORE INTO users VALUES (1, 'Alice', 'alice@example.com')")
    db.execute("INSERT OR IGNORE INTO users VALUES (2, 'Bob', 'bob@example.com')")
    db.commit()
    return db


@app.route("/healthz")
def health():
    return jsonify({"status": "ok"})


@app.route("/users")
def get_users():
    db = get_db()
    rows = db.execute("SELECT id, name, email FROM users").fetchall()
    return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])


@app.route("/users/search")
def search_users():
    """
    FIX 1: Use parameterised queries to prevent SQL injection.
    """
    name = request.args.get("name", "")
    db = get_db()
    rows = db.execute(
        "SELECT id, name, email FROM users WHERE name = ?", (name,)
    ).fetchall()
    return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])


@app.route("/ping")
def ping():
    """
    FIX 4: Use subprocess with a list of arguments (no shell=True).
           Also validate input is a simple hostname/IP.
    """
    host = request.args.get("host", "127.0.0.1")
    # Basic validation: only allow alphanumeric, dots, and hyphens
    if not all(c.isalnum() or c in (".", "-") for c in host):
        return jsonify({"error": "Invalid host"}), 400
    result = subprocess.check_output(
        ["ping", "-c", "1", host], text=True, timeout=5
    )
    return jsonify({"output": result})


if __name__ == "__main__":
    # FIX 5: Debug mode disabled in production
    app.run(host="0.0.0.0", port=5000, debug=False)
