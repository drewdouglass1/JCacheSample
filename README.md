# About The Application
This Java web application is a 'To-Do List',meant to be a simple demo of how you can integrate Websphere eXtreme Scale into your client applications. In addition, it uses Java caching (JCache) API, an industrial standard API that allows Java programs to interact with caching systems such as Webpshere eXtreme Scale (Supported starting from Websphere eXtreme Scale Version 8.6.1.1)

The To-Do List is simple and easy to use, it allows you to add and persist items that you need to get done. You can also mark items as completed and delete them from the list. The items are stored in an Websphere eXtreme Scale grid. 

# Requirements (UNDER CONSTRUCTION)
- Websphere eXtreme Scale Liberty Deployment 8.6.1.1 (Download the trial version from: https://www.ibm.com/developerworks/downloads/ws/wsdg/index.html) 
    - Follow instructions provided to 

- Apache Maven software project management and comprehension tool (Download link: https://maven.apache.org/download.cgi) 

- JDK (Version as per system requirements specified by Maven)

# Getting The Code 
To get the code, you can just clone the repository

```
git clone https://github.com/ibmWebsphereExtremeScale/JCacheSample.git
```  

# Dependencies (UNDER CONSTRUCTION)
The sample application uses two dependencies:A JSON library and ogclient.jar

- The JSON library is specified as a dependency in the POM file, Maven will take care of the rest including downloading and storing this library in the right location as well as packaging it into a final artifact

- The ogclient.jar is NOT available in a public Maven repository. You will have to obtain this jar file from https://hub.jazz.net/manage/manager/project/abchow/CachingSamples/overview?utm_source=dw#https://hub.jazz.net/project/abchow/CachingSamples/abchow%2520%257C%2520CachingSamples/_2fYdgJMyEeO3qtc4gZ02Xw/_2fl44JMyEeO3qtc4gZ02Xw/downloads
    and add it to your local repository by running the following maven command

```
$ mvn install:install-file -Dfile=<path-to-ogclient.jar> \
    -DgroupId=com.ogclient -DartifactId=ogclient \
    -Dversion=1.0 -Dpackaging=jar
    
(Replace <path-to-orgclient.jar> with a valid path to ogclient.jar)
```  
Once the dependency is available in your local repository, you can use it without any futher modifications to the POM file. 

# Building The Application 
After cloning the project and adding the ogclient.jar file to your local Maven repository, go to the directory where the POM file is located and run this command to build the WAR file 

```
mvn clean install
```
You should be able to access the WAR file build from the 'target' folder 

# Bluemix Setup 
For the purpose of this tutorial, the application will be run on Bluemix. To run your application on Bluemix, you must sign up for Bluemix and installed the Cloud Foundry command line tool. To sign up for Bluemix, head to https://console.ng.bluemix.net and register.

You can download the Cloud Foundry command line tool by following the steps in https://github.com/cloudfoundry/cli

After you have installed Cloud Foundry command line tool, you need to point it at Bluemix by running
```
cf login -a https://api.ng.bluemix.net
```
This will prompt you to login with your Bluemix ID and password.

# Providing Credentials
This application uses a Bluemix user-provided service instance to provide credentials to connect to Websphere eXtreme Scale. For more information visit https://console.ng.bluemix.net/docs/services/reqnsi.html#add_service

We will store credentials in a json file. Create a json file that follows this format (replace with valid credentials) : 

```
  {"catalogEndPoint":"<catalog server endpoint:port, eg: 129.11.111.111:4809,129.22.222.222:4809>",
   "gridName":"<grid name>",
   "username":"<username for WXS>",
   "password":"<password for WXS>"}
   
Save the file as DataCache-credentials.json
```

# Running The Application (UNDER CONSTRUCTION) 
 Once you have successfully logged in, let's push the WAR file to your Bluemix account

```
cf push <app name> -p JCacheSample.war -b (IN PROGRESS) 
``` 


# License 
See LICENSE.txt for license information
