targetScope = 'subscription'
param baseName string
param location string = deployment().location

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



module functionApp 'functionapp.bicep' = {
  scope: rsg
  name: 'functionApp'
  params: {
    baseName: baseName
    location: location
    aspId: asp.outputs.aspId
    webAppHostName: webApp.outputs.appHostname
    webjobURI: webJobURI
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




output resourceGroupName string = rsg.name
output functionAppName string = functionApp.outputs.functionAppName
output webAppName string = webApp.outputs.appName
