param location string = resourceGroup().location
param appName string
param hostingPlanSkuName string
param repoUrl string
param resourceGroupName string

// Resource group for App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: hostingPlanSkuName
    tier: 'Free'
  }
}

// Application Insights using the Workspace-based model
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${appName}-workspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30 // Number of days logs will be retained
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield' // This defines it to use the new workspace-based integration
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {   
          name: 'DUMMY_REPO_URL'
          value: repoUrl 
        }
        {
          name: 'DUMMY_RESOURCE_GROUP_NAME'
          value: resourceGroupName 
        }
      ]
    }
  }
}

// Output the URLs and App Insights info
output webAppUrl string = appService.properties.defaultHostName
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString