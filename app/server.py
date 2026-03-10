"""
Defender for DevOps Demo — Vulnerable Flask API
=================================================
This file contains INTENTIONAL security issues for demonstration purposes.
Each issue is clearly marked with a comment explaining why it exists.

Issues present:
  1. SQL Injection (SAST finding — CWE-89)
  2. Overly permissive CORS (misconfiguration)
  3. Dummy hardcoded secret (secret scanning finding)
  4. Vulnerable dependency (flask 2.2.0 — see requirements.txt)
"""

import os
import sqlite3
import subprocess

from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)

# ── ISSUE 2: Overly permissive CORS ─────────────────────────────────────────
# WHY: Demonstrates a runtime misconfiguration finding.
# Allowing all origins with credentials is insecure.
# FIX: Restrict origins to known domains (see server-fixed.py).
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# ── ISSUE 3: Hardcoded dummy secret ─────────────────────────────────────────
# WHY: Triggers secret-scanning alerts. This is a FAKE key — it grants no
#      access to any real system. Format mimics an Azure Storage key.
# FIX: Use environment variables or Azure Key Vault (see server-fixed.py).
STORAGE_ACCOUNT_KEY = "DefaultEndpointsProtocol=https;AccountName=fakestorageacct;AccountKey=UGxlYXNlRG9Ob3RVc2VUaGlzS2V5SXRJc0Zha2VBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUE==;EndpointSuffix=core.windows.net"  # noqa: E501  DUMMY — not a real key

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
    """Return all users."""
    db = get_db()
    rows = db.execute("SELECT id, name, email FROM users").fetchall()
    return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])


@app.route("/users/search")
def search_users():
    """
    ── ISSUE 1: SQL Injection (CWE-89) ────────────────────────────────────
    WHY:  The `name` query parameter is concatenated directly into a SQL
          query string, enabling SQL injection attacks.
    FIX:  Use parameterised queries (see server-fixed.py).
    """
    name = request.args.get("name", "")
    db = get_db()
    # VULNERABLE: string concatenation in SQL query
    query = "SELECT id, name, email FROM users WHERE name = '" + name + "'"
    rows = db.execute(query).fetchall()
    return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])


@app.route("/ping")
def ping():
    """
    ── ISSUE 4: Command Injection (CWE-78) ───────────────────────────────
    WHY:  User-supplied input is passed to a shell command without
          sanitisation. Demonstrates OS command injection for SAST.
    FIX:  Avoid shell=True; use subprocess with a list (see server-fixed.py).
    """
    host = request.args.get("host", "127.0.0.1")
    # VULNERABLE: unsanitised user input in shell command
    result = subprocess.check_output(f"ping -c 1 {host}", shell=True, text=True)
    return jsonify({"output": result})


if __name__ == "__main__":
    # Debug mode ON is intentional for the demo (another finding in some scanners)
    app.run(host="0.0.0.0", port=5000, debug=True)
