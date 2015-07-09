<!-- 
* 	Licensed under the Creative Commons License, Version 3.0 (the "License"); 
* 	you may not use this file except in compliance with the License. 
*  	You may obtain a copy of the License at 
* 	
* 	http://creativecommons.org/licenses/by-sa/3.0/us/
* 	
* 	Unless required by applicable law or agreed to in writing, software 
* 	distributed under the License is distributed on an "AS IS" BASIS, 
* 	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* 	See the License for the specific language governing permissions and 
* 	limitations under the License.
*	Created By: Stefan le Roux - www.coldfury.us, 2010
* 	Credit: Russell Brown - EmpireGP Services, 2007: I have based this service on Russell Brown's ColdFusion to Confluence API available at: http://blog.empiregpservices.com/post.cfm/coldfusion-to-confluence-gateway-api
*	Credit: Atlassian: Jira RPC Docs available at: http://docs.atlassian.com/software/jira/docs/api/rpc-jira-plugin/latest/index.html?com/atlassian/jira/rpc/soap/JiraSoapService.html
-->

<cfcomponent displayname="JiraService">

    <cffunction name="init" access="remote" returnType="Boolean">
        <cfargument name="url" type="Any" required="true" />
        <cfargument name="username" type="string" required="true" />
        <cfargument name="password" type="string" required="true" />
        
        <cfscript>
			VARIABLES._url = arguments.url;
			VARIABLES._username = arguments.username;
			VARIABLES._password = arguments.password;
			VARIABLES._userToken = "";
			VARIABLES._tokenTimeout = "1/1/2000";
			VARIABLES._timeoutMinutes = 15;
			VARIABLES.initRun = true;
			getUserToken();
		
	        return VARIABLES.initRun;
        </cfscript>
                
    </cffunction>
    

    <cffunction name="getUserToken" access="private" returntype="string">
    	<cfset var userToken = "">
    
		<cfif NOT VARIABLES.initRun>
            <cfthrow message="JiraService was not initialized correctly.">
            <cfabort>
        </cfif>
    
		<cfif VARIABLES._userToken EQ "">
        
        	<cfset userToken = createobject("webservice", VARIABLES._url).login(VARIABLES._username, VARIABLES._password)>
            <cfset VARIABLES._userToken = userToken>
            
        <cfelseif dateCompare(VARIABLES._tokenTimeout, now()) EQ -1>
            <cftry>
            	<cfset myUser = createobject("webservice", VARIABLES._url).getUser(VARIABLES._userToken, VARIABLES._username)>
            <cfcatch>
                <cfdump var="#cfcatch#" expand="false">
                <cfdump var="#variables#" expand="false">
            </cfcatch>
            </cftry>
            
        </cfif>
        
        <cfset VARIABLES._tokenTimeout = dateAdd("m", VARIABLES._timeoutMinutes, now())>
        
        <cfreturn VARIABLES._userToken>
        
    </cffunction>


    <cffunction name="showJiraWSDL" access="public" returntype="void" output="true">
        
        <cfset jiraWSDL = createobject("webservice", VARIABLES._url)>
        <cfdump var="#jiraWSDL#">
        
    </cffunction>

    <cffunction name="addActorsToProjectRole" access="public" returntype="void" output="false">
        <cfargument name="actors" type="array" required="yes"> 
        <cfargument name="projectRole" type="array" required="yes"> 
        <cfargument name="project" type="RemoteProject" required="yes"> 
        <cfargument name="actorType" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    

    <cffunction name="addAttachmentsToIssue" access="public" returntype="boolean" output="false" hint="Add attachments to an issue. This method accepts the data of the attachments as byte arrays. This is known to cause problems when the attachments are above a certain size.">
        <cfargument name="issueKey" type="String" required="yes"> 
        <cfargument name="attachmentFiles" type="array" required="yes" hint="An array containing the File Name, File Path to the uploaded files."> 
        
		<cfscript>
			var retVar = "";
			var binaryFile = 0;
			var fileNameArray = arraynew(1);
			var fileBinaryArray = arraynew(1);
			
			for(i = 1; i lte arraylen(ARGUMENTS.attachmentFiles); i++) {
				//populate array of File Names
				fileName = ARGUMENTS.attachmentFiles[i].FILENAME;
				//populate array of File Binaries
				fileBinary = filereadbinary(ARGUMENTS.attachmentFiles[i].FILEPATH&"\"&ARGUMENTS.attachmentFiles[i].FILENAME);
				arrayappend(fileNameArray, fileName);
				arrayappend(fileBinaryArray, fileBinary);
			}
			//Web service call to add attachments
			retVar = createobject("webservice", VARIABLES._url).addAttachmentsToIssue(getUserToken(), ARGUMENTS.issueKey, fileNameArray, fileBinaryArray);
			return retVar;
        </cfscript>
    
    </cffunction>
    
    
    <cffunction name="addBase64EncodedAttachmentsToIssue" access="public" returntype="boolean" output="false" hint="An alternative mechanism for adding attachments to an issue. This method accepts the data of the attachments as Base64 encoded strings instead of byte arrays. This is to combat the XML message bloat created by Axis when SOAP-ifying byte arrays.">
        <cfargument name="issueKey" type="String" required="yes"> 
        <cfargument name="attachmentFiles" type="array" required="yes" hint="An array containing the File Name, File Path to the uploaded files."> 
    
		<cfscript>
			var retVar = "";
			var binaryFile = 0;
			var fileNameArray = arraynew(1);
			var fileBinaryArray = arraynew(1);
			
			for(i = 1; i lte arraylen(ARGUMENTS.attachmentFiles); i++) {
				//populate array of File Names
				fileName = ARGUMENTS.attachmentFiles[i].FILENAME;
				//populate array of File Binaries
				fileBinary = filereadbinary(ARGUMENTS.attachmentFiles[i].FILEPATH&"\"&ARGUMENTS.attachmentFiles[i].FILENAME);
				arrayappend(fileNameArray, fileName);
				arrayappend(fileBinaryArray, tobase64(fileBinary));
			}
			//Web service call to add attachments
			retVar = createobject("webservice", VARIABLES._url).addBase64EncodedAttachmentsToIssue(getUserToken(), ARGUMENTS.issueKey, fileNameArray, fileBinaryArray);
			return retVar;
        </cfscript>
    
    </cffunction>
    
    
    <cffunction name="addComment" access="public" returntype="void" output="false">
        <cfargument name="issueKey" type="string" required="yes"> 
        <cfargument name="body" type="string" required="yes">

        <cfscript>
			var retVar = "";
			var comment = structNew();
				comment.body = ARGUMENTS.body;
			//Web service call to add comment
			retVar = createobject("webservice", VARIABLES._url).addComment(getUserToken(), ARGUMENTS.issueKey, comment);
		</cfscript>
        
    </cffunction>
    
    
    
    <cffunction name="addDefaultActorsToProjectRole" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String[]" required="yes"> 
        <cfargument name="in03" type="array" required="yes"> 
        <cfargument name="in04" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addPermissionTo" access="public" returntype="RemotePermissionScheme" output="false">
        <cfargument name="in02" type="RemotePermissionScheme" required="yes"> 
        <cfargument name="in03" type="RemotePermission" required="yes"> 
        <cfargument name="in04" type="RemoteEntity" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addUserToGroup" access="public" returntype="void" output="false">
        <cfargument name="in02" type="RemoteGroup" required="yes"> 
        <cfargument name="in03" type="RemoteUser" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addVersion" access="public" returntype="RemoteVersion" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteVersion" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addWorklogAndAutoAdjustRemainingEstimate" access="public" returntype="RemoteWorklog" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteWorklog" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addWorklogAndRetainRemainingEstimate" access="public" returntype="RemoteWorklog" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteWorklog" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="addWorklogWithNewRemainingEstimate" access="public" returntype="RemoteWorklog" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteWorklog" required="yes"> 
        <cfargument name="in04" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="archiveVersion" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes"> 
        <cfargument name="in04" type="boolean" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="createGroup" access="public" returntype="void" output="false" hint="Creates a group with the given name optionally adding the given user to it.">
        <cfargument name="groupName" type="String" required="yes"> 
        <cfargument name="username" type="String" required="no">

        <cfscript>
        
			var remoteUser = "";
				remoteUser = createobject("webservice", VARIABLES._url).getUser(getUserToken(), ARGUMENTS.username);

			var retVar = "";
			retVar = createobject("webservice", VARIABLES._url).createGroup(getUserToken(), ARGUMENTS.groupName, remoteUser);
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="createIssue" access="public" returntype="struct" output="false" hint="Creates a new issue in JIRA, with the minimum of project, summary, type supplied. The new Issue is returned.">
        <cfargument name="project" type="string" required="yes" hint="Project Key.">
        <cfargument name="summary" type="string" required="yes" hint="Ussue summary.">
        <cfargument name="type" type="string" required="yes" hint="Issue Type see: getIssueTypes().">
    	<cfargument name="assignee" type="string" required="no" hint="JIRA Username. If not specified, new issue will be assigned to creator. If specified and the user has the appropriate roles, the issue will be assigned.">
        <cfargument name="description" type="string" required="no" hint="Issue description.">
        <cfargument name="duedate" type="string" required="no" hint="issue due date.">
        <cfargument name="environment" type="string" required="no" hint="Issue environment. For example operating system, software platform and/or hardware specifications (include as appropriate for the issue).">
        <cfargument name="priority" type="numeric" required="no" hint="Issue priority see: getPriorities().">

        <cfscript>
			var newIssue = "";
			var issue = structNew();
				issue.project = ARGUMENTS.project;
				issue.summary = ARGUMENTS.summary;
				issue.type = ARGUMENTS.type;
				//set assignee
				try {
					issue.assignee = ARGUMENTS.assignee;
				}
				catch (any e) {
					//unable to assign to user, defaulting to creator ...
				}
				//set description
				if(isdefined("ARGUMENTS.description") and ARGUMENTS.description neq "") {
					issue.description = ARGUMENTS.description;
				}
				//set duedate
				if(isdefined("ARGUMENTS.duedate") and ARGUMENTS.duedate neq "") {
					issue.duedate = dateformat(ARGUMENTS.duedate);
				}
				//set environment
				if(isdefined("ARGUMENTS.environment") and ARGUMENTS.environment neq "") {
					issue.environment = ARGUMENTS.environment;
				}
				//set priority
				if(isdefined("ARGUMENTS.priority") and ARGUMENTS.priority neq "") {
					issue.priority = ARGUMENTS.priority;
				}				
				//Web service call to add issue
				newIssue = createobject("webservice", VARIABLES._url).createIssue(getUserToken(), issue);
				issue = getIssue(newIssue.getKey());
			return issue;
		</cfscript>
            
    </cffunction>
    
    
    
    <cffunction name="createIssueWithSecurityLevel" access="public" returntype="RemoteIssue" output="false">
        <cfargument name="in02" type="RemoteIssue" required="yes"> 
        <cfargument name="in03" type="long" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="createPermissionScheme" access="public" returntype="RemotePermissionScheme" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    <cffunction name="createProject" access="public" returntype="void" output="false">
        <cfargument name="key" type="String" required="yes"> 
        <cfargument name="name" type="String" required="yes"> 
        <cfargument name="description" type="String" required="yes"> 
        <cfargument name="url" type="String" required="yes">
        <cfargument name="lead" type="String" required="yes">
        <cfargument name="permissionScheme" type="struct" required="yes">
				
		<cfset var notificationScheme = structNew()>
		<cfset var issueSecurityScheme = structNew()>
        
        <cfscript>
			var callVar = "";
			var retVar = "";

			callVar = createobject("webservice", VARIABLES._url).createProject(getUserToken(), ARGUMENTS.key, ARGUMENTS.name, ARGUMENTS.description, ARGUMENTS.url, ARGUMENTS.lead, ARGUMENTS.permissionScheme, notificationScheme, issueSecurityScheme);
		</cfscript>

    </cffunction>
    
    
    
    <cffunction name="createProjectFromObject" access="public" returntype="RemoteProject" output="false">
    	<cfargument name="in02" type="RemoteProject" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="createProjectRole" access="public" returntype="RemoteProjectRole" output="false">
    	<cfargument name="in02" type="RemoteProjectRole" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="createUser" access="public" returntype="RemoteUser" output="false">
        <cfargument name="username" type="String" required="yes"> 
        <cfargument name="password" type="String" required="yes"> 
        <cfargument name="fullName" type="String" required="yes"> 
        <cfargument name="email" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
			retVar = createobject("webservice", VARIABLES._url).createUser(getUserToken(), ARGUMENTS.username, ARGUMENTS.password, ARGUMENTS.fullName, ARGUMENTS.email);
		</cfscript>
    
    </cffunction>
    
    
    
    <cffunction name="deleteGroup" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteIssue" access="public" returntype="void" output="false">
    	<cfargument name="issueKey" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
			retVar = createobject("webservice", VARIABLES._url).deleteIssue(getUserToken(), ARGUMENTS.issueKey);
		</cfscript>
    
    </cffunction>
    
    
    
    <cffunction name="deletePermissionFrom" access="public" returntype="RemotePermissionScheme" output="false">
        <cfargument name="in02" type="RemotePermissionScheme" required="yes"> 
        <cfargument name="in03" type="RemotePermission" required="yes"> 
        <cfargument name="in04" type="RemoteEntity" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deletePermissionScheme" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteProject" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteProjectAvatar" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="long" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteProjectRole" access="public" returntype="void" output="false">
        <cfargument name="in02" type="RemoteProjectRole" required="yes"> 
        <cfargument name="in03" type="boolean" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteUser" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteWorklogAndAutoAdjustRemainingEstimate" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteWorklogAndRetainRemainingEstimate" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="deleteWorklogWithNewRemainingEstimate" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="editComment" access="public" returntype="RemoteComment" output="false">
    	<cfargument name="in02" type="RemoteComment" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    <cffunction name="getAllPermissions" access="public" returntype="any" output="false">
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getAllPermissions(getUserToken());
			var permissionArray = arraynew(1);
        
			for(i=1; i lte arraylen(retVar); i++) {
				permissionStruct = structnew();
				permissionStruct.name = retVar[i].getName();
				permissionStruct.id = retVar[i].getPermission();
				arrayappend(permissionArray, permissionStruct);
			}
			
			return permissionArray;
		</cfscript>
    </cffunction>
    
    
    
    <cffunction name="getAssociatedNotificationSchemes" access="public" returntype="array" output="false">
    	<cfargument name="in02" type="RemoteProjectRole" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="getAssociatedPermissionSchemes" access="public" returntype="array" output="false">
   		<cfargument name="in02" type="RemoteProjectRole" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    <cffunction name="getAttachmentsFromIssue" access="public" returntype="array" output="false">
    	<cfargument name="issueKey" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getAttachmentsFromIssue(getUserToken(), ARGUMENTS.issueKey);
			var attachmentArray = arraynew(1);

			for(i=1; i lte arraylen(retVar); i++) {
				attachmentStruct = structnew();
				attachmentStruct.author = retVar[i].getAuthor();
				attachmentStruct.created = retVar[i].getCreated().getTime();
				attachmentStruct.filename = retVar[i].getFilename();
				
				//query server info to resolve path to attachment...
				serverInfo = getServerInfo();
				attachmentStruct.fileURL = serverInfo.attachmentPath&retVar[i].getId()&"/"&retVar[i].getFilename();
				
				attachmentStruct.filesize = retVar[i].getFilesize();
				attachmentStruct.mimetype = retVar[i].getMimetype();
				attachmentStruct.id = retVar[i].getId();
				arrayappend(attachmentArray, attachmentStruct);
			}
			return attachmentArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getAvailableActions" access="public" returntype="array" output="false">
		<cfargument name="issueKey" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getAvailableActions(getUserToken(), ARGUMENTS.issueKey);
			var actionArray = arraynew(1);
			
			for(i=1; i lte arraylen(retVar); i++) {
				actionStruct = structnew();
				actionStruct.name = retVar[i].getName();
				actionStruct.id = retVar[i].getId();
				arrayappend(actionArray, actionStruct);
			}
			return actionArray;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="getComment" access="public" returntype="struct" output="false">
		<cfargument name="id" type="numeric" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getComment(getUserToken(), ARGUMENTS.id);
			var	commentStruct = structnew();
				commentStruct.author = retVar.getAuthor();
				commentStruct.body = retVar.getBody();
				commentStruct.created = retVar.getCreated().getTime();
				commentStruct.id = retVar.getId();	
			return commentStruct;
		</cfscript>
        
    </cffunction>
    
    
    <cffunction name="getComments" access="public" returntype="array" output="false">
    	<cfargument name="issueKey" type="String" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getComments(getUserToken(), ARGUMENTS.issueKey);
			var commentArray = arraynew(1);
        	
			for(i=1; i lte arraylen(retVar); i++) {
				commentStruct = structnew();
				commentStruct.author = retVar[i].getAuthor();
				commentStruct.body = retVar[i].getBody();
				commentStruct.created = retVar[i].getCreated().getTime();
				commentStruct.id = retVar[i].getId();
				arrayappend(commentArray, commentStruct);
			}
			return commentArray;
		</cfscript>
        
    </cffunction>
    
    
    
    <cffunction name="getComponents" access="public" returntype="array" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="getConfiguration" access="public" returntype="RemoteConfiguration" output="false">
    	
        <cfthrow message="Method not implimented yet.">
        
    </cffunction>
    
    
    
    <cffunction name="getCustomFields" access="public" returntype="array" output="false">
    	
        <cfthrow message="Method not implimented yet.">
        
    </cffunction>
    
    
    
    <cffunction name="getDefaultRoleActors" access="public" returntype="RemoteRoleActors" output="false">
   		<cfargument name="in02" type="RemoteProjectRole" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="getFavouriteFilters" access="public" returntype="array" output="false">
    	
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="getFieldsForAction" access="public" returntype="array" output="false">
        <cfargument name="issueKey" type="String" required="yes"> 
        <cfargument name="actionIdString" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
        
    
    </cffunction>
    
    
    
    <cffunction name="getFieldsForEdit" access="public" returntype="array" output="false">
    	<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="getGroup" access="public" returntype="struct" output="false" hint="Find the group with the specified name in JIRA. Struct will include an array of users in the Group.">
    	<cfargument name="groupName" type="String" required="yes">
        
		<cfscript>
			var	groupStruct = structnew();
			try {
				var retVar = "";
					retVar = createobject("webservice", VARIABLES._url).getGroup(getUserToken(), ARGUMENTS.groupName);
					groupStruct.name = retVar.getName();
				var userArray = arraynew(1);
					for(u = 1; u lte arraylen(retVar.getUsers()); u++) {
						username = retVar.getUsers()[u].getName();
						user = getUser(username);
						arrayappend(userArray, user);
					}
					groupStruct.users = userArray;
			}
			catch (any e) {
				//return empty struct
			}
			return groupStruct;
		</cfscript>
		    
    </cffunction>
    
    
    <cffunction name="getIssue" access="public" returntype="struct" output="false">
    	<cfargument name="issueKey" type="String" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getIssue(getUserToken(), ARGUMENTS.issueKey);
			var	issueStruct = structnew();
				issueStruct.assignee = retVar.getAssignee();
				issueStruct.created = retVar.getCreated().getTime();
				issueStruct.description = retVar.getDescription();
				try {
					issueStruct.duedate = retVar.getDuedate().getTime();
				}
				catch (any e){
					issueStruct.duedate = "";
				}
				issueStruct.environment = retVar.getEnvironment();
				issueStruct.key = retVar.getKey();
				issueStruct.priority = retVar.getPriority();
				issueStruct.project = retVar.getProject();
				issueStruct.reporter = retVar.getReporter();
				issueStruct.resolution = retVar.getResolution();
				issueStruct.status = retVar.getStatus();
				issueStruct.summary = retVar.getSummary();
				issueStruct.type = retVar.getType();
				issueStruct.id = retVar.getid();
			
			return issueStruct;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getIssueById" access="public" returntype="struct" output="false">
    	<cfargument name="id" type="numeric" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getIssueById(getUserToken(), ARGUMENTS.id);
			var	commentStruct = structnew();
				commentStruct.assignee = retVar.getAssignee();
				commentStruct.created = retVar.getCreated().getTime();
				commentStruct.description = retVar.getDescription();
				commentStruct.duedate = retVar.getDuedate().getTime();
				commentStruct.environment = retVar.getEnvironment();
				commentStruct.key = retVar.getKey();
				commentStruct.priority = retVar.getPriority();
				commentStruct.project = retVar.getProject();
				commentStruct.reporter = retVar.getReporter();
				commentStruct.resolution = retVar.getResolution();
				commentStruct.status = retVar.getStatus();
				commentStruct.summary = retVar.getSummary();
				commentStruct.type = retVar.getType();
				commentStruct.id = retVar.getid();
			
			return commentStruct;
		</cfscript>
    
    </cffunction>
    
    
    
    <cffunction name="getIssueCountForFilter" access="public" returntype="long" output="false">
		<cfargument name="in02" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    <cffunction name="getIssueTypes" access="public" returntype="array" output="false" hint="Returns an array of all the issue types for all projects in JIRA.">

        <cfscript>
			var retVar = "";
			var issueTypeArray = arraynew(1);
			retVar = createobject("webservice", VARIABLES._url).getIssueTypes(getUserToken());
			
			for(i=1; i lte arraylen(retVar); i++) {
				issueTypeStruct = structnew();
				issueTypeStruct.name = retVar[i].getName();
				issueTypeStruct.id = retVar[i].getId();
				issueTypeStruct.icon = retVar[i].getIcon();
				arrayappend(issueTypeArray, issueTypeStruct);
			}
			
			return issueTypeArray;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="getIssueTypesForProject" access="public" returntype="array" output="false" hint="Returns an array of all the (non-sub task) issue types for the specified project id.">
    	<cfargument name="projectId" type="numeric" required="yes">
    	                
        <cfscript>
			var retVar = "";
			var issueTypeArray = arraynew(1);
			retVar = createobject("webservice", VARIABLES._url).getIssueTypesForProject(getUserToken(), ARGUMENTS.projectId);
			
			for(i=1; i lte arraylen(retVar); i++) {
				issueTypeStruct = structnew();
				issueTypeStruct.name = retVar[i].getName();
				issueTypeStruct.id = retVar[i].getId();
				issueTypeStruct.icon = retVar[i].getIcon();
				arrayappend(issueTypeArray, issueTypeStruct);
			}
			
			return issueTypeArray;
		</cfscript>
    
    </cffunction>
    
    
    
    <cffunction name="getIssuesFromFilter" access="public" returntype="array" output="false">
    	<cfargument name="in02" type="String" required="yes">
    
    </cffunction>
    
    
    
    <cffunction name="getIssuesFromFilterWithLimit" access="public" returntype="array" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="int" required="yes"> 
        <cfargument name="in04" type="int" required="yes">
    
    </cffunction>
    
    
    
    <cffunction name="getIssuesFromJqlSearch" access="public" returntype="array" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="int" required="yes">
    
    </cffunction>
    
    
    <cffunction name="getIssuesFromTextSearch" access="public" returntype="array" output="false" hint="Returns issues containing searchTerms. Note: this is a fuzzy search, returned in order of 'relevance', so the results are only generally useful for human consumption. This method also respects the jira.search.views.max.limit and jira.search.views.max.unlimited.group JIRA properties which will override the max number of results returned. If the jira.search.views.max.limit property is set and you are not in a group specified by jira.search.views.max.unlimited.group then the number of results returned will be constrained by the value of jira.search.views.max.limit if it is less than the specified maxNumResults.">
   		<cfargument name="searchTerms" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getIssuesFromTextSearch(getUserToken(), ARGUMENTS.searchTerms);
				
			var issueArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				myIssue = getIssue(retVar[i].getKey());
				arrayappend(issueArray, myIssue);
			}
			
			return issueArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getIssuesFromTextSearchWithLimit" access="public" returntype="array" output="false">
        <cfargument name="searchTerms" type="String" required="yes"> 
        <cfargument name="offSet" type="numeric" required="yes" hint="The place in the result set to use as the first result returned.">
        <cfargument name="maxNumResults" type="numeric" required="yes" hint="The maximum number of results that this method will return.">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getIssuesFromTextSearchWithLimit(getUserToken(), ARGUMENTS.searchTerms, ARGUMENTS.offSet, ARGUMENTS.maxNumResults);
				
			var issueArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				myIssue = getIssue(retVar[i].getKey());
				arrayappend(issueArray, myIssue);
			}
			
			return issueArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getIssuesFromTextSearchWithProject" access="public" returntype="array" output="false">
        <cfargument name="projectKeys" type="array" required="yes">
        <cfargument name="searchTerms" type="string" required="yes">
        <cfargument name="maxNumResults" type="numeric" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getIssuesFromTextSearchWithProject(getUserToken(), ARGUMENTS.projectKeys, ARGUMENTS.searchTerms, ARGUMENTS.maxNumResults);
				
			var issueArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				myIssue = getIssue(retVar[i].getKey());
				arrayappend(issueArray, myIssue);
			}
			
			return issueArray;
		</cfscript>
    
    </cffunction>
    
    
    
    <cffunction name="getNotificationSchemes" access="public" returntype="array" output="false">
    	
        <cfthrow message="Method not implimented yet.">
        
    </cffunction>
    
    
    <cffunction name="getPermissionSchemes" access="public" returntype="array" output="false">
    
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getPermissionSchemes(getUserToken());

			var permissionSchemeArray = arraynew(1);
/*			for(i=1; i lte arraylen(retVar); i++) {
				permissionSchemeStruct = structnew();
				permissionSchemeStruct.name = retVar[i].getName();
				permissionSchemeStruct.id = retVar[i].getId();
				permissionSchemeStruct.description = retVar[i].getDescription();
				arrayappend(permissionSchemeArray, permissionSchemeStruct);
			}
			
			return permissionSchemeArray;*/
		</cfscript>
			
    
    </cffunction>
    
    
    <cffunction name="getPriorities" access="public" returntype="array" output="false">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getPriorities(getUserToken());
			
			var piorityArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				priorityStruct = structnew();
				priorityStruct.name = retVar[i].getName();
				priorityStruct.id = retVar[i].getId();
				priorityStruct.icon = retVar[i].getIcon();
				arrayappend(piorityArray, priorityStruct);
			}
			
			return piorityArray;
		</cfscript>
        
    </cffunction>
    
    
    
    <cffunction name="getProjectAvatar" access="public" returntype="RemoteAvatar" output="false">
    	<cfargument name="in02" type="String" required="yes">
    
    </cffunction>
    
    
    
    <cffunction name="getProjectAvatars" access="public" returntype="array" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="boolean" required="yes">
    
    </cffunction>
    
    
    <cffunction name="getProjectById" access="public" returntype="struct" output="false">
    	<cfargument name="id" type="numeric" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getProjectById(getUserToken(), ARGUMENTS.id);
				
			var	projectStruct = structnew();
				projectStruct.description = retVar.getDescription();
				projectStruct.key = retVar.getKey();
				projectStruct.lead = retVar.getLead();
				projectStruct.projectURL = retVar.getProjectUrl();
				projectStruct.url = retVar.getUrl();
				projectStruct.name = retVar.getName();
				projectStruct.id = retVar.getId();

			return projectStruct;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getProjectByKey" access="public" returntype="struct" output="false">
    	<cfargument name="projectKey" type="String" required="yes">
		
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getProjectByKey(getUserToken(), ARGUMENTS.projectKey);
				
			var	projectStruct = structnew();
				projectStruct.description = retVar.getDescription();
				projectStruct.key = retVar.getKey();
				projectStruct.lead = retVar.getLead();
				projectStruct.projectURL = retVar.getProjectUrl();
				projectStruct.url = retVar.getUrl();
				projectStruct.name = retVar.getName();
				projectStruct.id = retVar.getId();

			return projectStruct;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="getProjectRole" access="public" returntype="struct" output="false">
    	<cfargument name="id" type="numeric" required="yes">
		
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getProjectRole(getUserToken(), ARGUMENTS.id);

			var	projectRoleStruct = structnew();
				projectRoleStruct.description = retVar.getDescription();
				projectRoleStruct.id = retVar.getId();
				projectRoleStruct.name = retVar.getName();

			return projectRoleStruct;
		</cfscript>
        
    </cffunction>
    
    
    
    <cffunction name="getProjectRoleActors" access="public" returntype="RemoteProjectRoleActors" output="false">
        <cfargument name="projectRole" type="RemoteProjectRole" required="yes"> 
        <cfargument name="project" type="RemoteProject" required="yes">
    	
        <cfthrow message="Method not implimented yet.">

    </cffunction>
    
    
    <cffunction name="getProjectRoles" access="public" returntype="array" output="false">
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getProjectRoles(getUserToken());
				
			var projectRoleArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				projectRoleStruct = structnew();
				projectRoleStruct.description = retVar[i].getDescription();
				projectRoleStruct.id = retVar[i].getId();
				projectRoleStruct.name = retVar[i].getName();
				arrayappend(projectRoleArray, projectRoleStruct);
			}

			return projectRoleArray;
		</cfscript>
    </cffunction>
    
    
    
    <cffunction name="getProjectWithSchemesById" access="public" returntype="RemoteProject" output="false">
    	<cfargument name="in02" type="long" required="yes">
    
    </cffunction>
    
    
    
    <cffunction name="getProjectsNoSchemes" access="public" returntype="array" output="false" hint="Returns an array of all the Projects defined in JIRA. ">
    	
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getProjectsNoSchemes(getUserToken());
				
			var projectArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				project = getProjectByKey(retVar[i].getKey());
				arrayappend(projectArray, project);
			}
			return projectArray;

		</cfscript>

    </cffunction>
    
    
    <cffunction name="getResolutionDateById" access="public" returntype="string" output="false" hint="Given an issue id, this method returns the resolution date for this issue. If the issue hasn't been resolved yet, this method will return null.">
    	<cfargument name="issueId" type="numeric" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getResolutionDateById(getUserToken(), ARGUMENTS.issueId);
				
				if(isdefined("retVar") and retVar neq "") {
					resolutionDate = retVar;
				} else {
					resolutionDate = "null";
				}
				return resolutionDate;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getResolutionDateByKey" access="public" returntype="string" output="false" hint="Given an issue key, this method returns the resolution date for this issue. If the issue hasn't been resolved yet, this method will return null.">
	    <cfargument name="issueKey" type="String" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getResolutionDateByKey(getUserToken(), ARGUMENTS.issueKey);
				
				if(isdefined("retVar") and retVar neq "") {
					resolutionDate = retVar;
				} else {
					resolutionDate = "null";
				}
				return resolutionDate;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getResolutions" access="public" returntype="array" output="false" hint="Returns an array of all the issue resolutions in JIRA.">
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getResolutions(getUserToken());
				
			var resolutionArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				resolutionStruct = structnew();
				resolutionStruct.description = retVar[i].getDescription();
				//resolutionStruct.icon = retVar[i].getIcon();
				resolutionStruct.name = retVar[i].getName();
				resolutionStruct.id = retVar[i].getId();
				
				arrayappend(resolutionArray, resolutionStruct);
			}
			return resolutionArray;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="getSavedFilters" access="public" returntype="array" output="false" hint="This retreives a list of the currently logged in user's favourite fitlers.">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getSavedFilters(getUserToken());
			
			var savedFilterArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				savedFilterStruct = structnew();
				savedFilterStruct.author = retVar[i].getAuthor();
				savedFilterStruct.description = retVar[i].getDescription();
				savedFilterStruct.project = retVar[i].getProject();
				savedFilterStruct.xml = retVar[i].getXml();
				savedFilterStruct.name = retVar[i].getName();
				savedFilterStruct.id = retVar[i].getId();				
				arrayappend(savedFilterArray, savedFilterStruct);
			}
			
			return savedFilterArray;
		</cfscript>
        
    </cffunction>
    
    
    <cffunction name="getSecurityLevel" access="public" returntype="struct" output="false" hint="Returns the current security level for given issue.">
    	<cfargument name="issueKey" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
            
    </cffunction>
    
    
    <cffunction name="getSecurityLevels" access="public" returntype="array" output="false" hint="Returns an array of all security levels for a given project.">
    	<cfargument name="projectKey" type="String" required="yes">
		
        <cfthrow message="Method not implimented yet.">
            
    </cffunction>
    
 
    <cffunction name="getSecuritySchemes" access="public" returntype="array" output="false">
    
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getSecuritySchemes(getUserToken());
				
			var securitySchemeArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				securitySchemeStruct = structnew();
				securitySchemeStruct.description = retVar[i].getDescription();
				securitySchemeStruct.id = retVar[i].getId();
				securitySchemeStruct.name = retVar[i].getName();
				securitySchemeStruct.type = retVar[i].getType();
				
				arrayappend(securitySchemeArray, securitySchemeStruct);
			}
			
			return securitySchemeArray;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="getServerInfo" access="public" returntype="struct" output="false" hint="Returns information about the server JIRA is running on including build number and base URL.">
    	
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getServerInfo(getUserToken());
			var	serverInfoStruct = structnew();
				serverInfoStruct.baseURL = retVar.getBaseUrl();
                serverInfoStruct.buildDate = retVar.getBuildDate().getTime();
                serverInfoStruct.buildNumber = retVar.getBuildNumber();
                serverInfoStruct.edition = retVar.getEdition();
                serverInfoStruct.serverTime = retVar.getServerTime().getServerTime();
                serverInfoStruct.version = retVar.getVersion();
				serverInfoStruct.attachmentPath = retVar.getBaseUrl()&"/secure/attachment/";
			
			return serverInfoStruct;

		</cfscript>
        
    </cffunction>
    
    
    <cffunction name="getStatuses" access="public" returntype="array" output="false" hint="Returns an array of all the issue statuses in JIRA.">
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getStatuses(getUserToken());
				
			var statusArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				statusStruct = structnew();
				statusStruct.name = retVar[i].getName();
				statusStruct.id = retVar[i].getId();
				arrayappend(statusArray, statusStruct);
			}
			
			return statusArray;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getSubTaskIssueTypes" access="public" returntype="array" output="false" hint="Returns an array of all the sub task issue types in JIRA.">
    	
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getSubTaskIssueTypes(getUserToken());
				
			var statusArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				statusStruct = structnew();
				statusStruct.name = retVar[i].getName();
				statusStruct.id = retVar[i].getId();
				arrayappend(statusArray, statusStruct);
			}
			
			return statusArray;
		</cfscript>
        
    </cffunction>
    
    
    <cffunction name="getSubTaskIssueTypesForProject" access="public" returntype="array" output="false" hint="Returns an array of all the sub task issue types for the specified project id.">
    	<cfargument name="projectId" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getSubTaskIssueTypesForProject(getUserToken(), ARGUMENTS.projectId);
				
			var statusArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				statusStruct = structnew();
				statusStruct.name = retVar[i].getName();
				statusStruct.id = retVar[i].getId();
				arrayappend(statusArray, statusStruct);
			}
			
			return statusArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getUser" access="public" returntype="struct" output="false" hint="Returns information about a user defined to JIRA.">
    	<cfargument name="username" type="String" required="yes">

		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getUser(getUserToken(), ARGUMENTS.username);
			var userStruct = structnew();
				userStruct.email = retVar.getEmail();
				userStruct.fullname = retVar.getFullname();
				userStruct.username = retVar.getName();
			return userStruct;
		</cfscript>

        
    </cffunction>
    
    
    <cffunction name="getVersions" access="public" returntype="array" output="false" hint="Returns an array of all the versions for the specified project key.">
    	<cfargument name="projectKey" type="String" required="yes">

        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getVersions(getUserToken(), ARGUMENTS.projectKey);
			
			var versionArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				versionStruct = structnew();
				versionStruct.releaseDate = retVar[i].getReleaseDate().getTime();
				versionStruct.sequence = retVar[i].getSequence();
				versionStruct.archived = retVar[i].isArchived();
				versionStruct.released = retVar[i].isReleased();
				versionStruct.name = retVar[i].getName();
				versionStruct.id = retVar[i].getId();
				arrayappend(versionArray, versionStruct);
			}
			
			return versionArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="getWorklogs" access="public" returntype="array" output="false" hint="Returns all worklogs for the given issue. You can only log work on an issue if your administrator has enabled 'time-tracking', and if you have the correct permissions in the project to which the issue belongs.">
    	<cfargument name="issueKey" type="String" required="yes">
        
        <cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).getWorklogs(getUserToken(), ARGUMENTS.issueKey);
        
			var worklogArray = arraynew(1);
			for(i=1; i lte arraylen(retVar); i++) {
				worklogStruct = structnew();
				worklogStruct.author = retVar[i].getAuthor();
				worklogStruct.comment = retVar[i].getComment();
				worklogStruct.created = retVar[i].getCreated().getTime();
				worklogStruct.groupLevel = retVar[i].getGroupLevel();
				worklogStruct.id = retVar[i].getId();
				worklogStruct.roleLevelId = retVar[i].getRoleLevelId();
				worklogStruct.startDate = retVar[i].getStartDate().getTime();
				worklogStruct.timeSpent = retVar[i].getTimeSpent();
				worklogStruct.timeSpentInSeconds = retVar[i].getTimeSpentInSeconds();
				worklogStruct.updateAuthor = retVar[i].getUpdateAuthor();
				worklogStruct.updated = retVar[i].getUpdated().getTime();

				arrayappend(worklogArray, worklogStruct);
			}
			
			return worklogArray;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="hasPermissionToCreateWorklog" access="public" returntype="boolean" output="false" hint="Determines if the user has the permission to add worklogs to the specified issue, that timetracking is enabled in JIRA and that the specified issue is in an editable workflow state.">
    	<cfargument name="issueKey" type="String" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).hasPermissionToCreateWorklog(getUserToken(), ARGUMENTS.issueKey);
			return retVar;
		</cfscript>
    
    </cffunction>
    
     
    <cffunction name="hasPermissionToDeleteWorklog" access="public" returntype="boolean" output="false" hint="Determine whether the current user has the permission to delete the supplied worklog, that timetracking is enabled in JIRA and that the associated issue is in an editable workflow state. This method will return true if the user is a member of the worklog's group/role level (if specified) AND * The user has the WORKLOG_DELETE_ALL permission; OR * The user is the worklog author and has the WORKLOG_DELETE_OWN permission and false otherwise.">
    	<cfargument name="worklogId" type="numeric" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).hasPermissionToDeleteWorklog(getUserToken(), ARGUMENTS.worklogId);
			return retVar;
		</cfscript>

    </cffunction>
    
    
    <cffunction name="hasPermissionToEditComment" access="public" returntype="boolean" output="false">
    	<cfargument name="id" type="numeric" required="yes" hint="Comment ID.">
        
		<cfscript>
			var comment = getComment(ARGUMENTS.id);
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).hasPermissionToEditComment(getUserToken(), comment);
			return retVar;
		</cfscript>
    
    </cffunction>
    

    <cffunction name="hasPermissionToUpdateWorklog" access="public" returntype="boolean" output="false" hint="Determine whether the current user has the permission to update the supplied worklog, that timetracking is enabled in JIRA and that the associated issue is in an editable workflow state. This method will return true if the user is a member of the worklog's group/role level (if specified) AND * The user has the WORKLOG_EDIT_ALL permission; OR * The user is the worklog author and has the WORKLOG_EDIT_OWN permission and false otherwise.">
    	<cfargument name="worklogId" type="numeric" required="yes">
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).hasPermissionToUpdateWorklog(getUserToken(), ARGUMENTS.worklogId);
			return retVar;
		</cfscript>
    
    </cffunction>
    
    
    <cffunction name="isProjectRoleNameUnique" access="public" returntype="boolean" output="false">
    	<cfargument name="name" type="String" required="yes">
        
		<cfscript>
			var retVar = "";
				try {
					retVar = createobject("webservice", VARIABLES._url).isProjectRoleNameUnique(getUserToken(), ARGUMENTS.name);
				}
				catch (any e) {
					retVar = false;
				}
			return retVar;
		</cfscript>
    
    </cffunction>

    
    <cffunction name="progressWorkflowAction" access="public" returntype="struct" output="false">
        <cfargument name="issueKey" type="String" required="yes"> 
        <cfargument name="actionIdString" type="String" required="yes" hint="First call getAvailableActions() to find a valid array of available actions for the issue in it's current state.">
        <cfargument name="actionParams" type="array" required="no">
        
        <cfset var actionParamsArray = arraynew(1)>
        
		<cfscript>
			var retVar = "";
				retVar = createobject("webservice", VARIABLES._url).progressWorkflowAction(getUserToken(), ARGUMENTS.issueKey, ARGUMENTS.actionIdString, actionParamsArray);
				myIssue = getIssue(retVar.getKey());
			return myIssue;
		</cfscript>

    </cffunction>
    
    
    
    <cffunction name="refreshCustomFields" access="public" returntype="void" output="false">
    	
        <cfthrow message="Method not implimented yet.">
        
    </cffunction>
    
    
    
    <cffunction name="releaseVersion" access="public" returntype="void" output="false">
        <cfargument name="projectKey" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteVersion" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="removeActorsFromProjectRole" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String[]" required="yes"> 
        <cfargument name="in03" type="array" required="yes"> 
        <cfargument name="in04" type="RemoteProject" required="yes"> 
        <cfargument name="in05" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="removeAllRoleActorsByNameAndType" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="removeAllRoleActorsByProject" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="RemoteProject" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="removeDefaultActorsFromProjectRole" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String[]" required="yes"> 
        <cfargument name="in03" type="array" required="yes"> 
        <cfargument name="in04" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="removeUserFromGroup" access="public" returntype="void" output="false">
        <cfargument name="in02" type="RemoteGroup" required="yes"> 
        <cfargument name="in03" type="RemoteUser" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="setNewProjectAvatar" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="String" required="yes"> 
        <cfargument name="in04" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="setProjectAvatar" access="public" returntype="void" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="long" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateGroup" access="public" returntype="RemoteGroup" output="false">
    	<cfargument name="in02" type="RemoteGroup" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateIssue" access="public" returntype="RemoteIssue" output="false">
        <cfargument name="in02" type="String" required="yes"> 
        <cfargument name="in03" type="RemoteFieldValue[]" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateProject" access="public" returntype="RemoteProject" output="false">
    	<cfargument name="in02" type="RemoteProject" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateProjectRole" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="RemoteProjectRole" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateWorklogAndAutoAdjustRemainingEstimate" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="RemoteWorklog" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateWorklogAndRetainRemainingEstimate" access="public" returntype="void" output="false">
    	<cfargument name="in02" type="RemoteWorklog" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
    
    
    
    <cffunction name="updateWorklogWithNewRemainingEstimate" access="public" returntype="void" output="false">
        <cfargument name="in02" type="RemoteWorklog" required="yes"> 
        <cfargument name="in03" type="String" required="yes">
        
        <cfthrow message="Method not implimented yet.">
    
    </cffunction>
	
	
	<cffunction name="getEstimatedTimesToCompletionDefinition" access="public" returntype="array">
		
		<cfscript>
			var completionTimeArray = arraynew(2);
				completionTimeArray[1][1] = "m";
				completionTimeArray[1][2] = "Minutes";
				completionTimeArray[2][1] = "h";
				completionTimeArray[2][2] = "Hours";
				completionTimeArray[3][1] = "d";
				completionTimeArray[3][2] = "Days";
				completionTimeArray[4][1] = "w";
				completionTimeArray[4][2] = "Weeks";
				return completionTimeArray;
        </cfscript>

		
	</cffunction>	
	
	

</cfcomponent>
