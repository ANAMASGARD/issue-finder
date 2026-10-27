# static-file-server

A tiny HTTP server that serves files from a `public/` directory.

## Usage

```bash
node server.js
# then: curl http://localhost:8080/hello.txt
```

## Scope

Serves any file under `public/` by request path. Intended for serving the fixed set of files already placed in `public/`, nothing outside it.
