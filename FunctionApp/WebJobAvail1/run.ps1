# Input bindings are passed in via param block.
param($Timer)

$webAppUrl = "$($env:webJob)"
$userName = "$($env:webJobUser)"
$userPWD = "$($env:webJobSecret)"


# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
    
$webAppUrl = "https://mttwebapp.scm.azurewebsites.net/api/triggeredwebjobs/Sleepy"

    
$userName = "`$MTTWebApp" 
$userPWD = "6FZR1th2ZjuN481z7PcEmZDCEcSrLLnEsAp4layyibBRXyyas5ZaFkLYL6bK" 

$authHeader = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $userPWD)))


    
$headers = @{ Authorization = "$authHeader" }

# use Invoke-WebRequest to send a request to the web app's URL and store the result so we can check the status code
# also, track the start and end times for the request so we can calculate the duration later on
$startTime = Get-Date

$result = Invoke-WebRequest -Uri $webAppUrl -Method Get -Headers $headers -SkipHttpErrorCheck
$endTime = Get-Date

# if the status code is in the range of client errors or server errors then mark the test as failed
if ($result.StatusCode -ge 400 -and $result.StatusCode -ge 599 )
{
    $success = $false
    $message = "Web app responding with HTTP status code $($result.StatusCode)"
}

elseif($result.Content -like "*Success*")
{
   $success = $true
    $message = "Web app responding with HTTP status code $($result.StatusCode)" 
      
}

else
{
  $success = $false
   $message = "Last Run Webjob not returned Success" 
       
}


# create a new app insights client using the instrumentation key stored in the 'APPINSIGHTS_INSTRUMENTATIONKEY' app setting
$appInsightsClient = New-AppInsightsClient -InstrumentationKey $env:APPINSIGHTS_INSTRUMENTATIONKEY

# send the availability test result back to app insights
$appInsightsParams = @{
    AppInsightsClient = $appInsightsClient
    TestName          = $webAppUrl
    DateTime          = $startTime
    Duration          = New-TimeSpan -Start $startTime -End $endTime
    TestRunLocation   = "westeurope"
    Success           = $success ?? $true
    Message           = $message ?? ""
}
Send-AppInsightsAvailability @appInsightsParams