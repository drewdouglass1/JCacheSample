# About The Application
This Java web application is a 'To-Do List',meant to be a simple demo of how you can integrate Websphere eXtreme Scale into your client applications. In addition, it uses Java caching (JCache) API, an industrial standard API that allows Java programs to interact with caching systems such as Webpshere eXtreme Scale (Supported starting from Websphere eXtreme Scale Version 8.6.1.1)

The To-Do List is simple and easy to use, it allows you to add and persist items that you need to complete. You can also mark items as completed and delete them from the list. The items are stored in an Websphere eXtreme Scale grid. 

# Requirements 
- Websphere eXtreme Scale Liberty Deployment (XSLD) 8.6.1.1 (Download the trial version from: https://www.ibm.com/developerworks/downloads/ws/wsdg/index.html) 
    - Follow instructions provided to setup your XSLD instance 
    - JCache is not supported when eXtreme Memory (XM) function is enabled. To Disable XM, use the following instructions:                    (https://www.ibm.com/support/knowledgecenter/SSTVLU_8.6.1/com.ibm.websphere.extremescale.doc/rxsUpdateXMSettingTaskCommand.html)
    - Create a grid of type Simple on XSLD 

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

- The ogclient.jar is NOT available in a public Maven repository. If you are using the Java buildpack to deploy the app, you have to follow these two steps: 
    1. Edit the POM.xml file, uncomment the following block of code 
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
    2. Download ogclient.jar from https://hub.jazz.net/manage/manager/project/abchow/CachingSamples/overview?       utm_source=dw#https://hub.jazz.net/project/abchow/CachingSamples/abchow%2520%257C%2520CachingSamples/_2fYdgJMyEeO3qtc4gZ02Xw/_2fl44JMyE eO3qtc4gZ02Xw/downloads
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
For the purpose of this tutorial, the application will be deployed on Bluemix. To run your application on Bluemix, you must sign up for Bluemix and install the Cloud Foundry command line tool. To sign up for Bluemix, head to https://console.ng.bluemix.net and register.

You can download the Cloud Foundry command line tool by following the steps in https://github.com/cloudfoundry/cli

After you have installed Cloud Foundry command line tool, you need to point to Bluemix by running
```
cf login -a https://api.ng.bluemix.net
```
This will prompt you to login with your Bluemix ID and password.

# Providing Credentials
This application uses a Bluemix user-provided service instance to provide credentials to connect to Websphere eXtreme Scale. For more information visit https://console.ng.bluemix.net/docs/services/reqnsi.html#add_service

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

# Running The Application (UNDER CONSTRUCTION) 
 Once you have successfully logged in, let's push the WAR file to your Bluemix account with a Java Buildpack

```
cf push <app name> -p JCacheSample.war -b https://github.com/cloudfoundry/java-buildpack
``` 

Next, bind the application to the user-provided service created 

```
cf bind-service <app name> <service name>
``` 

Restage the application so changes made will take effect 

```
cf restage <app name>
``` 
# Accessing The Application 
To view the application, log onto the Bluemix console ( https://console.ng.bluemix.net ) and click on your deployed application from the dashboard. On the application page Runtime, click the "View App" button, this will launch the app.

# Troubleshooting (INPROGRESS) 
If an operation on the WebSphere eXtreme Scale fails, a failure message will be displayed on the application page. These are some suggestions on how you can troubleshoot the problem. Check the application logs - from the Bluemix UI console, click on your application and select 'Logs'. Check for any error messages in the logs. 

If there is a connection exception such as: 
```
APP/0[err] java.lang.NullPointerException
APP/0Failed to perform loadData on ConfigurationGrid Application may have failed to connect to the grid
APP/0[err] at com.ibm._jsp._ToDoList._jspService(_ToDoList.java:239)
```
- Go to the Bluemix console, click on your application. Select 'Runtime', then select the 'Environment variables' tab. Under VCAp services, ensure that the correct information is passed in for credentials (catalogEndPoint, gridName, password, username) 
- Check that the name of the user provided service contains the prefix XSSimple 
- Check that the grid created is of type 'Simple' 

If there is a security exception such as: 
```
APP/0    Failed to connect to grid
APP/0    [err] javax.cache.CacheException: com.ibm.websphere.objectgrid.ConnectException: CWOBJ1325E: There was a Client security configuration error. The catalog server at endpoint 129.41.233.108:4,809 is configured with SSL. However, the Client does not have SSL configured. The Client SSL configuration is null.
```
- This error indicates that the client application was not configured with SSL but WebSphere eXtreme Scale was configured with SSl
        

# License 
See LICENSE.txt for license information
