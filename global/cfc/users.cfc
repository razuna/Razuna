<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent extends="extQueryCaching">

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("users")>

<!--- DO A QUICKSEARCH --->
<cffunction name="quicksearch">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<!--- function body --->
	<cfquery datasource="#application.razuna.datasource#" name="localquery">
		SELECT u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_company, u.user_active, count(*)<cfif application.razuna.thedatabase EQ "oracle"> over()</cfif> total,
		(
		SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>min(ct_g_u_grp_id)
		FROM ct_groups_users
		WHERE ct_g_u_user_id = u.user_id
		<cfif application.razuna.thedatabase EQ "oracle">
			AND ROWNUM = 1
		<cfelseif application.razuna.thedatabase EQ "db2">
			FETCH FIRST 1 ROWS ONLY
		<cfelseif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
			LIMIT 1
		</cfif>
		) AS ct_g_u_grp_id
		FROM ct_users_hosts ct, users u
		WHERE ct.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- user not "admin"
		AND u.user_login_name <> <cfqueryparam cfsqltype="cf_sql_varchar" value="admin"> --->
		AND ct.ct_u_h_user_id = u.user_id
		<cfif arguments.thestruct.user_email IS NOT "">
			AND lower(u.user_email) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_email)#%">
		</cfif>
		<cfif arguments.thestruct.user_login_name IS NOT "">
			AND
			(
			lower(u.user_login_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			OR
			lower(u.user_first_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			OR
			lower(u.user_last_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			)
		</cfif>
		<cfif arguments.thestruct.user_company IS NOT "">
			AND lower(u.user_company) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_company)#%">
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"dam")>
			AND lower(u.user_in_dam) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		</cfif>
		GROUP BY u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_active, u.user_company
		ORDER BY u.user_first_name, u.user_last_name
	</cfquery>
	<!--- If we come from DAM we don't show System Admins --->
	<cfif structkeyexists(arguments.thestruct,"dam")>
		<cfquery dbtype="query" name="localquery">
		SELECT *
		FROM localquery
		WHERE ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
	</cfif>
	<cfreturn localquery>
</cffunction>

<!--- Check for existing --->
<cffunction name="check" output="true" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<cfset var qry = "">
	<!--- function body --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT u.user_id
	FROM ct_users_hosts ct, users u
	WHERE ct.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND ct.ct_u_h_user_id = u.user_id
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	<cfif structkeyexists(arguments.thestruct,"user_login_name")>
		AND lower(u.user_login_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.user_login_name)#">
	<cfelseif structkeyexists(arguments.thestruct,"user_email")>
		AND lower(u.user_email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.user_email)#">
	</cfif>
	</cfquery>
	<!--- Return --->
	<cfif qry.recordcount EQ 0>
		<cfoutput>#SerializeJSON(true)#</cfoutput>  
	<cfelse>
		<cfoutput>#SerializeJSON(false)#</cfoutput>  
	</cfif>
</cffunction>

<!--- Get all users --->
<cffunction name="getall">
	<cfargument name="thestruct" type="Struct" required="false">
	<!--- Params --->
	<cfset var localquery = 0>
	<cfset var countquery = 0>
	<cfparam name="arguments.thestruct" default="#structnew()#">
	<!--- Get cachetoken --->
	<cfset variables.cachetoken = getcachetoken("users")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="localquery" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallusers */ u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_active, u.user_company, 
	0 AS thetotal, u.user_pass, (SELECT count(1) FROM users uu, ct_groups_users cg WHERE cg.ct_g_u_user_id = uu.user_id AND cg.ct_g_u_grp_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="1"> AND uu.user_id <>'1') numsysadmin,
		<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
			(
				SELECT GROUP_CONCAT(DISTINCT ct_g_u_grp_id ORDER BY ct_g_u_grp_id SEPARATOR ',') AS grpid
				FROM ct_groups_users
				WHERE ct_g_u_user_id = u.user_id
			) AS ct_g_u_grp_id
		<cfelseif application.razuna.thedatabase EQ "mssql">
			STUFF(
				(
					SELECT ', ' + ct_g_u_grp_id
					FROM ct_groups_users
					WHERE ct_g_u_user_id = u.user_id
		          	FOR XML PATH ('')
	          	)
	          	, 1, 1, ''
			) AS ct_g_u_grp_id
		<cfelseif application.razuna.thedatabase EQ "oracle">
			(
				SELECT wmsys.wm_concat(ct_g_u_grp_id) AS grpid
				FROM ct_groups_users
				WHERE ct_g_u_user_id = u.user_id
			) AS ct_g_u_grp_id
		</cfif>
	FROM ct_users_hosts uh, users u
	WHERE (
		uh.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		AND uh.ct_u_h_user_id = u.user_id
		)
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
	GROUP BY user_id, user_login_name, user_first_name, user_last_name, user_email, user_active, user_company, user_pass
	</cfquery>
	<!--- If we come from DAM we don't show System Admins --->
	<cfif structkeyexists(arguments.thestruct,"dam")>
		<cfquery dbtype="query" name="localquery">
		SELECT *, <cfif isdefined("arguments.thestruct.sortby")>'yes'<cfelse>'no'</cfif> sorted, <cfif isdefined("arguments.thestruct.sortby")>'#arguments.thestruct.sortby#'<cfelse>''</cfif>sortby
		FROM localquery
		WHERE  ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		AND ct_g_u_grp_id NOT LIKE '1,%'
		<cfif isdefined("arguments.thestruct.sortby")>
			ORDER  BY #arguments.thestruct.sortby# #arguments.thestruct.sortorder#
		<cfelse>
			ORDER  BY  user_login_name asc
		</cfif>
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn localquery>
</cffunction>

<!--- Get Details from this User --->
<cffunction name="details">
	<cfargument name="thestruct" type="Struct">
	<cfset variables.cachetoken = getcachetoken("users")>
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT/* #variables.cachetoken#detailsusers */ user_id, user_login_name, user_email, user_pass, 
	user_first_name, user_last_name, user_in_admin, user_create_date, user_active, user_company, user_phone, 
	user_mobile, user_fax, user_in_dam, user_salutation, user_expiry_date, user_search_selection
	FROM users u
	WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- GET EMAIL FROM THIS USER --->
<cffunction name="user_email">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#user_emailuser */ user_email
	FROM users
	WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
	</cfquery>
	<cfreturn qry.user_email>
</cffunction>

<!--- Get hosts of this user --->
<cffunction name="userhosts">
	<cfargument name="thestruct" type="Struct">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#userhosts */ h.host_id, h.host_name, h.host_db_prefix, h.host_shard_group, h.host_path
	FROM ct_users_hosts ct, hosts h
	WHERE ct.ct_u_h_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	AND ct.ct_u_h_host_id = h.host_id
	</cfquery>
	<cfreturn qry>
</cffunction>
<!--- Check the Email already exist --->
<cffunction name="check_email">
	<cfargument name="email" type="string" required="true" >
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT u.user_email, u.user_login_name
		FROM users u, ct_users_hosts ct
		WHERE lower(u.user_email) = <cfqueryparam value="#lcase(arguments.email)#" cfsqltype="cf_sql_varchar">
		AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		AND ct.ct_u_h_user_id = u.user_id
	</cfquery>
	<cfreturn qry>
</cffunction>
<!--- Add AD Server --->
<cffunction name="ad_server_user">
	<cfargument name="thestruct" type="Struct">
	<cfif isdefined("arguments.thestruct.ad_users")>
		<cfloop list="#arguments.thestruct.ad_users#" index="i" delimiters="," >
			<cfset arguments.thestruct.user_first_name = evaluate("arguments.thestruct.user_first_name_#i#")>
			<cfset arguments.thestruct.user_last_name = evaluate("arguments.thestruct.user_last_name_#i#")>
			<cfset arguments.thestruct.intrauser = "T">
			<cfset arguments.thestruct.user_active = "T">
			<cfset arguments.thestruct.user_pass = "">
			<cfset arguments.thestruct.hostid = session.hostid>
			<cfset arguments.thestruct.user_login_name = evaluate("arguments.thestruct.user_login_name_#i#")>
			<cfset arguments.thestruct.user_email = evaluate("arguments.thestruct.user_email_#i#")>
			<cfset arguments.thestruct.user_company = evaluate("arguments.thestruct.user_company_#i#")>
			<cfset arguments.thestruct.user_street = evaluate("arguments.thestruct.user_street_#i#")>
			<cfset arguments.thestruct.user_zip = evaluate("arguments.thestruct.user_zip_#i#")>
			<cfset arguments.thestruct.user_city = evaluate("arguments.thestruct.user_city_#i#")>
			<cfset arguments.thestruct.user_country = evaluate("arguments.thestruct.user_country_#i#")>
			<cfset arguments.thestruct.user_phone = evaluate("arguments.thestruct.user_phone_#i#")>
			<cfset arguments.thestruct.user_phone_2 = evaluate("arguments.thestruct.user_phone_2_#i#")>
			<cfset arguments.thestruct.user_mobile = evaluate("arguments.thestruct.user_mobile_#i#")>
			<cfset arguments.thestruct.user_fax = evaluate("arguments.thestruct.user_fax_#i#")>
			<cfif arguments.thestruct.user_login_name NEQ '' OR arguments.thestruct.user_email NEQ ''> 
				<cfinvoke method="add"  thestruct="#arguments.thestruct#">
			</cfif>
		</cfloop> 
	</cfif>
</cffunction>

<!--- Add user --->
<cffunction name="add">
	<cfargument name="thestruct" type="Struct">
	<!--- Params --->
	<cfparam default="F" name="arguments.thestruct.user_active">
	<cfparam default="F" name="arguments.thestruct.adminuser">
	<cfparam default="F" name="arguments.thestruct.intrauser">
	<cfparam default="F" name="arguments.thestruct.vpuser">
	<cfparam default="" name="arguments.thestruct.user_company">
	<cfparam default="" name="arguments.thestruct.user_phone">
	<cfparam default="" name="arguments.thestruct.user_mobile">
	<cfparam default="" name="arguments.thestruct.user_fax">
	<cfparam default="" name="arguments.thestruct.user_salutation">
	<cfparam default="false" name="arguments.thestruct.emailinfo">
	<cfparam default="" name="arguments.thestruct.user_search_selection">
	<!--- Check that there is no user already with the same email address --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_sameuser">
	SELECT u.user_email, u.user_login_name
	FROM users u, ct_users_hosts ct
	WHERE (
		lower(u.user_email) = <cfqueryparam value="#lcase(arguments.thestruct.user_email)#" cfsqltype="cf_sql_varchar">
		OR lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.thestruct.user_login_name)#" cfsqltype="cf_sql_varchar">
		)
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	</cfquery>
	<!--- Not the same user thus go on --->
	<cfif qry_sameuser.RecordCount EQ 0>
		<cfset newid = 0>
		<!--- Check the AD Users --->
		<cfif structKeyExists(arguments.thestruct,'user_pass') AND arguments.thestruct.user_pass NEQ ''>
			<!--- Hash Password --->
			<cfset thepass = hash(arguments.thestruct.user_pass, "MD5", "UTF-8")>
		</cfif>
		<!--- Insert the User into the DB --->
		<cfset newid = createuuid()>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO users
		(user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin,
		user_create_date, user_active, user_company, user_phone, user_mobile, user_fax, user_in_dam, user_salutation, user_in_vp, user_search_selection
		<cfif StructKeyExists(arguments.thestruct,"user_expirydate") AND isdate(arguments.thestruct.user_expirydate)>
			, user_expiry_date
		</cfif>
		)
		VALUES(
		<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.user_login_name#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_email#" cfsqltype="cf_sql_varchar">,
		<cfif structKeyExists(arguments.thestruct,'user_pass') AND arguments.thestruct.user_pass NEQ ''>
			<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">,
		<cfelse>
			<cfqueryparam value="" cfsqltype="cf_sql_varchar">,
		</cfif>
		<cfqueryparam value="#arguments.thestruct.user_first_name#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_last_name#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.adminuser#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#arguments.thestruct.user_active#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_company#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_phone#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_mobile#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_fax#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.intrauser#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_salutation#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.vpuser#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.user_search_selection#" cfsqltype="cf_sql_varchar">
		<cfif StructKeyExists(arguments.thestruct,"user_expirydate") AND isdate(arguments.thestruct.user_expirydate)>,<cfqueryparam value="#arguments.thestruct.user_expirydate#" cfsqltype="cf_sql_date"></cfif>
		)
		</cfquery>
	
		<!--- Insert the user to the user host cross table --->
		<cfloop delimiters="," index="thehostid" list="#arguments.thestruct.hostid#">
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO ct_users_hosts
			(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#thehostid#" cfsqltype="cf_sql_integer">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfloop>
		<!--- Add AD user's group --->
		<cfif structKeyExists(arguments.thestruct,'grp_id_assigneds') AND arguments.thestruct.grp_id_assigneds NEQ ''>
			<cfset arguments.thestruct.newid = newid />
			<cfinvoke component="groups_users" method="insertBulk" thestruct="#arguments.thestruct#">
		</cfif>
		<!--- Log --->
		<cfif structkeyexists(arguments.thestruct,"dam")>
			<cfset logsection = "DAM">
		<cfelse>
			<cfset logsection = "Admin">
		</cfif>
		<cfinvoke component="defaults" method="trans" transid="added" returnvariable="added" />
		<cfset log_users(theuserid=newid,logaction='Add',logsection='#logsection#',logdesc='#added#: UserID: #newid# eMail: #arguments.thestruct.user_email# First Name: #arguments.thestruct.user_first_name# Last Name: #arguments.thestruct.user_last_name#')>
		<!--- Send email to user --->
		<cfif arguments.thestruct.emailinfo>
			<cfinvoke method="emailinfo" user_id="#newid#" userpass="#arguments.thestruct.user_pass#" >
		</cfif>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("users")>
	<cfelse>
		<cfset newid = 0>
	</cfif>
	<!--- Return --->
	<cfreturn newid>
</cffunction>

<!--- Delete user --->
<cffunction name="delete">
	<cfargument name="thestruct" type="Struct">
	<!--- remove all cross-table entries first -------------------------------------------- --->
	<!--- Remove from the host table --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM ct_users_hosts
	WHERE ct_u_h_user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Remove Intra/extranet carts  --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#cart
	WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Remove user comments  --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM users_comments
	WHERE user_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- att ct-entries removed, now remove the record itself -------------------------------------------- --->
	<!--- Get detail of user first --->
	<cfset arguments.thestruct.user_id = arguments.thestruct.id>
	<cfinvoke method="details" thestruct="#arguments.thestruct#" returnvariable="theuser">
	<!--- Log --->
	<cfif NOT structkeyexists(arguments.thestruct,("logsection"))>
		<cfset arguments.thestruct.logsection = "admin">
	</cfif>
	<cfinvoke component="defaults" method="trans" transid="deleted" returnvariable="deleted" />
	<cfset log_users(theuserid=arguments.thestruct.id,logaction='Delete',logsection='#arguments.thestruct.logsection#',logdesc='#deleted#: UserID: #arguments.thestruct.id# eMail: #theuser.user_email# First Name: #theuser.user_first_name# Last Name: #theuser.user_last_name#')>
	<!--- Remove from the User Table --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM users
	WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Delete social accounts --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#users_accounts
	WHERE user_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Delete from folder_subscribe --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#folder_subscribe
	WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("users")>
	<cfreturn />
</cffunction>

<!--- Update user --->
<cffunction name="update">
	<cfargument name="thestruct" type="Struct">
	<cfparam default="F" name="arguments.thestruct.user_active">
	<cfparam default="F" name="arguments.thestruct.adminuser">
	<cfparam default="F" name="arguments.thestruct.intrauser">
	<cfparam default="false" name="arguments.thestruct.emailinfo">
	<cfparam default="" name="arguments.thestruct.user_pass">
	<cfparam default="" name="arguments.thestruct.user_search_selection">
	<!--- Var --->
	<cfset var is_sysadmin = false>
	
	<!--- Check that there is no user already with the same email address. Since this is the detail we already have a user with the same email address so we exclude this user from the search --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_sameuser">
	SELECT u.user_email, u.user_id
	FROM users u, ct_users_hosts ct
	WHERE lower(u.user_email) = <cfqueryparam value="#lcase(arguments.thestruct.user_email)#" cfsqltype="cf_sql_varchar">
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- There is no user with the same name thus continue --->
	<cfif qry_sameuser.RecordCount EQ 0>
		<!--- First remove the admin user value --->
		<cfif NOT structkeyexists(arguments.thestruct,"dam")>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE users
			SET 
			user_in_admin = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
			user_in_dam = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
			WHERE user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		<!--- Hash Password --->
		<cfif structKeyExists(arguments.thestruct,"user_pass")>
			<cfset thepass = hash(arguments.thestruct.user_pass, "MD5", "UTF-8")>
		</cfif>
		<!--- Check to see if user is systemadmin --->
		<cfinvoke component="groups_users" method="getUsersOfGroup" grp_id="1" returnvariable="qry_group" />
		<!--- Check if user is in list --->
		<cfset var sysadminfound = listfind(valueList(qry_group.user_id), arguments.thestruct.user_id, ",")>
		<!--- Set sysadmin --->
		<cfif sysadminfound GT 0>
			<cfset var is_sysadmin = true>
		</cfif>
		<!--- Update the User in the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET
		user_login_name=<cfqueryparam value="#arguments.thestruct.user_login_name#" cfsqltype="cf_sql_varchar">,
		user_email=<cfqueryparam value="#arguments.thestruct.user_email#" cfsqltype="cf_sql_varchar">
		<cfif structKeyExists(arguments.thestruct,"user_pass") AND arguments.thestruct.user_pass IS NOT "">
			, user_pass=<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">
		</cfif>,
		user_first_name=<cfqueryparam value="#arguments.thestruct.user_first_name#" cfsqltype="cf_sql_varchar">,
		user_last_name=<cfqueryparam value="#arguments.thestruct.user_last_name#" cfsqltype="cf_sql_varchar">,
		<!--- If we are coming from the DAM then exclude --->
		<cfif NOT structkeyexists(arguments.thestruct,"dam")>
			user_in_admin = <cfqueryparam value="#arguments.thestruct.adminuser#" cfsqltype="cf_sql_varchar">,
		</cfif>
		user_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		user_active = <cfqueryparam value="#arguments.thestruct.user_active#" cfsqltype="cf_sql_varchar">,
		USER_COMPANY = <cfqueryparam value="#arguments.thestruct.USER_COMPANY#" cfsqltype="cf_sql_varchar">,
		USER_PHONE = <cfqueryparam value="#arguments.thestruct.USER_PHONE#" cfsqltype="cf_sql_varchar">,
		USER_MOBILE = <cfqueryparam value="#arguments.thestruct.USER_MOBILE#" cfsqltype="cf_sql_varchar">,
		USER_FAX = <cfqueryparam value="#arguments.thestruct.USER_FAX#" cfsqltype="cf_sql_varchar">,
		user_in_dam = <cfqueryparam value="#arguments.thestruct.intrauser#" cfsqltype="cf_sql_varchar">,
		user_salutation = <cfqueryparam value="#arguments.thestruct.user_salutation#" cfsqltype="cf_sql_varchar">,
		user_search_selection = <cfqueryparam value="#arguments.thestruct.user_search_selection#" cfsqltype="cf_sql_varchar">
		<cfif StructKeyExists(arguments.thestruct,"user_expirydate") AND (isdate(arguments.thestruct.user_expirydate) or len(arguments.thestruct.user_expirydate) eq 0)>
			,user_expiry_date = <cfif len(arguments.thestruct.user_expirydate) eq 0>null<cfelse><cfqueryparam value="#arguments.thestruct.user_expirydate#" cfsqltype="cf_sql_date"></cfif>
		</cfif>
		WHERE user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Insert the user to the user host cross table --->
		<!--- First remove all value for this user --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_users_hosts
		WHERE ct_u_h_user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
		<!---If coming from DAM admin then do not delete all tenants but just the one associated with the DAM --->
		<cfif isDefined("arguments.thestruct.dam") AND arguments.thestruct.dam EQ "t">
			AND ct_u_h_host_id  IN (<cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		</cfif>
		</cfquery>
		<!--- if not sysadmin simply get select hostids --->
		<cfif !is_sysadmin>
			<!--- Insert the user to the user host cross table --->
			<cfloop delimiters="," index="thehostid" list="#arguments.thestruct.hostid#">
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO ct_users_hosts
				(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#thehostid#" cfsqltype="CF_SQL_NUMERIC">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfloop>
		<!--- we are a sysadmin --->
		<cfelse>
			<!--- Get all hosts --->
			<cfquery datasource="#application.razuna.datasource#" name="qry_hosts">
			SELECT host_id
			FROM hosts
			</cfquery>
			<cfloop delimiters="," index="thehostid" list="#valuelist(qry_hosts.host_id)#">
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO ct_users_hosts
				(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#thehostid#" cfsqltype="CF_SQL_NUMERIC">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfloop>
		</cfif>
		<!--- Send email to user --->
		<cfif arguments.thestruct.emailinfo>
			<cfinvoke method="emailinfo" user_id="#arguments.thestruct.user_id#" userpass="#arguments.thestruct.user_pass#" >
		</cfif>
		<!--- Log --->
		<cfif structkeyexists(arguments.thestruct,"dam")>
			<cfset logsection = "DAM">
		<cfelse>
			<cfset logsection = "Admin">
		</cfif>
		<cfinvoke component="defaults" method="trans" transid="updated" returnvariable="updated" />
		<cfset log_users(theuserid=arguments.thestruct.user_id,logsection='#logsection#',logaction='Update',logdesc='#updated#: UserID: #arguments.thestruct.user_id# eMail: #arguments.thestruct.user_email# First Name: #arguments.thestruct.user_first_name# Last Name: #arguments.thestruct.user_last_name#')>
	</cfif>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("users")>
	<cfreturn />
</cffunction>

<!--- Confirm user --->
<cffunction name="confirm">
	<cfargument name="thestruct" type="Struct">
	<cfparam default="0" name="arguments.thestruct.id">
	<cfset var qry = "">
	<!--- Check that there is a user with this id --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT u.user_id
	FROM users u, ct_users_hosts ct
	WHERE u.user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	</cfquery>
	<!--- There is a user thus continue --->
	<cfif qry.RecordCount EQ 1>
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET user_active = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">
		WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Set var --->
		<cfset arguments.thestruct.id = arguments.thestruct.id>
	<cfelse>
		<!--- Set var --->
		<cfset arguments.thestruct.id = 0>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.id>
</cffunction>

<!--- Get API key --->
<cffunction name="getapikey" output="false" returntype="string">
	<cfargument name="user_id" required="true">
	<cfargument name="reset" required="false" default="false">
	<!--- If we need to reset the key then save first --->
	<cfif arguments.reset EQ "true">
		<cfset key.user_api_key = createuuid("")>
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET user_api_key = <cfqueryparam value="#key.user_api_key#" cfsqltype="CF_SQL_VARCHAR">
		WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
	<!--- See if value is there --->
	<cfquery datasource="#application.razuna.datasource#" name="key">
	SELECT user_api_key
	FROM users
	WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- If key is empty --->
	<cfif key.user_api_key EQ "">
		<cfset key.user_api_key = createuuid("")>
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET user_api_key = <cfqueryparam value="#key.user_api_key#" cfsqltype="CF_SQL_VARCHAR">
		WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn key.user_api_key />
</cffunction>

<!--- Get social accounts for this user --->
<cffunction name="getsocial">
	<cfargument name="thestruct" type="Struct">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getsocial */ identifier, provider
	FROM #session.hostdbprefix#users_accounts
	WHERE user_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Save social accounts ---------------------------------------------------------------------->
<cffunction name="savesocial" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<!--- Delete all records with this ID in the DB --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#users_accounts
	WHERE user_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	</cfquery>
	<!--- Get the name and select fields --->
	<cfset var thefield = "">
	<cfset var theselect = "">
	<cfloop collection="#arguments.thestruct#" item="i">
		<cfif i CONTAINS "identifier_">
			<!--- Get values --->
			<cfset f = listfirst(i,"_")>
			<cfset fn = listlast(i,"_")>
			<cfset fg = f & "_" & fn>
			<cfset thefield = thefield & "," & fg>
		</cfif>
		<cfif i CONTAINS "provider_">
			<!--- Get values --->
			<cfset s = listfirst(i,"_")>
			<cfset sn = listlast(i,"_")>
			<cfset sg = s & "_" & sn>
			<cfset theselect = theselect & "," & sg>
		</cfif>
	</cfloop>
	<!--- loop over list amount and do insert and listgetat --->
	<cfloop from="1" to="#listlen(thefield)#" index="i">
		<cfset fi = listgetat(thefield, listfindnocase(thefield,"identifier_#i#"))>
		<cfset se = listgetat(theselect, listfindnocase(theselect,"provider_#i#"))>
		<cfset fi_value = arguments.thestruct["#fi#"]>
		<cfset se_value = arguments.thestruct["#se#"]>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#users_accounts
		(user_id_r, host_id, identifier, provider)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fi_value#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#se_value#">
		)
		</cfquery>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("users")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export users --->
<cffunction name="users_export" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>We are starting to export your data. Please wait. Once done, you can find the file to download at the bottom of this page!</strong><br /></cfoutput>
	<cfflush>
	<cfset var qry = "">
	<!--- Query users --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT u.user_id, u.user_login_name as login_name, u.user_first_name as first_name, u.user_last_name  as last_name , u.user_email as email, u.user_active as active, u.user_expiry_date
	FROM ct_users_hosts uh, users u LEFT JOIN ct_groups_users gu ON gu.ct_g_u_user_id = u.user_id
	WHERE (
		uh.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		AND uh.ct_u_h_user_id = u.user_id
		)
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
	AND gu.ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '1'
	GROUP BY u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_active,u.user_expiry_date
	</cfquery>
	<!--- Add column to qry --->
	<cfset var MyArray = ArrayNew(1)>
	<cfset MyArray[1] = "">
	<cfset QueryAddcolumn(qry, "groupid", "varchar", MyArray)>
	<cfset QueryAddcolumn(qry, "password", "varchar", MyArray)>
	<cfinvoke component="defaults" method="getdateformat" returnvariable="thedateformat" dsn="#application.razuna.datasource#">
	<!--- Loop over records and update each record with the groupid --->
	<cfloop query="qry">
		<!--- Get groupid --->
		<cfquery datasource="#application.razuna.datasource#" name="qrygrp">
		SELECT ct_g_u_grp_id
		FROM ct_groups_users
		WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#user_id#">
		</cfquery>
		<!--- Now update record --->
		<cfset QuerySetcell(qry, "groupid", valuelist(qrygrp.ct_g_u_grp_id), currentrow )>
		<cfset QuerySetcell(qry, "user_expiry_date", dateformat(qry.user_expiry_date,'#thedateformat#'), currentrow )>
	</cfloop>
	<!--- Remove the user_id column --->
	<cfset QueryDeletecolumn( qry, "user_id" )>
	<!--- We got the query ready, continue export --->
	<!--- CVS --->
	<cfif arguments.thestruct.format EQ "csv">
		<cfinvoke method="export_csv" thepath="#arguments.thestruct.thepath#" theqry="#qry#" />
	<!--- XLS --->
	<cfelse>
		<!--- Add custom fields to meta fields --->
		<cfinvoke method="export_xls" thepath="#arguments.thestruct.thepath#" theqry="#qry#" theformat="#arguments.thestruct.format#" />
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export CSV --->
<cffunction name="export_csv" output="false">
	<cfargument name="thepath" type="string">
	<cfargument name="theqry" type="query">
	<!--- Create CSV --->
	<cfset var csv = csvwrite(arguments.theqry)>
	<!--- Check the directory already exists --->
	<cfif ! directoryExists("#arguments.thepath#/outgoing")>
		<!--- create directory --->
		<cfdirectory action="create" directory="#arguments.thepath#/outgoing" mode="777">
	</cfif>
	<!--- Write file to file system --->
	<cffile action="write" file="#arguments.thepath#/outgoing/razuna-users-export-#session.hostid#-#session.theuserid#.csv" output="#csv#" charset="utf-8" nameconflict="overwrite">
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="downloadable_file" returnvariable="downloadable_file" />
	<cfoutput><p><a href="outgoing/razuna-users-export-#session.hostid#-#session.theuserid#.csv"><strong style="color:green;">#downloadable_file#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Call function to remove older files --->
	<cfinvoke method="remove_files" thepath="#arguments.thepath#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export XLS --->
<cffunction name="export_xls" output="true">
	<cfargument name="thepath" type="string">
	<cfargument name="theqry" type="query">
	<cfargument name="theformat" type="string">
	<!--- Create Spreadsheet --->
	<cfif arguments.theformat EQ "xls">
		<cfset var sxls = spreadsheetnew()>
	<cfelseif arguments.theformat EQ "xlsx">
		<cfset var sxls = spreadsheetnew(true)>
	</cfif>

	<!--- Create header row --->
	<cfset var therows = "login_name,first_name,last_name,email,active, user_expiry_date,groupid,password">
	<cfset SpreadsheetAddrow(sxls, therows, 1)>
	<cfset SpreadsheetFormatRow(sxls, {bold=TRUE, alignment="left"}, 1)>

	<cfset SpreadsheetColumnfittosize(sxls, "1-#len(therows)#")>
	<cfset SpreadsheetSetcolumnwidth(sxls, 1, 5000)>
	<cfset SpreadsheetSetcolumnwidth(sxls, 2, 5000)>
	<cfset SpreadsheetSetcolumnwidth(sxls, 3, 5000)>
	<cfset SpreadsheetSetcolumnwidth(sxls, 4, 10000)>
	<cfset SpreadsheetSetcolumnwidth(sxls, 5, 3000)>
	<cfset SpreadsheetSetcolumnwidth(sxls, 6, 10000)>
	<!--- Add orders from query --->
	<cfset SpreadsheetAddRows(sxls, arguments.theqry, 2)> 
	<cfset SpreadsheetFormatrow(sxls, {textwrap=false, alignment="vertical_top"}, 2)>
	<cfset SpreadsheetFormatcolumn(sxls, {bold=true}, "1-6")>
	<!--- Check the directory already exists --->
	<cfif ! directoryExists("#arguments.thepath#/outgoing")>
		<!--- create directory --->
		<cfdirectory action="create" directory="#arguments.thepath#/outgoing" mode="777">
	</cfif>

	<!--- Write file to file system --->
	<cfset SpreadsheetWrite(sxls,"#arguments.thepath#/outgoing/razuna-users-export-#session.hostid#-#session.theuserid#.#arguments.theformat#",true)>
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="downloadable_file" returnvariable="downloadable_file" />
	<cfoutput><p><a href="outgoing/razuna-users-export-#session.hostid#-#session.theuserid#.#arguments.theformat#"><strong style="color:green;">#downloadable_file#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Call function to remove older files --->
	<cfinvoke method="remove_files" thepath="#arguments.thepath#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Remove old export files --->
<cffunction name="remove_files" output="no">
	<cfargument name="thepath" type="string">
	<cftry>
		<!--- Set time for remove --->
		<cfset removetime = DateAdd("h", -6, "#now()#")>
		<!--- Now check directory on the hard drive. This will fix issue with files that were not successfully uploaded thus missing in the temp db --->
		<cfdirectory action="list" directory="#arguments.thepath#/outgoing" name="thefiles" type="file">
		<!--- Loop over dirs --->
		<cfloop query="thefiles">
			<cfif datelastmodified LT removetime AND FileExists("#arguments.thepath#/outgoing/#name#")>
				<cffile action="delete" file="#arguments.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function users.remove_files">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
</cffunction>

<!--- Do the Import ---------------------------------------------------------------------->
<cffunction name="users_import" output="false">
	<cfargument name="thestruct" type="struct">
	<cfif NOT fileexists("#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#")>
		<cfoutput><h3>The file is not readable. Please upload it again!</h3></cfoutput>
		<cfabort>
	</cfif>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("users")>
	<!--- Feedback --->
	<cfoutput><strong>Starting the import</strong><br><br></cfoutput>
	<cfflush>
	<!--- CSV and XML --->
	<cfif arguments.thestruct.file_format EQ "csv">
		<!--- Read the file --->
		<cffile action="read" file="#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#" charset="utf-8" variable="thefile" />
		<!--- Read CSV --->
		<cfset var theimport = csvread(string=thefile,headerline=true)>
	<!--- XLS and XLSX --->
	<cfelse>
		<!--- Read the file --->
		<cfset var thexls = SpreadsheetRead("#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#")>
		<cfset var theimport = SpreadsheetQueryread(spreadsheet=thexls,sheet=0,headerrow=1)>
	</cfif>
	<!--- Feedback --->
	<cfoutput>We could read your file. We assume the first row has headers. Continuing...<br><br></cfoutput>
	<cfflush>
	<cfset var qry = "">
	<!--- Do the import. Start loop --->
	<cfloop query="theimport">
		<!--- check for same record according to email --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT u.user_email
		FROM users u, ct_users_hosts ct
		WHERE lower(user_email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(email)#">
		AND u.user_id = ct.ct_u_h_user_id
		AND ct.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If record is found simply check if password column is empty. If so, skip record else update password --->
		<cfif qry.recordcount EQ 1>
			<!--- check for password column --->
			<cfif password NEQ "">
				<!--- Feedback --->
				<cfoutput>The user with the eMail address "#email#" exists. But as requested we are changing his password now.<br></cfoutput>
				<cfflush>
				<!--- Grab password and hash it --->
				<cfset thepass = hash(password, "MD5", "UTF-8")>
				<!--- Update DB --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE users
				SET user_pass = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thepass#">
				WHERE lower(user_email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(email)#">
				</cfquery>
			<cfelse>
				<!--- Feedback --->
				<cfoutput>The user with the eMail address "#email#" exists. Skipping record update.<br></cfoutput>
				<cfflush>
			</cfif>
		<!--- Users does not exists, append to DB --->
		<cfelseif email NEQ "">
			<!--- Feedback --->
			<cfoutput>Found new user with the eMail address "#email#". Adding record now.<br></cfoutput>
			<cfflush>
			<cftry>
				<!--- Create structure for function --->
				<cfset arguments.thestruct.user_login_name = login_name>
				<cfset arguments.thestruct.user_email = email>
				<cfset arguments.thestruct.user_pass = password>
				<cfset arguments.thestruct.user_first_name = first_name>
				<cfset arguments.thestruct.user_last_name = last_name>
				<cfset arguments.thestruct.user_active = active>
				<cfset arguments.thestruct.hostid = session.hostid>
				<cfset arguments.thestruct.intrauser = "T">
				<!--- Call function --->
				<cfinvoke method="add" thestruct="#arguments.thestruct#" returnvariable="userid" />
				<!--- Add to groups --->
				<cfif groupid NEQ "">
					<cfloop list="#groupid#" delimiters="," index="i">
						<cftry>
							<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO	ct_groups_users
							(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#userid#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
							)
							</cfquery>
							<cfcatch type="database">
								<!--- Feedback --->
								<cfoutput><span style="color:red;">The groupid (#i#) does not exists.</span><br></cfoutput>
								<cfflush>
							</cfcatch>
						</cftry>
					</cfloop>
				</cfif>
				<cfcatch type="any">
					<!--- Feedback --->
					<cfoutput><span style="color:red;">Something's wrong here: #cfcatch.detail# - #cfcatch.message#</span><br></cfoutput>
					<cfset cfcatch.custom_message = "Error in function users.users_import">
					<cfset errobj.logerrors(cfcatch,false)/>
					<cfflush>
				</cfcatch>
			</cftry>
		</cfif>
	</cfloop>
	<!--- Feedback --->
	<cfoutput>Cleaning up...<br><br></cfoutput>
	<cfflush>
	<!--- Remove the file --->
	<cffile action="delete" file="#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#" />
	<!--- Feedback --->
	<cfoutput><strong style="color:green;">Your users have been successully imported!</strong><br><br></cfoutput>
	<cfflush>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("users")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get all users who are active --->
<cffunction name="getallactive">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallactive */ u.user_email, u.user_first_name, u.user_last_name
	FROM users u, ct_users_hosts uh
	WHERE (
		uh.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		AND uh.ct_u_h_user_id = u.user_id
		)
	WHERE lower(u.user_active) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="t">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Get all users who are active --->
<cffunction name="checkapikey" output="true">
	<cfargument name="api_key" required="true" type="string">
	<!--- Set application variables. Needed for the checkdb method in API --->
	<cfset application.razuna.api.dsn = application.razuna.datasource>
	<cfset application.razuna.api.setid = 1>
	<cfset application.razuna.api.storage = application.razuna.storage>
	<cfset application.razuna.api.thedatabase = application.razuna.thedatabase>
	<!--- Call internal API to check for the API key --->
	<cfinvoke component="global.api2.authentication" method="checkdb" api_key="#arguments.api_key#" returnvariable="checklogin">
	<cfif !checklogin>
		<cfoutput>Sorry, no valid API key!</cfoutput>
		<cfabort>
	</cfif>
	<cfreturn checklogin />
</cffunction>

<!--- Send email to user --->
<cffunction name="emailinfo" output="true">
	<cfargument name="user_id" required="true" type="string">
	<cfargument name="userpass" required="true" type="string">
	<cfset var prefs="">
	<!--- Get the record --->
	<cfinvoke method="details" thestruct="#arguments#" returnvariable="qry_user" />
	<!--- Get email settings --->
	<cfinvoke component="settings" method="getsettingsfromdam" returnvariable="prefs">
	<cfset var email_body = prefs. set2_new_user_email_body>
	<cfset var email_subject = prefs. set2_new_user_email_sub>
	<cfif email_subject EQ ''>
		<cfset email_subject = 'Welcome!'>
	</cfif>
	<cfif email_body EQ ''>
		<cfset email_body = '<p>Dear User,<br />Your Razuna account login information are as follows:<br />Username: $username$<br />Password: $password$</p>'>
	</cfif>
	<!--- Insert username and password into body --->
	<cfset email_body =replacenocase(email_body,"$username$", "#qry_user.user_login_name#","ONE")>
	<cfif arguments.userpass NEQ "">
		<cfset email_body =replacenocase(email_body,"$password$", "#arguments.userpass#","ONE")>
	<cfelse>
		<cfset email_body =replacenocase(email_body,"$password$", "_hidden_","ONE")>
	</cfif>
	<!--- Send the email --->
	<cfinvoke component="email" method="send_email" to="#qry_user.user_email#" subject="#email_subject#" themessage="#email_body#">
	<cfreturn />
</cffunction>

<!--- Delete selected users --->
<cffunction name="delete_selects" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<cfparam name="arguments.thestruct.theuserid" default="">
	<!--- If this is for ALL users --->
	<cfif arguments.thestruct.allusers>
		<!--- Query all users --->
		<cfinvoke method="getall" thestruct="#arguments.thestruct#" returnvariable="qry_users" />
		<cfset arguments.thestruct.numsysadmin = qry_users.numsysadmin>
		<!--- Now filter out all users in admin and sysadmin group --->
		<cfquery dbtype="query" name="qry_users">
		SELECT *
		FROM qry_users
		WHERE ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="2">
		AND ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
		<!--- Put all the userids into a list --->
		<cfset arguments.thestruct.theuserid = valueList(qry_users.user_id,",")>
	</cfif>
	<!--- Loop over the userid --->
	<cfloop list="#arguments.thestruct.theuserid#" delimiters="," index="i">
		<cfset var qry = "">
		<!--- Check if only 1 sysadmin present--->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT *
		FROM users u, ct_groups_users cg 
		WHERE  cg.ct_g_u_user_id = u.user_id 
		AND cg.ct_g_u_user_id =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
		AND cg.ct_g_u_grp_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="1">
		AND (SELECT count(1) FROM users uu, ct_groups_users cgu WHERE cgu.ct_g_u_user_id = uu.user_id AND cgu.ct_g_u_grp_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="1"> AND uu.user_id <>'1')  = 1
		</cfquery>
		<!--- Do not delete if only 1 system admin is present --->
		<cfif qry.recordcount EQ 0>
			<!--- Delete user --->
			<cfset arguments.thestruct.id = i>
			<cfinvoke method="delete" thestruct="#arguments.thestruct#" />
			<!--- Delete in groups users --->
			<cfset arguments.thestruct.newid = i>
			<cfinvoke component="groups_users" method="deleteUser" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get User by ApiKey --->
<cffunction name="getUserbyApiKey">
	<cfargument name="api_key" type="string">
	<!--- Set param --->
	<cfset var qry = "">
	<!--- Get cache --->
	<cfset variables.cachetoken = getcachetoken("users")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	select /* #variables.cachetoken#getUserbyApiKey */ user_id, user_login_name, user_email ,user_first_name, user_last_name
	from users
	where user_api_key = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.api_key#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<cffunction name="send_emails" returntype="void" hint="Send welcome email to selected users">
	<cfargument name="thestruct" type="Struct">
	<cfparam name="arguments.thestruct.theuserid" default="">
	<!--- If this is for ALL users --->
	<cfif arguments.thestruct.allusers>
		<!--- Query all users --->
		<cfinvoke method="getall" thestruct="#arguments.thestruct#" returnvariable="qry_users" />
		<!--- Now filter out all users in admin group --->
		<cfquery dbtype="query" name="qry_users">
		SELECT *
		FROM qry_users
		WHERE ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="2">
		</cfquery>
		<!--- Put all the userids into a list --->
		<cfset arguments.thestruct.theuserid = valueList(qry_users.user_id,",")>
	</cfif>
	<!--- Loop over the userid --->
	<cfloop list="#arguments.thestruct.theuserid#" delimiters="," index="i">
		<!--- Send email to user --->
		<cfinvoke method="emailinfo" user_id="#i#" userpass="" >
	</cfloop>
</cffunction>

<!--- Get all the folders this user has access to based on the user id --->
<cffunction name="getAllFolderOfUser" returntype="string">
	<cfargument name="user_id" type="string">
	<cfargument name="host_id" type="numeric">
	<!--- Param --->
	<cfset var qry_groups = "">
	<cfset var qry_folders = "">
	<cfset var qry_folders_user = "">
	<cfset var result = "0">
	<!--- Get cachetoken --->
	<cfset var cache_user = getcachetoken("users")>
	<cfset var cache_folders = getcachetoken("folders")>
	<!--- Get groups of user --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_groups" cachedwithin="1" region="razcache">
	SELECT /* #cache_user#getAllFolderOfUser */ ct_g_u_grp_id
	FROM ct_groups_users 
	WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user_id#">
	</cfquery>
	<!--- Get all the folders for this group(s) --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_folders" cachedwithin="1" region="razcache">
	SELECT /* #cache_folders#getAllFolderOfUser2 */ folder_id_r AS folderid
	FROM #session.hostdbprefix#folders_groups 
	WHERE grp_id_r IN (
		<cfif qry_groups.recordcount EQ 0>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		<cfelse>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="0,#valuelist(qry_groups.ct_g_u_grp_id)#" list="true">
		</cfif>
	)
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.host_id#">
	</cfquery>
	<!--- Get all the folder the user owns --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_folders_user" cachedwithin="1" region="razcache">
	SELECT /* #cache_folders#getAllFolderOfUser3 */ folder_id AS folderid
	FROM #session.hostdbprefix#folders
	WHERE folder_owner = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.host_id#">
	</cfquery>
	<!--- Now UNION both queries --->
	<cfquery dbtype="query" name="qry_union">
	SELECT *
	FROM qry_folders
	UNION
	SELECT *
	FROM qry_folders_user
	</cfquery>
	<!--- We got the folders convert to a list --->
	<cfif qry_union.recordcount NEQ 0>
		<cfset var result = valuelist(qry_union.folderid)>
	</cfif>
	<!--- Return --->
	<cfreturn result />
</cffunction>

</cfcomponent>