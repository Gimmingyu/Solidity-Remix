# Blockchain In Action 4장

> 블록체인 인 액션 책을 읽고 공부한 내용을 기록한 글 입니다. 글에 나와있는 내용과 사진은 모두 블록체인 인 액션에 포함된 내용 혹은 이를 정리한 것 입니다. 문제가 될 시 삭제하겠습니다.

스마트 컨트랙트에 코딩된 로직은 혼자서 작동하지 않는다.  
스마트 컨트랙트 함수와 블록체인 서비스를 호출하는 사용자 애플리케이션이 있어야 한다.  
Dapp은 블록체인 함수를 호출하는 탈중앙화 스마트 컨트랙트의 로직이 포함된 웹 또는 엔터프라이즈 애플리케이션이다.

블록체인 아키텍쳐의 흐름을 상기해보면, 다음과 같다.

```
- 사용자가 UI 함수를 호출한다.  
- UI 함수는 웹 애플리케이션 소프트웨어와 블록체인 API를 사용해 스마트 컨트랙트 함수를 연결한다.  
- 스마트 컨트랙트 함수는 호출을 나타내는 Txs를 체인에 기록한다.
```

행위자로부터 일관된 블록체인 기록은 블록체인 네트워크에 기록된 블록체인에 연결된 양쪽 노드 모두에서 일어난다는 것을 알 수 있다.  
4장에 Dapp 개발을 위해 사용하는 아티팩트와 기법들은 다음과 같다.

```
- 모든 Dapp 프로젝트에 필요한 웹 애플리케이션용 "project-app" 모듈과 스마트 컨트랙트용 "project-contract" 모듈
- 웹 서버와 패키지 매니저 (Node.js)
- Web3 provider로 불리는 블록체인 provider
- Dapp을 배포하고 테스트할 통합적인 환경을 제공하는 개발 도구 IDE(트러플 스위트)
- 메타마스크 브라우저 플러그인을 이용한 어카운트 관리
```

Remix IDE는 스마트 컨트랙트 개발을 위한 환경이고, 트러플 스위트는 Dapp 개발을 프로덕션 수준으로 이끈다.

## 개발과정

```
- 문제 설정 분석: 설계 원칙과 다이어그램을 이용해서 솔루션 설계하고 표현.
- 스마트 컨트랙트 개발: Remix IDE를 통해 스마트 컨트랙트를 개발하고 테스트.
- Dapp개발: 트러플 IDE를 통해 Dapp을 코딩하고 테스트 블록체인에 배포, 메인 네트워크에 마이그레이션.
```

## Truffle 설치

mac에서는 sudo npm install truffle -g 를 사용해서 설치할 수 있다.  
현재 version 정보

```
Truffle v5.5.11 (core: 5.5.11)
Ganache v^7.0.4
Solidity v0.5.16 (solc-js)
Node v18.0.0
Web3.js v1.5.3
```

## Dapp 스택 구축

```
1. 로컬 블록체인 레이어 설치
2. 스마트 컨트랙트 개발 및 배포
3. 웹 애플리케이션 UI 개발
4. 웹 서버 환경 설정과 스마트 컨트랙트 레이어를 연결하는 결합 코드 개발
```

## 가나쉬 테스트 체인 설치

[https://trufflesuite.com/ganache/](https://trufflesuite.com/ganache/) 에서 가나쉬 설치가 가능하다.

**설치를 한 후, quick start를 누르면 나오는 MNEMONIC 키를 복사해두자.**

설치를 하고 3장에서의 투표케이스의 테스트를 위해 컨트랙트를 담을 표준화 디렉토리 구조를 만들고 초기화한다.

```
디렉토리 구조
Ballot-Dapp
    Ballot-app
    Ballot-contract
```

##### Ballot-contract 디렉토리에서 truffle init 명령어를 사용해서 트러플이 제공하는 템플릿을 사용할 수 있다.

##### 실행 후의 Ballot-contract 내의 구조는 다음과 같다.

```
Ballot-contract
    contracts/
    migrations/ 
    test/
    truffle-config.js
```

### contracts/

-   스마트 컨트랙트를 위한 솔리디티 소스파일 Migrations.sol 파일이 다른 스마트 컨트랙트의 배포를 돕는다.

### migrations/

-   트러플은 스마트 컨트랙트의 배포를 위한 Migration 시스템을 사용한다. 디렉토리 내의 migration.js 파일은 개발중인 스마트 컨트랙트의 변화를 관리한다.

### test/

-   스마트 컨트랙트를 위한 자바스크립트와 솔리디티 테스트

### truffle-config.js

-   트러플 설정 파일, 블록체인 네트워크 ID, IP, RPC 포트 번호와 같은 개인 설정 정보가 들어 있다.

**contract에 Ballot.sol 파일을 만든 후, ./Ballot-contract 에서 truffle compile 을 입력하게 되면**

**내가 설정해둔 truffle-config의 컴파일 버전을 이용해 .sol 파일을 컴파일해준다.**

**컴파일에 성공하면 Ballot-contract/build/contract/Ballot.json 파일이 생긴다.**

**해당 파일은 스마트 컨트랙트 코드의 애플리케이션 바이너리 인터페이스라고 부른다.**

**웹 애플리케이션에서 스마트 컨트랙트로 보내는 호출과 모듈간의 데이터 송신에 사용될 인터페이스이다.**

## 블록체인 네트워크 설정

**_truffle-config.js 파일을 수정해서, 웹 애플리케이션에서 스마트 컨트랙트 코드로 들어갈 RPC 포트를 설정한다._**

**_서버를 로컬 머신으로 설정하고 가나쉬 테스트 블록체인을 위한 RPC포트 및 네트워크 ID를 입력해서 설정을 해준다._**

**_다른 블록체인 네트워크 상에 컨트랙트를 배포하려면, 네트워크 ID와 포트 번호를 그것에 맞게 설정해주어야 한다._**

```
여기서 RPC란 Remote Procedure Call 의 약자로서 동일 컴퓨터 상의 다른 프로세스나

다른 컴퓨터 상의 프로세스의 함수를 호출하는데 사용하는 프로토콜이다.

이 RPC 포트 덕에 다른 컴퓨터와의 통신을 마치 로컬 함수를 호출하듯이 할 수 있는데,

RPC 호출을 수행하기 위해서는 네트워크의 주소와 종점을 알아야한다.

현재 많은 DApp 서비스는 서비스 운영의 유연성을 위해 사용자들에게 각자 직접 노드를 돌리지 않게 하고

RPC 서비스를 통해 메인넷과 연결하게 한다.

즉, 사용자들이 메인넷과 연결된 Metamask같은 지갑 서비스를 사용하고 이를 DApp 웹사이트에 연결해 트랜잭션을 보내는 방법이 일반적이다.
```

## 스마트 컨트랙트 배포하기

**_스마트 컨트랙트를 배포하기 전에, migrations/ 폴더에 2\_deploy\_contract.js 라는 이름으로 마이그레이션 스크립트를 추가했다._**

```
var Ballot = artifacts.require("Ballot");

module.exports = function(deployer) {
  deployer.deploy(Ballot,4);
};
```

이 파일은 배포해야 할 컨트랙트를 명시하고, Parameter 값이 있을 경우 이를 constructor에게 전달한다.

이 경우에는 ballot의 constructor parameter를 4로 초기화했는데, 이는 투표할 제안 수가 4개라는 것을 의미한다.

이 스크립트로 다수의 스마트 컨트랙트를 배포할 수도 있다. 마이그레이션 폴더를 살펴보면 기본적으로 1\_initial\_migration.js가 있는데,

이것은 truffle migrate가 필요로 하는 최초의 migration인 Migrations.sol 이라는 컨트랙트를 배포하기 위한 스크립트이다.

접두사 1, 2는 마이그레이션 단계를 나타내는 숫자이므로 파일 이름에 유의해야한다.

이제 명령어 "truffle migrate --reset" 을 이용해 가나쉬 테스트 체인에 컨트랙트를 배포하면 된다.

reset option은 migration.sol 을 포함한 모든 컨트랙트를 재배포한다.

실제 프로덕션 환경에서는 이미 배포한 컨트랙트는 변조 불가능하며, 리셋으로도 덮어쓸 수 없다.

## 웹 애플리케이션 개발

이제 스마트 컨트랙트와 상호작용하기 위해 웹 애플리케이션을 개발해야한다.

ballot-app 디렉토리에서 Node.js를 초기화하고 (npm init) Package.json, index.js 파일을 만든다.

_package.json_

```
{
  "name": "ballot-app",
  "version": "1.0.0",
  "lockfileVersion": 1,
  "requires": true,
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies" : {
      "express" : "^4.18.0"
  }
}
```

_index.js_

```
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
```

그 외에 html, css 등 필요한 파일이 있는데, 해당 파일들은 책에서 제공한 파일을 ballot-app 폴더에 복사해 넣은 후 테스팅했다.

npm start 를 이용해서 로컬 호스트에서 서버를 시작하고, 마지막으로 메타마스크를 다운로드한다.

메타마스크는 디지털 지갑이자, 블록체인 애플리케이션으로 나가는 게이트웨이이자, 웹 앱과 블록체인 서버간의 프록시와 같은 역할을 한다.

또한 메타마스크는 블록체인 위에 만든 어카운트와 이더를 안전하게 관리하고, 사용자 어카운트가 만든 트랜잭션에 디지털 서명을 할 수 있게 한다.

메타마스크는 web3 API를 사용해서 스마트 컨트랙트에 접근한다는 점도 알아둬야 한다.