var express = require('express');
var app = express();
app.use(express.static('src')); // 퍼블릭 웹 아티팩트를 위한 베이스 디렉토리 
app.use(express.static('../ballot-contract/build/contracts')); // 스마트 컨트랙트의 인터페이스 JSON파일 위치 
app.get('/', function (req, res) {
  res.render('index.html');
  // index.html == 웹 앱의 랜딩 페이지 
});
// Node.js 서버의 포트 3000
app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});