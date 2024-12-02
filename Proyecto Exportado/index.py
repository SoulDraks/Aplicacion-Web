from http.server import HTTPServer, SimpleHTTPRequestHandler

class MyHTTPRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

if __name__ == "__main__":
    PORT = 8000
    httpd = HTTPServer(("localhost", PORT), MyHTTPRequestHandler)
    print(f"Servidor corriendo en http://localhost:{PORT}")
    httpd.serve_forever()
