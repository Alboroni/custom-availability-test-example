targetScope = 'subscription'
param baseName string
param location string = deployment().location
param webJobURI string 
param  webJobUser string = 'Test'
@secure()
param webpwd-secret string

resource rsg 'Microsoft.Resources/resourceGroups@2020-08-01' = {
  name: baseName
  location: location
  tags: {
    DestroyTime: '19:00'
  }
}

module asp 'asp.bicep' = {
  scope: rsg
  name: 'asp'
  params: {
    location: location
    name: baseName
  }
}

module la 'logAnaly.bicep' = {
  scope: rsg
  name: 'la'
  params: {
    location: location
    name: baseName
  }
}

module webApp 'webapp.bicep' = {
  scope: rsg
  name: 'webApp'
  params: {
    aspId: asp.outputs.aspId
    baseName: baseName
    location: location
   
  }
}



module functionApp 'functionapp.bicep' = {
  scope: rsg
  name: 'functionApp'
  params: {
    baseName: baseName
    location: location
    aspId: asp.outputs.aspId
    laId: la.outputs.laId
    webAppHostName: webApp.outputs.appHostname
    webJobURI: webJobURI
    webJobUser: webJobUser
    webJobPWD: webpwd-secret

  }
}






output resourceGroupName string = rsg.name
output functionAppName string = functionApp.outputs.functionAppName
output webAppName string = webApp.outputs.appName
