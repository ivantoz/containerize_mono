const http = require("http");

const host = 'localhost';
const port = 8000;

const requestListener = function (req, res) {
  const fwd_for = req.headers['x-forwarded-for'] || 'None'
  const real_ip = req.headers['x-real-ip'] || 'None'
  const fwd_proto = req.headers['x-forwarded-proto'] || 'None'

  const body = `You cannot be more than what you are.`.concat(
    `\nX-Forwarded-For: ${fwd_for}\nX-Real-IP: ${real_ip}\nX-Forwarded-Proto: ${fwd_proto}`
  )

  res.writeHead(200, {'Content-Type': 'text/html'}).end(body)
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});