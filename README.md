## A PoC environment using a custom availability test in Application Insights to monitor WebJobs status and availability.

In this PoC deployment We use a function and the trackavailability() from App insights inside a powershell module to confirm the the status of the web job as availability we want to monitor

The deployment yml  requires the webJobURI to be populated. This is the URL format - https://your_app_service.scm.azurewebsites.net/api/triggeredwebjobs/your_web_job_name. You need to replace the app service name and web job name you created, The webJobUser is the User name for the WebJob found in properties of the web job where the password can also be found
The password for the web job should be added as a repository secret (WEBJOBPWD) 




