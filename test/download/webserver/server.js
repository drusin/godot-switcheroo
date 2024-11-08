import http from 'http';
import url from 'url';
import fs from 'fs';

http.createServer((request, response) => {
    const requestUrl = url.parse(request.url);
    response.writeHead(200);
    fs.createReadStream(import.meta.dirname + '/public/' + requestUrl.pathname, 'utf-8').pipe(response);
}).listen(9615);