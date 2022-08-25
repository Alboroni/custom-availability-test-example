## The PoC used a customer availability test to monitor WebJobs status and avaialbiltyu in App Insights 

We use a function and the trackavailability() from App insights inside a powershell module  SDK to confirm the the status of the web job and upload those results 

The deployment yml  requires the webJobURI to be populated. This is the URL format - https://your_app_service.scm.azurewebsites.net/api/triggeredwebjobs/your_web_job_name. You need to replace the app service name and web job name you created, The webJobUser is the User name for the WebJob found in properties of the web job where the password can also be found
The password should be added to the created keyvault 


We then use a custom track availability Powershell module to allow to use . 

To run we need to find out the WEbJobURL in kudo , the user account and its password.


