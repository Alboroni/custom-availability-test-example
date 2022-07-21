param baseName string
param location string = resourceGroup().location
param aspId string
param laId string
param webAppHostName string
param webJobURI string


var uniqueName = uniqueString(baseName, 'functionApp', resourceGroup().id)
var stgSecretName = 'storageConnString'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: uniqueName
  location: location 
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource kv 'Microsoft.KeyVault/vaults@2018-02-14' = {
  name: uniqueName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
  
  resource stgKey 'secrets' = {
    name: stgSecretName
    properties: {
      value: 'DefaultEndpointsProtocol=https;AccountName=${stg.name};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', stg.name), '2015-05-01-preview').key1}'
    }


  }

  resource webJobpsswrd 'secrets' = {
    name: webJobPwd
    properties: {
      value: 'nonsnses'
    }
}


resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: baseName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: laId
  }
}

resource fa 'Microsoft.Web/sites@2019-08-01' = {
  name: uniqueName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: aspId
  }
  kind: 'functionapp'

  resource appSettings 'config@2018-11-01' = {
    name: 'appsettings'
    properties: {
      AzureWebJobsStorage: '@Microsoft.KeyVault(SecretUri=${kv::stgKey.properties.secretUri})'
      FUNCTIONS_EXTENSION_VERSION: '~3'
      FUNCTIONS_WORKER_RUNTIME: 'powershell'
      FUNCTIONS_WORKER_RUNTIME_VERSION: '~7'
      APPINSIGHTS_INSTRUMENTATIONKEY: ai.properties.InstrumentationKey
      webAppHostname: webAppHostName
      webJobURI: webJobURI
      WebJobUser: webJobUser
      webJobPwd: '@Microsoft.KeyVault(SecretUri=${kv::stgKey.properties.secretUri})'

      location: location
    }
  }

}

resource kvAccess 'Microsoft.KeyVault/vaults/accessPolicies@2018-02-14' = {
  parent: kv
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: fa.identity.tenantId
        objectId: fa.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

output functionAppName string = fa.name
output functionAppId string = fa.id

