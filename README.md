# About The Application
This Java web application is a 'To-Do List', meant to be a simple demo of how you can integrate Websphere eXtreme Scale into your client applications. It introduces the caching functionality of WebSphere eXtreme Scale image on IBM Bluemix Container Services (ICS). In addition, the To-Do List uses Java caching (JCache) API, an industrial standard API that allows Java programs to interact with caching systems such as Webpshere eXtreme Scale (Supported starting from Websphere eXtreme Scale Version 8.6.1.1)

The To-Do List is simple and easy to use, it allows you to add and persist items that you need to complete. You can also mark items as completed and delete them from the list. The items are stored in a simple Websphere eXtreme Scale grid. 

There is a step by step Youtube tutorial available to help users build and deploy this application: https://www.youtube.com/watch?v=-20qio-DqEU&feature=youtu.be

# Requirements 
- Websphere eXtreme Scale (ibm-websphere-extreme-scale) image on IBM Bluemix Container Services will be used for the To-Do List
    - For documentation on setting up ibm-websphere-extreme-scale image for Bluemix, visit:  https://console.ng.bluemix.net/docs/images/docker_image_extreme_scale/ibm-websphere-extreme-scale_starter.html
    
    - JCache is not supported when eXtreme Memory (XM) function is enabled. To Disable XM, use the instructions below:
 			
		a) Connect to the container 
		
		```
		cf ic exec -it container_name bash
		```
					
		b) List the host name 
		```
		hostname
		```

		c) Retrieve the public IP of the same container (if the container does not have a public IP, follow the steps in the getting started section to provide it one via the Bluemix console or command line) 
		
		d) Create a new entry in your local client machine’s hosts file that will map the public IP and hostname of the container together. It will look something like this:
		```
		169.44.8.87	instance-05106102
		
		NOTE: Hosts file locations:
		Unix: /etc/hosts
		Windows: C:\Windows\System32\drivers\etc

		```
		
		e) Follow instructions on this link to disable eXtreme Memory (XM) using the REST API: (https://www.ibm.com/support/knowledgecenter/SSTVLU_8.6.1/com.ibm.websphere.extremescale.doc/rxsUpdateXMSettingTaskCommand.html)

   - Create a grid of type Simple on WebSphere eXtreme Scale 

- Apache Maven software project management and comprehension tool
   - Download link: https://maven.apache.org/download.cgi
   - Installation Instructions: https://maven.apache.org/install.html

- JDK (Version as per system requirements specified by Maven)

- Git 
    - Download Link: https://git-scm.com/downloads

# Getting The Code 
To get the code, you can just clone the repository

```
git clone https://github.com/ibmWebsphereExtremeScale/JCacheSample.git
```  
For more information on cloning a remote repository, visit: https://help.github.com/articles/cloning-a-repository/

# Dependencies
The sample application uses two dependencies: A JSON library and ogclient.jar

- The JSON library is specified as a dependency in the POM file, Maven will take care of the rest, this includes downloading and storing this library in the right location and packaging it into a final artifact

- The ogclient.jar is NOT available in a public Maven repository. If you are using the Liberty buildpack to deploy the app, you can skip these two steps (NOTE: This tutorial uses the Liberty Buildpack). Else:  
    a) Edit the POM.xml file, uncomment the following block of code 
    ```
    <!--
	<dependency>
		<groupId>com.ogclient</groupId>
		<artifactId>ogclient</artifactId>
		<version>1.0</version>
	</dependency>
	-->
    
    //To uncomment, remove '<!--' at the beginning and '-->' at the end of the block of code
    ```
    b) Download ogclient.jar from 
    ```
    https://hub.jazz.net/manage/manager/project/abchow/CachingSamples/overview?utm_source=dw#https://hub.jazz.net/project/abchow/CachingSamples/abchow%2520%257C%2520CachingSamples/_2fYdgJMyEeO3qtc4gZ02Xw/_2fl44JMyEeO3qtc4gZ02Xw/downloads
     
    ```
    and add it to your local repository by running the following maven command
  

    ```
    $ mvn install:install-file -Dfile=<path-to-ogclient.jar> \
        -DgroupId=com.ogclient -DartifactId=ogclient \
        -Dversion=1.0 -Dpackaging=jar

    //Replace <path-to-orgclient.jar> with a valid path to ogclient.jar
    ```  
    Once the dependency is available in your local repository, you can use it without any futher modifications to the POM file. 

# Building The Application 
After cloning the project and adding the ogclient.jar file to your local Maven repository, go to the directory where the pom.xml file is located and run this command to build the WAR file 

```
mvn clean install
```
You should be able to access the WAR file from the 'target' folder

# Bluemix Setup 
To run your application on Bluemix, you must sign up for Bluemix and install Cloud Foundry command line tool. To sign up for Bluemix, head to https://console.ng.bluemix.net and register.

You can download Cloud Foundry command line tool by following the steps in https://github.com/cloudfoundry/cli

After installing Cloud Foundry command line tool, you need to point to Bluemix by running
```
cf login -a https://api.ng.bluemix.net
```
This will prompt you to login with your Bluemix ID and password.

# Providing Credentials
This application uses Bluemix user-provided service instance to provide credentials to connect to WebSphere eXtreme Scale. For more information visit https://console.ng.bluemix.net/docs/services/reqnsi.html#add_service

We will store credentials in a json file. Create a json file that follows this format. Replace with valid credentials, making sure that you specify all catalog end points(CEPs), seperated by a comma: 

```
  {"catalogEndPoint":"<catalog server endpoint:port, eg: 129.11.111.111:4809,129.22.222.222:4809>",
   "gridName":"<grid name>",
   "username":"<username for WXS>",
   "password":"<password for WXS>"}
   
//Save the file as credentials.json
```
To create a user-provided service on Bluemix with the json file you have created, run the following command: 

```
cf cups <service-name> -p <path to/credentials.json file>

//Replace <service-name> with any name of your choosing but service name must have 'XSSimple' as the prefix. For example:XSSimple-credentials***
```

# Running The Application 
 Once you have successfully logged in, let's push the WAR file to your Bluemix account with the Liberty Buildpack (by default)

```
cf push <app name> -p JCacheSample.war
``` 

Next, bind the application to the user-provided service created 

```
cf bind-service <app name> <service name>
``` 

To allow communication between your application and the Websphere eXtreme Scale (WXS) containers on ICS, set the Bluemix HOSTSALIAS environment variables

```
cf set-env <app name> HOSTSALIAS_wxs1 111.11.111.11
cf set-env <app name> HOSTSALIAS_wxs2 222.22.222.22

//Replace wxs1 and wxs2 with the alias names you call when you start up WXS containers 
(the prefix should remain HOSTSALIAS_)
//the IPs are the public assigned IPs for your WXS containers. 
``` 

Restage the application so changes made will take effect 

```
cf restage <app name>
``` 

# Accessing The Application 
Logon to ACE console: https://console.ng.bluemix.net and find your application on the dashboard. Clicking on the link provided will launch your sample application.

# Troubleshooting
If an operation on the WebSphere eXtreme Scale fails, a failure message will be displayed on the application page. These are some suggestions on how you can troubleshoot the problem. Check the application logs - from the Bluemix UI console, click on your application and select 'Logs'. Check for any error messages in the logs.

If there is a connection exception such as: 
```
APP/0[err] java.lang.NullPointerException
APP/0Failed to perform loadData on ConfigurationGrid Application may have failed to connect to the grid
APP/0[err] at com.ibm._jsp._ToDoList._jspService(_ToDoList.java:239)
```
- Go to the Bluemix console, click on your application. Select 'Runtime', then select the 'Environment variables' tab. Under VCAP services, ensure that the correct information is passed in for credentials (catalogEndPoint, gridName, password, username).  Check that the Bluemix HOSTSALIAS environment variables are set correctly. 
- Check that the name of the user provided service contains the prefix XSSimple 
- Ensure that the grid created is of type 'Simple' 

If there is a security exception such as: 
```
APP/0    Failed to connect to grid
APP/0    [err] javax.cache.CacheException: com.ibm.websphere.objectgrid.ConnectException: CWOBJ1325E: There was a Client security configuration error. The catalog server at endpoint 129.41.233.108:4,809 is configured with SSL. However, the Client does not have SSL configured. The Client SSL configuration is null.
```
- This error indicates that the client application was not configured with SSL but WebSphere eXtreme Scale was configured with SSL
        

# License 
See LICENSE.txt for license information
