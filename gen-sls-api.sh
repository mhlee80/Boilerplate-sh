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
""" > $functionsFilename

mkdir -p src/functions/api-handlers/$apiGroup-$apiVersion/$basePath

