usage="usage: $0 <apiGroup> <apiVersion> <basePath>";

if [ $1 ] ; then 
  apiGroup=$1;
fi

if [ $2 ] ; then 
  apiVersion=$2;
fi

if [ $3 ] ; then 
  basePath=$3;
fi

if [ -z $apiGroup ] ; then
  echo $usage; exit 1;
fi

if [ -z $apiVersion ] ; then
  echo $usage; exit 1;
fi

if [ -z $basePath ] ; then
  echo $usage; exit 1;
fi

functionsFilename=serverless-$apiGroup-$apiVersion-$basePath.yaml

echo """\
post:
  name: \${self:custom.apiName}-post
  handler: src/functions/api-handlers/\${self:custom.apiGroup}-\${self:custom.apiVersion}/\${self:custom.basePath}/post.handler
  events:
    - http:
        path: /
        method: post
        integration: lambda-proxy
        cors: true

get:
  name: \${self:custom.apiName}-get
  handler: src/functions/api-handlers/\${self:custom.apiGroup}-\${self:custom.apiVersion}/\${self:custom.basePath}/get.handler
  events:
    - http:
        path: /
        method: get
        integration: lambda-proxy
        cors: true

list:
  name: \${self:custom.apiName}-list
  handler: src/functions/api-handlers/\${self:custom.apiGroup}-\${self:custom.apiVersion}/\${self:custom.basePath}/list.handler
  events:
    - http:
        path: /
        method: get
        request:
          parameters:
            querystrings:
              url: true
        integration: lambda-proxy
        cors: true

delete:
  name: \${self:custom.apiName}-delete
  handler: src/functions/api-handlers/\${self:custom.apiGrou}-\${self:custom.apiVersion}/\${self:custom.basePath}/delete.handler
  events:
    - http:
        path: /{id}
        method: delete
        request:
          parameters:
            paths:
              id: true
        integration: lambda-proxy
        cors: true
""" > $functionsFilename

mkdir -p src/functions/api-handlers/$apiGroup-$apiVersion/$basePath

echo """\
'use strict';

module.exports.handler = async event => {
  return {
    statusCode: 201,
    body: JSON.stringify(
      {
        message: \`POST\`,
        input: event,
      },
      null,
      2
    ),
  };
};
""" > src/functions/api-handlers/$apiGroup-$apiVersion/$basePath/post.js


echo """\
'use strict';

module.exports.handler = async event => {
  const id = event.pathParameters.id

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: \`GET: id = \${id}\`,
        input: event,
      },
      null,
      2
    ),
  };
};
""" > src/functions/api-handlers/$apiGroup-$apiVersion/$basePath/get.js

echo """\
'use strict';

module.exports.handler = async event => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: \`LIST\`,
        input: event,
      },
      null,
      2
    ),
  };
};
""" > src/functions/api-handlers/$apiGroup-$apiVersion/$basePath/list.js

echo """\
'use strict';

module.exports.handler = async event => {
  const id = event.pathParameters.id

  return {
    statusCode: 204,
    body: JSON.stringify(
      {
        message: \`DELETE: id = \${id}. But 204 does not require body.\`,
        input: event,
      },
      null,
      2
    ),
  };
};
""" > src/functions/api-handlers/$apiGroup-$apiVersion/$basePath/delete.js

mkdir -p test-scripts/functions

echo """\
'use strict'

const assert = require('assert')
const { describe, it, before, after } = require('mocha')
const chakram = require('chakram')
const expect = chakram.expect

const stage = process.env.STAGE === 'prd' ? 'prd' : 'dev'
const infraConfig = require('../../config/infra-cfg.json')[stage]

const host = process.env.SLS_HOST

describe('$apiGroup-$apiVersion/$basePath', function () {
  this.timeout(0)

  before('setup', async function () {
  })

  after('tear down', async function () {
  })

  it('post $apiGroup-$apiVersion/$basePath/', function () {
    const url = host + '/'
    var response = chakram.get(url)

    expect(response).to.have.status(201)

    // response.then(function (res) {
    //   console.log(JSON.stringify(res.response.body))
    //   return res
    // })

    return chakram.wait()
  })

  it('get $apiGroup-$apiVersion/$basePath/{id}', function () {
    const url = host + '/' + 'id'
    var response = chakram.get(url)

    expect(response).to.have.status(200)

    // response.then(function (res) {
    //   console.log(JSON.stringify(res.response.body))
    //   return res
    // })

    return chakram.wait()
  })

  it('list $apiGroup-$apiVersion/$basePath', function () {
    const url = host + '/'
    var response = chakram.get(url)

    expect(response).to.have.status(200)

    // response.then(function (res) {
    //   console.log(JSON.stringify(res.response.body))
    //   return res
    // })

    return chakram.wait()
  })

  it('delete $apiGroup-$apiVersion/$basePath/{id}', function () {
    const url = host + '/' + 'id'
    var response = chakram.get(url)

    expect(response).to.have.status(204)

    // response.then(function (res) {
    //   console.log(JSON.stringify(res.response.body))
    //   return res
    // })

    return chakram.wait()
  })
})
""" > test-scripts/functions/$apiGroup-$apiVersion-$basePath.js