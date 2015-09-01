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
<cfoutput>
	<form name="form_folder#attributes.theid#" action="#self#" method="post" id="form_folder#attributes.theid#" onsubmit="foldersubmit('#attributes.theid#','#attributes.isdetail#','<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">T<cfelse>F</cfif>');return false;">
	<input type="hidden" name="#theaction#" value="#xfa.submitfolderform#">
	<input type="hidden" name="theid" value="#attributes.theid#">
	<input type="hidden" name="level" value="#attributes.level#">
	<input type="hidden" name="rid" id="rid" value="#attributes.rid#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">
		<input type="hidden" name="coll_folder" value="T">
	</cfif>
	<div id="folder#attributes.theid#-#attributes.isdetail#" style="width:<cfif attributes.isdetail EQ "T">100%<cfelse>690px</cfif>;padding-bottom:60px;">
		<cfif attributes.isdetail NEQ "T" AND !application.razuna.isp AND attributes.iscol NEQ "T">
			<ul>
				<li><a href="##folder_new#attributes.theid#">#myFusebox.getApplicationData().defaults.trans("folder_new")#</a></li>
				<!--- Hide 'Link to Folder' for Amazon --->
				<cfif !application.razuna.isp AND application.razuna.storage NEQ 'amazon'>
					<li><a href="##folder_link#attributes.theid#">#myFusebox.getApplicationData().defaults.trans("link_folder_header")#</a></li>
				</cfif>
			</ul>
		</cfif>
		<div id="folder_new#attributes.theid#">
			<table border="0" cellpadding="0" cellspacing="0" class="grid">
				<cfloop query="qry_langs">
					<cfset thisid = lang_id>
					<!--- Folder Name --->
					<tr>
						<td valign="top" width="1%" nowrap="true" class="td2">
							#myFusebox.getApplicationData().defaults.trans("folder_name")#<cfif qry_langs.recordcount NEQ 1> (#lang_name#)</cfif>
						</td>
						<td>
							<cfif qry_folder.folder_name EQ "My Folder">
								<input type="hidden" name="folder_name" id="folder_name" value="#qry_folder.folder_name#">
								#qry_folder.folder_name#
							<cfelse>
								<input type="text" id="folder_name" name="folder_name_#thisid#" style="width:400px;" value="<cfloop query="qry_folder_name"><cfif thisid EQ lang_id_r>#folder_name#</cfif></cfloop>" <cfif qry_langs.recordcount EQ 1>onkeyup="samefoldernamecheck('#attributes.theid#');foldernamecheck_invalidchars('#attributes.theid#');"</cfif> autocomplete="off">
								<cfif qry_langs.recordcount EQ 1>
									<div id="samefoldername"></div>
									<div id="invalidchars"></div>
								</cfif>
							</cfif>
						</td>
					</tr>
					<!--- Description --->
					<tr>
						<td valign="top" width="1%" nowrap="true" class="td2">#myFusebox.getApplicationData().defaults.trans("description")#</td>
						<td width="100%" class="td2"><textarea name="folder_desc_#thisid#" class="text" style="width:400px;height:50px;"><cfloop query="qry_folder_desc"><cfif thisid EQ lang_id_r><cfif folder_desc NEQ "">#folder_desc#</cfif></cfif></cfloop></textarea></td>
					</tr>
				</cfloop>
				<!--- RAZ-2207 Check Group/Users Permissions --->
				<cfset flag = 0>
				<cfif  qry_label_set.set2_labels_users EQ ''>
					<cfset flag=1>
				<cfelse>
					<cfif qry_GroupsOfUser.recordcount NEQ 0>
					<cfloop list = '#valuelist(qry_GroupsOfUser.grp_id)#' index="i" >
						<cfif listfindnocase(qry_label_set.set2_labels_users,i,',') OR listfindnocase(qry_label_set.set2_labels_users,session.theuserid,',')>
							<cfset flag=1>
						</cfif>
					</cfloop>
					<cfelse>
						<cfif listfindnocase(qry_label_set.set2_labels_users,session.theuserid,',')>
							<cfset flag = 1>
						</cfif>	
					</cfif>	
				</cfif>
				<!--- Labels --->
				<cfif attributes.isdetail EQ "T">
					<cfif cs.tab_labels>
						<tr>
							<td valign="top">#myFusebox.getApplicationData().defaults.trans("labels")#</td>
							<td width="100%" colspan="5">
							<!--- RAZ-2898 : Show Advanced labels --->
							<cfif attributes.thelabelsqry.recordcount lte 200>
								<select data-placeholder="#myFusebox.getApplicationData().defaults.trans('choose_label')#" class="chzn-select" style="width:410px;" id="tags_folder" onchange="razaddlabels('tags_folder','#attributes.folder_id#','folder','#myFusebox.getApplicationData().defaults.trans("change_saved")#');" multiple="multiple">
									<option value=""></option>
									<cfloop query="attributes.thelabelsqry">
										<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
									</cfloop>
								</select>
								<cfif flag EQ 1 OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
									<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
								</cfif>
							<cfelse>
								<!--- Label text area --->
								<div style="width:450px;">
									<div id="select_lables_#attributes.folder_id#" class="labelContainer" style="float:left;width:400px;" >
										<cfloop query="attributes.thelabelsqry">
											<cfif ListFind(qry_labels,'#label_id#') NEQ 0>
											<div class='singleLabel' id="#label_id#">
												<span>#label_path#</span>
												<a class='labelRemove'  onclick="removeLabel('#attributes.folder_id#','folder', '#label_id#',this,'#myFusebox.getApplicationData().defaults.trans("change_saved")#')" >X</a>
											</div>
											</cfif>
										</cfloop>
									</div>
									<cfif qry_label_set.set2_labels_users EQ "t" OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
										<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false" style="float:left;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
									</cfif>
									<!--- Select label button --->
									<br /><br /><a onclick="showwindow('#myself#c.select_label_popup&file_id=#attributes.folder_id#&file_type=folder&closewin=2','Choose Labels',600,2);return false;" href="##"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("select_labels")#</button></a>
								</div>
							</cfif>
							</td>
						</tr>
					</cfif>
					<!--- Show folderid --->
					<tr>
						<td>ID</td>
						<td>#attributes.folder_id#</td>
					</tr>
					<!--- Show search selection --->
					<cfif cs.search_selection>
						<tr>
							<td>#myFusebox.getApplicationData().defaults.trans("folder_search_selection")#</td>
							<td><input type="checkbox" name="in_search_selection" value="true"<cfif qry_folder.in_search_selection> checked="checked"</cfif> /></td>
						</tr>
					</cfif>
				</cfif>
				<tr>
					<td colspan="2" class="list"></td>
				</tr>
				<tr>
					<td class="td2" valign="top"><strong>#myFusebox.getApplicationData().defaults.trans("permissions")#</strong></td>
					<td valign="top" class="td2" style="padding:0;margin:0;">
						<table width="420" cellpadding="0" cellspacing="0" border="0" class="grid">
							<tr>
								<th width="100%" colspan="2">#myFusebox.getApplicationData().defaults.trans("access_for")#</th>
								<th width="1%" nowrap align="center">#myFusebox.getApplicationData().defaults.trans("per_read")#</th>
								<th width="1%" nowrap align="center">#myFusebox.getApplicationData().defaults.trans("per_read_write")#</th>
								<th width="1%" nowrap align="center">#myFusebox.getApplicationData().defaults.trans("per_all")#</th>
							</tr>
							<tr class="list">
								<td width="1%" align="center" style="padding:4px;"><input type="checkbox" name="grp_0" value="0" <cfif qry_folder_groups_zero.grp_id_r EQ 0> checked</cfif> onclick="checkradio(0);"></td>
								<td width="100%" nowrap class="textbold" style="padding:4px;">#myFusebox.getApplicationData().defaults.trans("everybody")#</td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="R" name="per_0" id="per_0"<cfif (qry_folder_groups_zero.grp_permission EQ "R") OR (qry_folder_groups_zero.grp_permission EQ "")> checked</cfif>></td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="W" name="per_0"<cfif qry_folder_groups_zero.grp_permission EQ "W"> checked</cfif>></td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="X" name="per_0"<cfif qry_folder_groups_zero.grp_permission EQ "X"> checked</cfif>></td>
							</tr>
							<cfloop query="qry_groups">
								<cfset grpidnodash = replace(grp_id,"-","","all")>
								<tr class="list">
									<td width="1%" align="center" style="padding:4px;"><input type="checkbox" name="grp_#grp_id#" value="#grp_id#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id#> checked</cfif></cfloop> onclick="checkradio('#grpidnodash#');"></td>
									<td width="1%" nowrap style="padding:4px;">#grp_name#</td>
									<td align="center" style="padding:4px;"><input type="radio" value="R" name="per_#grpidnodash#" id="per_#grpidnodash#"<cfif attributes.isdetail EQ "T"><cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "R"> checked<cfelseif grp_id_r NEQ #qry_groups.grp_id#> checked</cfif></cfloop><cfelse> checked</cfif>></td>
									<td align="center" style="padding:4px;"><input type="radio" value="W" name="per_#grpidnodash#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "W"> checked</cfif></cfloop>></td>
									<td align="center" style="padding:4px;"><input type="radio" value="X" name="per_#grpidnodash#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "X"> checked</cfif></cfloop>></td>
								</tr>
							</cfloop>
							<cfif attributes.rid NEQ 0>
								<tr>
									<td colspan="5"><em>#myFusebox.getApplicationData().defaults.trans("subfolder_inherit")#</em></td>
								</tr>
							</cfif>
						</table>
					</td>
				</tr>
				<!--- Hide inherit permission for new folders --->
				<cfif attributes.isdetail EQ "T">
					<tr>
						<td></td>
						<td style="padding-bottom:7px;"><input type="checkbox" name="perm_inherit" value="T"> #myFusebox.getApplicationData().defaults.trans("group_inherit")#</td>
					</tr>
				</cfif>
			</table>
			<!--- This is the plugin section --->
			<cfif attributes.iscol EQ "F" AND attributes.folderaccess EQ "X">
				<cfif structKeyExists(pl,"pview")>
					<cfloop list="#pl.pview#" delimiters="," index="i">
						#evaluate(i)#
					</cfloop>
				</cfif>
			</cfif>
			<div style="clear:both;"></div>
			<div style="float:right;padding-top:10px;padding-right:10px;">
				<input type="submit" name="submit" id="foldersubmitbutton" value="<cfif attributes.isdetail EQ "T">#myFusebox.getApplicationData().defaults.trans("button_update")#<cfelse>#myFusebox.getApplicationData().defaults.trans("button_add")#</cfif>" class="button">
			</div>
		</div>
		<!--- Link to Folder --->
		<cfif attributes.isdetail NEQ "T" AND !application.razuna.isp AND attributes.iscol NEQ "T" AND application.razuna.storage NEQ 'amazon'>
			<div id="folder_link#attributes.theid#">
				<table border="0" cellpadding="0" cellspacing="0" class="grid" style="width:660px;">
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("link_folder_desc")#</td>
					</tr>
					<tr>
						<td class="td2"><hr></td>
					</tr>
					<tr>
						<td class="td2" width="1%" nowrap="true" style="padding-top:7px;"><strong>#myFusebox.getApplicationData().defaults.trans("link_folder_path_header")#</strong></td>
					</tr>
					<tr>
						<td class="td2" width="100%">
							<input name="link_path" id="link_path" type="text" style="width:450px;"> <a href="##" onclick="jschecklink();">#myFusebox.getApplicationData().defaults.trans("check_folder")#</a>
							<div id="foldercheck"></div>
						</td>
					</tr>
				</table>
				<div id="addlinkstatus" style="display:none;"></div>
				<div style="clear:both;"></div>
				<div style="float:right;padding-top:10px;padding-right:10px;">
					<input type="button" name="linkbutton" id="linkbutton" value="Establish link" class="button" onclick="foldersubmit('#attributes.theid#','#attributes.isdetail#','<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">T<cfelse>F</cfif>','false',true);return false;">
				</div>
			</div>
		</cfif>
		<!--- Buttons --->
		<div style="float:left;padding-top:10px;padding-bottom:10px;">
			<cfif attributes.isdetail EQ "T" AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR attributes.folderaccess EQ "X") AND NOT (qry_folder.folder_owner EQ session.theuserid AND qry_folder.folder_name EQ "my folder")>
				<input type="button" name="movefolder" value="#myFusebox.getApplicationData().defaults.trans("move_folder")#" class="button" onclick="showwindow('#myself#c.move_file&file_id=0&type=movefolder&thetype=folder&folder_id=#attributes.folder_id#&folder_level=#qry_folder.folder_level#&iscol=#qry_folder.folder_is_collection#','#myFusebox.getApplicationData().defaults.trans("move_folder")#',600,1);"> 
				<cfif qry_folder.folder_is_collection NEQ "T" AND application.razuna.storage NEQ 'amazon'>
					<input type="button" name="copyfolder" value="#myFusebox.getApplicationData().defaults.trans("copy_folder")#" class="button" onclick="showwindow('#myself#c.move_file&file_id=0&type=copyfolder&thetype=folder&folder_id=#attributes.folder_id#&folder_level=#qry_folder.folder_level#&iscol=#qry_folder.folder_is_collection#','#myFusebox.getApplicationData().defaults.trans("copy_folder")#',600,1);">
				</cfif>   
			</cfif>
			<cfif attributes.isdetail EQ "T">
				<cfif cs.show_trash_icon AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "" OR attributes.folderaccess EQ "X")>
					<cfif (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR attributes.folderaccess EQ "X")>
						<input type="button" name="trashfolder" value="#myFusebox.getApplicationData().defaults.trans("trash_folder")#" class="button" onclick="showwindow('#myself#ajax.trash_folder&folder_id=#attributes.folder_id#&iscol=#qry_folder.folder_is_collection#','#myFusebox.getApplicationData().defaults.trans("trash_folder")#',400,2);" style="margin-right:20px;">
					<cfelseif qry_folder.folder_name NEQ "my folder" AND qry_folder.folder_owner EQ session.theuserid>
						<input type="button" name="trashfolder" value="#myFusebox.getApplicationData().defaults.trans("trash_folder")#" class="button" onclick="showwindow('#myself#ajax.trash_folder&folder_id=#attributes.folder_id#&iscol=#qry_folder.folder_is_collection#','#myFusebox.getApplicationData().defaults.trans("trash_folder")#',400,2);" style="margin-right:20px;">
					</cfif>
				</cfif>
			</cfif>
			<!--- <cfif attributes.isdetail NEQ "T">
				<input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("cancel")#" onclick="destroywindow(1);return false;" class="button"> 
			</cfif> --->
		</div>
		<div style="float:right;padding-top:10px;padding-right:10px;">
			<div id="updatetext" style="float:left;color:green;padding-right:10px;padding-top:4px;font-weight:bold;"></div>
		</div>
	</div>
	</form>

	<!--- JS --->
	<cfif attributes.isdetail NEQ "T">
		<script language="JavaScript" type="text/javascript">
			// Initialize Tabs
			jqtabs("folder#attributes.theid#-#attributes.isdetail#");
			// Check link
			function jschecklink(){
				// Check link
				loadcontent('foldercheck','#myself#c.folder_link_check&link_path=' + escape($('##link_path').val()));
			}
		</script>
	</cfif>
	<script language="JavaScript" type="text/javascript">
		// Focus on the folder_name
		$('##folder_name').focus();
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
	</script>
</cfoutput>