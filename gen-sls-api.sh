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

apiGroupId=$apiGroup-$apiVersion-$basePath
functionsFilename=serverless-$apiGroupId.yaml

echo """\
get:
  name: \${self:custom.apiName}-get
  handler: src/functions/api-handlers/\${self:custom.apiGroupId}/\${self:custom.basePath}/get.handler
  events:
    - http:
        path: /
        method: get
        integration: lambda-proxy
        cors: true
""" > $functionsFilename
