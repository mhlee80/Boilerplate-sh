echo """\
# Welcome to Serverless!
#
# This file is the main config file for your service.
# It's very minimal at this point and uses default values.
# You can always add more config options for more control.
# We've included some commented out config examples here.
# Just uncomment any of them to get that config option.
#
# For full config options, check the docs:
#    docs.serverless.com
#
# Happy Coding!

service:
  name: \${self:custom.serviceName}
# app and org for use with dashboard.serverless.com
#app: your-app-name
#org: your-org-name

# You can pin your service to only deploy with a specific Serverless version
# Check out our docs for more details
# frameworkVersion: "=X.X.X"

custom:
  serviceName: \${env:SLS_SERVICE_NAME}
  stage: \${opt:stage, 'dev'} # dev or prd
  apiGroup: \${env:SLS_API_GROUP}
  apiVersion: \${env:SLS_API_VERSION}
  apiGroupId: \${env:SLS_API_GROUP_ID}
  basePath: \${env:SLS_BASE_PATH}
  domainName: \${self:custom.apiGroupId}.\${self:custom.stage}.\${self:custom.serviceName}.wiwa.io
  apiName: \${self:custom.serviceName}-\${self:custom.stage}-\${self:custom.apiGroupId}-\${self:custom.basePath}
  endpointType: REGIONAL
  
  memorySize: 128
  timeout: 30

  _cfg: \${file(config/infra-cfg.json)}
  cfg: \${self:custom._cfg.\${self:custom.stage}}

  functionsFilename: serverless-\${self:custom.apiGroupId}-\${self:custom.basePath}.yaml

  aws:
    vpc:
      region: \${self:custom.cfg.aws.vpc.region}
      securityGroupId: \${self:custom.cfg.aws.vpc.securityGroupId}
      privateSubnetId1: \${self:custom.cfg.aws.vpc.privateSubnetId1}
      privateSubnetId2: \${self:custom.cfg.aws.vpc.privateSubnetId2}
    iam:
      functionRoleARN: \${self:custom.cfg.aws.iam.functionRoleARN}

  customDomain:
    domainName: \${self:custom.domainName}
    basePath: \${self:custom.basePath}
    stage: \${self:custom.stage}
    createRoute53Record: true
    endpointType: \${self:custom.endpointType}

provider:
  name: aws
  runtime: nodejs12.x
  endpointType: \${self:custom.endpointType}
  stage: \${self:custom.stage}
  region: \${self:custom.aws.vpc.region}
  apiName: \${self:custom.apiName}
  apiVersion: \${self:custom.apiVersion}
  memorySize: \${self:custom.memorySize}
  timeout: \${self:custom.timeout}
  
  vpc:
    securityGroupIds:
      - \${self:custom.aws.vpc.securityGroupId}
    subnetIds:
      - \${self:custom.aws.vpc.privateSubnetId1}
      - \${self:custom.aws.vpc.privateSubnetId2}
  
  role: \${self:custom.aws.iam.functionRoleARN}

functions:
  \${file(\${self:custom.functionsFilename})} 

plugins:
  - serverless-offline
  - serverless-domain-manager

package:
  exclude:
    - README/**
""" > serverless.yml
