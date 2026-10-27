// A tiny static file server. See README.md.
//
// VULNERABILITY (planted for this fixture): the request path is joined
// directly onto the served directory without resolving ".." segments or
// confirming the resolved path stays inside publicDir. A request like
// GET /../server.js (or any path traversal sequence) reads a file outside
// public/, including this server's own source or, on a real deployment,
// files like /etc/passwd.
const http = require("node:http");
const path = require("node:path");
const fs = require("node:fs");

const publicDir = path.join(__dirname, "public");

const server = http.createServer((req, res) => {
  const requestedPath = decodeURIComponent(req.url.split("?")[0]);
  const filePath = path.join(publicDir, requestedPath); // no traversal check

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end("not found\n");
      return;
    }
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(data);
  });
});

if (require.main === module) {
  const port = process.env.PORT || 8080;
  server.listen(port, () => {
    console.log(`listening on http://localhost:${port}`);
  });
}

module.exports = { server };
