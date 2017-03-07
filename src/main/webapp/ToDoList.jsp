<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
<%@ page import="java.util.*" %>  
<%@ page import="java.net.URI" %>  
<%@ page import="com.ibm.websphere.objectgrid.*" %>
<%@ page import="com.ibm.websphere.objectgrid.security.config.*" %>
<%@ page import="com.ibm.websphere.objectgrid.security.plugins.builtins.*" %>

<%@ page import="org.json.*" %>

<%@ page import="javax.cache.Cache" %>
<%@ page import="javax.cache.CacheManager" %>
<%@ page import="javax.cache.Caching" %>
<%@ page import="javax.cache.configuration.MutableConfiguration" %>

<%@ page import="com.ibm.websphere.jcache.CachingProviderImpl" %>
<%@ page import="com.ibm.websphere.objectgrid.security.config.ClientSecurityConfiguration" %>
<%@ page import="com.ibm.websphere.objectgrid.security.plugins.CredentialGenerator" %>
<%@ page import="javax.cache.spi.CachingProvider" %>
<%@ page import="com.ibm.websphere.objectgrid.security.plugins.builtins.UserPasswordCredentialGenerator" %>

<%!

//Variable to store credentials
String gridName=null;
String hostName=null;
String username=null;
String password=null;
String operation="operation";

CachingProvider cachingProvider;
CacheManager cacheManager; 
Cache<String,String> cache;

public void jspInit() {

	//Obtain credentials from VCAP_SERVICES environment variable 
	Map<String, String> env = System.getenv();
	String vcap=env.get("VCAP_SERVICES");
	boolean foundService=false;
	
	if(vcap==null) {
		System.out.println("No VCAP_SERVICES found");
	} 
	
    else {
    	try{
    		JSONObject obj = new JSONObject(vcap);
    		String[] names=JSONObject.getNames(obj);
    		if(names!=null) {
    			for(String name:names) {
    				//When using user-provided services, the JSON file is titled "user-provided",the json object can be obtained by querying the name "user"
    				if (name.startsWith("user")) {
    					JSONArray val = obj.getJSONArray(name);
    					JSONObject serviceAttr = val.getJSONObject(0);
    					JSONObject credentials = serviceAttr.getJSONObject("credentials");
    					
    					//obtain credentials specified by user 
    					username = credentials.getString("username");
    					password = credentials.getString("password"); 
    					hostName=credentials.getString("catalogEndPoint");
    					gridName= credentials.getString("gridName");
    					foundService = true;
    				}
    			}
    		}
    	}catch (Exception e) {
    		System.out.println(e);
    	}			
	}
	
	//if VCAP_SERVICES is not found or is not used, error message is outputed 
	if (!foundService){
		System.out.println("WXS Credentials not found!");
	}
	
	try{
	
		//specify WebSphere eXtreme Scale as JCache provider to get caching provider 
		cachingProvider=Caching.getCachingProvider("com.ibm.websphere.jcache.CachingProviderImpl");
		
		//URI for a client that runs in stand-alone JVM
		URI uri = CachingProviderImpl.createClientURI(gridName, null, null);
		
		//set credentials (security configurations)
		CredentialGenerator credGen=new UserPasswordCredentialGenerator(username,password);
		ClientSecurityConfiguration csc = ClientSecurityConfigurationFactory.getClientSecurityConfiguration();
		csc.setCredentialGenerator(credGen);
		csc.setSecurityEnabled(true);
		
		//Set properties object with catalog endpoints and security configuration
		Properties properties=new Properties();
		properties.put(CachingProviderImpl.PROP_CATALOG_END_POINTS,hostName);
		properties.put(CachingProviderImpl.PROP_CLIENT_SECURITY_CONFIGURATION, csc);
		
		//retrieve remote CacheManager
		cacheManager=cachingProvider.getCacheManager(uri,null,properties);
		
		//retrieve Cache 
		cache=cacheManager.getCache(gridName);
		
	}catch(Exception e){
		System.out.println("Failed to connect to grid");
		e.printStackTrace();
	}
}

%>
<%
	try {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");
		
		//receive 'operation' parameter from request
		operation=request.getParameter("operation"); 

		
		//insert item into the grid using JCache API
		if ("insert".equals(operation)){
			String value=request.getParameter("value");
			cache.put(value,value);
		}
	
		//clear all key-value pairs in the grid using JCache API
		if ("clear".equals(operation)){
			cache.clear();
		}
		
		//retrieves all key-value pairs from the grid using an iterator using JCache API
		if ("loadData".equals(operation)){
			JSONArray jsonArray=new JSONArray(); 
			JSONObject json=new JSONObject();
			Iterator<Cache.Entry<String, String>> list=cache.iterator();
			
			while (list.hasNext()){
				Cache.Entry<String,String> currentEntry=list.next();
				JSONObject value=new JSONObject();
	        	value.put("value",currentEntry.getValue());
	        	jsonArray.put(value);
			}
		json.put("values",jsonArray);
		response.getWriter().write(json.toString());
		}
		
		//removes a key value pair from the grid using JCache API
		if ("remove".equals(operation)){
			String value=request.getParameter("task");
			cache.remove(value);
		}
		
	}catch (Exception e){
		System.out.println("Failed to perform " + operation + " on " + gridName + " .Application may have failed to connect to the grid");
		response.getWriter().write("Failed");
		e.printStackTrace();
	}
%>
