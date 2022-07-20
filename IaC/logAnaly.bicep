param name string
param location string

resource la 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location:  location
   properties: {  
 
  }
}
output laId string = la.id
