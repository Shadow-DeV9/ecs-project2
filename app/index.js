
const http = require('http');
const fs = require('fs');
const path = require('path');

const publicDirectory = path.join(__dirname, 'public');

const server = http.createServer((req, res) => {
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'healthy' }));
        return;
    }

    let filePath;

    if (req.url === '/' || req.url === '/index.html') {
        filePath = path.join(publicDirectory, 'index.html');
    } else if (req.url === '/style.css') {
        filePath = path.join(publicDirectory, 'style.css');
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 - Page not found');
        return;
    }

    const contentType = filePath.endsWith('.css')
        ? 'text/css'
        : 'text/html';

    fs.readFile(filePath, (err, content) => {
        if (err) {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('500 - Internal server error');
            return;
        }

        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content);
    });
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
