usage="usage: $0 <serviceName> <apiGroup> <apiVersion> <basePath>";

if [ $1 ] ; then 
  serviceName=$1;
fi

if [ $2 ] ; then 
  apiGroup=$2;
fi

if [ $3 ] ; then 
  apiVersion=$3;
fi

if [ $4 ] ; then 
  basePath=$4;
fi

if [ -z $serviceName ] ; then
  echo $usage; exit 1;
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
  handler: src/functions/api-handlers/\${self:custom.apiGroup}-\${self:custom.apiVersion}/\${self:custom.basePath}/delete.handler
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

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=dev
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls offline --stage \$SLS_STAGE
""" > sls-offline-dev-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=prd
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls offline --stage \$SLS_STAGE
""" > sls-offline-prd-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=dev
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls create_domain --stage \$SLS_STAGE
sls deploy --stage \$SLS_STAGE
""" > sls-deploy-dev-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=prd
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls create_domain --stage \$SLS_STAGE
sls deploy --stage \$SLS_STAGE
""" > sls-deploy-prd-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=dev
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls delete_domain
sls remove --stage \$SLS_STAGE
""" > sls-remove-dev-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=prd
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

sls delete_domain
sls remove --stage \$SLS_STAGE
""" > sls-remove-prd-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=dev
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

export SLS_HOST="http://localhost:3000"
mocha test-scripts/functions/$apiGroup-$apiVersion-$basePath.js
""" > test-offline-dev-$apiGroup-$apiVersion-$basePath.sh

echo """\
export SLS_SERVICE_NAME=$serviceName
export SLS_STAGE=prd
export SLS_API_GROUP=$apiGroup
export SLS_API_VERSION=$apiVersion
export SLS_BASE_PATH=$basePath

export SLS_HOST="http://localhost:3000"
mocha test-scripts/functions/$apiGroup-$apiVersion-$basePath.js
""" > test-offline-prd-$apiGroup-$apiVersion-$basePath.sh