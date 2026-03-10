# ---------------------------------------------------------------------------
# container/Dockerfile — Vulnerable Container Image
# ---------------------------------------------------------------------------
# INTENTIONAL vulnerabilities for container-scanning demos:
#
#   1. Uses an OLD base image (python:3.9-slim from an older digest) which
#      contains known OS-level CVEs (e.g., in openssl, libc).
#   2. Runs as root (no USER directive).
#   3. Installs vulnerable pip packages.
#   4. Copies a dummy secret into the image layer.
#
# See Dockerfile.fixed for the remediated version.
# ---------------------------------------------------------------------------

# ISSUE 1: Old base image with known CVEs
FROM python:3.9-slim

# ISSUE 2: No non-root user — container runs as root
WORKDIR /app

# Copy application
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/server.py .

# ISSUE 4: Dummy secret baked into image layer (triggers secret scanning)
# This is a FAKE key — not real.
ENV AZURE_STORAGE_KEY="UGxlYXNlRG9Ob3RVc2VUaGlzS2V5SXRJc0Zha2VBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUE=="

EXPOSE 5000

# ISSUE 2 (continued): running as root
CMD ["python", "server.py"]
