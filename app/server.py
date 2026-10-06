#!/usr/bin/env python3
"""Minimal HTTP app. Message and version come from a ConfigMap; API key from a Secret."""

import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("PORT", "8080"))
APP_MESSAGE = os.environ.get("APP_MESSAGE", "Hello world")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
# Required from Secret so the Deployment still mounts credentials; not shown on the page.
_ = os.environ.get("APP_API_KEY", "")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"{APP_MESSAGE}\nversion {APP_VERSION}\n".encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()