// Hack for IE10. Only works in IE10 as 10 has conditional testing
var isIE10 = false;
/*@cc_on
	if (/^10/.test(@_jscript_version)) {
		isIE10 = true;
	}
@*/
// JQuery Settings. Disable jquery cache if IE10 as it caches way too much
if (isIE10) {
	$.ajaxSetup({
		cache: false
	});
}
// Show Window
function showwindow(theurl,thetitle,thew,thewin) {
	destroywindow(thewin);
	// Clear the content of the window and show the loading gif
	$('#thewindowcontent' + thewin).html('<img src="' + dynpath + '/global/host/dam/images/loading.gif" width="16" height="16" border="0" style="padding:10px;">');
	// Load Content into Dialog
	$('#thewindowcontent' + thewin).load(theurl).dialog({
		// RAZ-2718 Decode User's first and last name for title
		title: unescape(thetitle),
		modal: true,
		autoOpen: false,
		width: thew,
		height: 'auto',
		position: 'top'
		//minHeight: 600,
		// overlay: {
		// 	backgroundColor: '#000',
		// 	opacity: 0.5
		// }
	});
	// Open window
	$('#thewindowcontent' + thewin).dialog('open');
}
// Destroy Window
function destroywindow(numb) {
	try{
		$('#thewindowcontent' + numb).dialog('destroy').empty();
	}
	catch(e) {};
}
// Load Tabs
function jqtabs(tabs){
	$(function() {
		$("#" + tabs).tabs();
	});
}
// Load Content with JQuery
function loadcontent(ele,url){
	$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
	// Load the page
	$("#" + ele).load(url, function() {
		$("#bodyoverlay").remove();
	});
}
// Load overlay
function loadoverlay(){
	$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
}
// Form: Get Action URL
function formaction(theid) {
	var theaction = $('#' + theid).attr("action");
	return theaction;
}
// Form: Serialize Data
function formserialize(theid) {
	var theser = $('#' + theid).serialize();
	return theser;
}

// Jump to a folder and refresh left side
function goToFolder(folderid) {
	// Load folder on the right side
	$('#rightside').load('index.cfm?fa=c.folder&col=F&folder_id=' + folderid);
	// Refresh folder tree (as we could be in labels, etc.)
	switchmainselection('folders','Folders');
}

/*
 * Trim a string
 */
function trim(iString)	{
	return iString.replace (/^\s+/, '').replace (/\s+$/, '');
}
// Loading Gif
function loadinggif(whatdiv){
	$('#' + whatdiv).html('<img src="' + dynpath + '/global/host/dam/images/loading.gif" border="0" width="16" height="16">');
}
// JS to be able to click on the text link and have the checkbox checked
// This should be called like: <a href="##" onclick="clickcbk('theform','convert_to',0)"> where
// the "0" is the number of the first checkbox fields.
function clickcbk(theform,thefield,which) {
	if(document.forms[theform].elements[thefield][which].checked == false){
		document.forms[theform].elements[thefield][which].checked = true;
	}
	else{
		document.forms[theform].elements[thefield][which].checked = false;
	}
}
// Remove Record
function removerecord(what,id){
	//alert(what);
	$("#thewindowcontent1").html("");
	destroywindow(1);
}
// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = document.forms[theform].app_lang.options[document.forms[theform].app_lang.selectedIndex].value;
	if(URL2 != '') {
	window.top.location.href = URL2 + '&v=' + parseInt((Math.random() * 99999999)) ;
	}
}
// Change Host
function changehost(hostform){
	var URL3 = document.hostform.host.options[document.hostform.host.selectedIndex].value;
	window.top.location.href = URL3;
}
// Change Row per Page
function changerow(ele,theid){
	var theurl = $('#' + theid).val();
	loadcontent(ele,theurl);
}
// Change Host and submit form
function changehostform(hostform){
	document.hostform.submit();
}
// Jump to different section within admin
function gotos(gotourl){
	var URL4 = document.gotourl.gotosec.options[document.gotourl.gotosec.selectedIndex].value;
	if (URL4 != '') {
		window.open(URL4);
	}
}
function toggleDiv(mydiv){
	//alert(document.getElementById(mydiv));
	var t = document.getElementById(mydiv);
	
	if(t.style.display == "none"){
		t.style.display = "";
	}else{
		t.style.display = "none";
	}
}
function hidethis(mydiv){
	var t = document.getElementById(mydiv);
	t.style.display = "none";
}
function FormInfo() {
	var info = "";
	for(var i=0;i<document.forms.length;i++)	{
		var oForm = document.forms[i];
		info += oForm.name + "\n";
		for(var j=0;j<oForm.elements.length;j++){
			info += oForm.elements[j].name + "(" + oForm.elements[j].type + ")"  + " : " + oForm.elements[j].value + "\n";
		}
	}
	return info;
}
// Copy the content from one select box top the second select box
function deleteOption(object,index) {
	object.options[index] = null;
}
function addOption(object,text,value) {
	var defaultSelected = true;
	var selected = true;
	var optionName = new Option(text, value, defaultSelected, selected)
	object.options[object.length] = optionName;
}
function copySelected(fromObject,toObject) {
	for (var i=0, l=fromObject.options.length;i<l;i++) {
		if (fromObject.options[i].selected)
			addOption(toObject,fromObject.options[i].text,fromObject.options[i].value);
	}
	for (var i=fromObject.options.length-1;i>-1;i--) {
		if (fromObject.options[i].selected)
			deleteOption(fromObject,i);
	}
}
function copyAll(fromObject,toObject) {
	for (var i=0, l=fromObject.options.length;i<l;i++) {
		addOption(toObject,fromObject.options[i].text,fromObject.options[i].value);
	}
	for (var i=fromObject.options.length-1;i>-1;i--) {
		deleteOption(fromObject,i);
	}
}
function populateHidden(fromObject,toObject) {
	var output = '';
	for (var i=0, l=fromObject.options.length;i<l;i++) {
			output += escape(fromObject.options[i].value) + ',';
	}
	//alert(output);
	toObject.value = output;
}
// Will convert the value given in the width and set it in the heigth
function aspectheight(inp,out,theform){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = inp.value / document.forms[theform].elements[out].value;
		if (theaspect != 2){
			var bytwo = inp.value / 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.forms[theform].elements[out].value = bytwo;
		}
}
// Will convert the value given in the heigth and set it in the width
function aspectwidth(inp,out,theform){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = inp.value / document.forms[theform].elements[out].value;
		if (theaspect != 2){
			var bytwo = inp.value * 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.forms[theform].elements[out].value = bytwo;
		}
}
// Enable folderselection in list
function enablesub(myform,nostore) {
	// Remove ui-selected class
	$('.assetbox').removeClass('ui-selected');
	// Set nostore to false
	if (nostore === ''){
		nostore = false;
	}
	// Check if there are any files selected. If so ignore below
	var anyselect = $('div').hasClass('ui-selected');
	if (!anyselect) {
		// Check state of selection box
		// var isclosed = $("#folderselection" + myform).is(':hidden');
		// get how many are selected
		var n = $('#' + myform + ' input:checked').length;
		// Open or close selection
		if (n > 0) {
			$("#folderselection" + myform).slideDown('slow');
			$("#folderselectionb" + myform).slideDown('slow');
			$("#selectalert" + myform).slideDown('slow');
			$("#selectalertb" + myform).slideDown('slow');
		}
		if (n === 0) {
			$("#folderselection" + myform).slideUp('slow');
			$("#folderselectionb" + myform).slideUp('slow');
			$("#selectalert" + myform).slideUp('slow');
			$("#selectalertb" + myform).slideUp('slow');
			// Store IDs
			if (!nostore){
				storeids(myform);
			}
		}
		// if selection is here
		if (n !== 0) {
			// Hide the selectall desc
			$("#selectstore" + myform).css("display","none");
			$("#selectstoreb" + myform).css("display","none");
			// Store IDs
			if (!nostore){
				storeids(myform);
			}
		}
	}
}
// Enable folderselection in list
function enablefromselectable(myform) {
	var idsempty = false;
	// Check state of selection box
	var isclosed = $("#folderselection" + myform).is(':hidden');
	// get how many are selected
	var n = $("#" + myform + " .ui-selected input[name='file_id']").length;
	// Open or close selection
	if (n > 0 && isclosed) {
		$("#folderselection" + myform).slideToggle('slow');
		$("#folderselectionb" + myform).slideToggle('slow');
		
	}
	if (n === 0 && !isclosed) {
		$("#folderselection" + myform).slideToggle('slow');
		$("#folderselectionb" + myform).slideToggle('slow');
	}
	// Hide select all status
	$("#selectstore" + myform).css("display","none");
	$("#selectstoreb" + myform).css("display","none");
}
function enablesubserver(myform) {
	var valid = true;   
	var checkBoxes = false;
	var checkboxChecked = false;
	
	for (var i=0, j=document.forms[myform].elements.length; i<j; i++) {
		myType = document.forms[myform].elements[i].type;
		
	if (myType == 'checkbox') {
			checkBoxes = true;
			if (document.forms[myform].elements[i].checked) checkboxChecked = true;
		}
	}

	if (checkboxChecked == false) {
	document.forms[myform].submitbutton.disabled = true;
	}
	if (checkboxChecked == true) {
	document.forms[myform].submitbutton.disabled = false;
	}
}
function validateValues() {
	var valid = true;
		
	var checkBoxes = false;
	var checkboxChecked = false;
	
	for (var i=0, j=document.forms[myform].elements.length; i<j; i++) {
		myType = document.forms[myform].elements[i].type;
		
		if (myType == 'checkbox') {
			checkBoxes = true;
			if (document.forms[myform].elements[i].checked) checkboxChecked = true;
		}
		
	}

	if (checkBoxes && !checkboxChecked) valid = false;

	if (!valid)
	return valid;    
}
// If clicked in the document then close any dropdown menu with the class ddicon
$(document).bind('click', function(e) {
	var $clicked=$(e.target);
	/* if($clicked.is('.ddselection_header') || $clicked.parents().is('.ddselection_header') || $clicked.is('.ddicon')) */
	if($clicked.is('.ddicon') || $clicked.parents().is('.ddselection_header')) {
		//alert('inside');
	}
	else {
		//alert('outside');
		$('.ddselection_header').hide();
	}
});
// Simply JS to check radio button for group permissions
// Check radio box
	function checkradio(thisid){
		$('#per_' + thisid).prop('checked','checked');
	}
// Flash footer_tabs
function flash_footer(text){
	$.sticky(text);
}
// Global Tagit events
function raztagit(thediv,fileid,thetype,raztags,perm){
	var tags = $('#' + thediv);
	tags.tagit({
		singleField: true,
		singleFieldNode: $('#' + thediv),
		availableTags: raztags,
		caseSensitive: false,
		allowSpaces: true
	});
	// If user adds a new tag (but only if he is allowed to)
	tags.tagit({
		onTagAdded: function(evt, tag) {
			var v = tags.tagit('tagLabel', tag);
			loadcontent('div_forall','index.cfm?fa=c.label_update&id=' + fileid + '&type=' + thetype + '&thelab=' + encodeURIComponent(v));
			if (perm == 't'){
				$.sticky('<span style="color:green;font-Weight:bold;">The label has been saved!</span>');
			}
		}
	});
	// If user removed it from here
	tags.tagit({
		onTagRemoved: function(evt, tag) {
			var v = tags.tagit('tagLabel', tag);
			loadcontent('div_forall','index.cfm?fa=c.label_remove&id=' + fileid + '&type=' + thetype + '&thelab=' + encodeURIComponent(v));
			$.sticky('The label has been removed!');
		}
	});
}

// Adding labels for users who can not edit
function razaddlabels(thediv,fileid,thetype,text){
	$('#' + thediv).chosen().change(
		loadcontent('div_forall','index.cfm?fa=c.label_add_all&fileid=' + fileid + '&thetype=' + thetype + '&labels=' + $('#' + thediv).val())
	);
	$.sticky(text);
}

// For the Quick Search
$(document).ready(function() {
	// Store the value of the input field
	var theval = $('#simplesearchtext').val();
	// If user click on the quick search field we hide the text
	$('#simplesearchtext').click(function(){
		// Get the value of the entry field
		var theentrynow = $('#simplesearchtext').val();
		if (theentrynow == 'Quick Search'){
			$('#simplesearchtext').val('');
		}
	});
	// If the value field is empty restore the value field
	$('#simplesearchtext').blur(function(){
		// Get the current value of the field
		var thevalnow = $('#simplesearchtext').val();
		// If the current value is empty then restore it with the default value
		if ( thevalnow === '') {
			$('#simplesearchtext').val(theval);
		}
	});
});
function checkentry(){
	// Define the folder id
	var thefolderid = 0;
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// Parse the entry
	var theentry = $('#simplesearchtext').val();
	var thetype = $('#simplesearchthetype').val();
	// Grab the folder id
	var folder_id = $('#qs_folder_id').val();
	if (typeof folder_id !== 'undefined' && folder_id !== '') {
		thefolderid = folder_id;
	}
	if (theentry === "" | theentry === "Quick Search") {
		return false;
	}
	else {
		// get the first position
		var p1 = theentry.substr(theentry,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Show loading bar
			$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
			// We are now using POST for the search field (much more compatible then a simple load for foreign chars)
			$('#rightside').load('index.cfm?fa=c.search_simple', { searchtext: encodeURIComponent(theentry), folder_id: thefolderid, thetype: thetype }, function(){
				$("#bodyoverlay").remove();
			});
		}
		return false;
	}
}
// When a search selection is clicked
function selectsearchtype(thetype,thelinktext){
	// Set the type in hidden input field
	$('#simplesearchthetype').val(thetype);
	$('#searchselection').toggle();
	// Remove the image in all marks
	$('.markfolder').html('&nbsp;').css({'float':'left','padding-right':'14px'});
	// Now mark the div
	$('#mark' + thetype).css({'float':'left','padding-right':'3px'});
	$('#mark' + thetype).html('<img src="' + dynpath + '/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0">');
	// Change the link text itself
	$('#searchselectionlink').text(thelinktext);
}
// When a search selection is clicked for search selection
function selectsearchselection(folderid,thelinktext){
	// Set the folder id in hidden input field
	$('#simplesearchfolderid').val(folderid);
	$('#searchselection').toggle();
	// Remove the image in all marks
	$('.markfolder').html('&nbsp;').css({'float':'left','padding-right':'14px'});
	// Now mark the div
	$('#mark_' + folderid).css({'float':'left','padding-right':'3px'});
	$('#mark_' + folderid).html('<img src="' + dynpath + '/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0">');
	// Change the link text itself
	$('#searchselectionlink').text(thelinktext);
}
// Store selects
function storeids(theform){
	// Get the checked values (file id's)
	var fileids = '';
	var filetypes = '';
	var del_fileids = '';
	var del_filetypes = '';
	// $('input[name=checkbox][name="file_id"]:checked').each(function() {
	// console.log($(this).val());
	// });
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
	   if ((document.forms[theform].elements[i].name.indexOf('file_id') > -1)) {
			if (document.forms[theform].elements[i].checked) {
				fileids += document.forms[theform].elements[i].value + ',';
			}
			/* else {
				del_fileids += document.forms[theform].elements[i].value + ',';
			}*/
		}
	}
	// Store in session
	$('#div_forall').load('index.cfm?fa=c.store_file_values',{file_id:fileids,del_file_id:del_fileids,individual_select:true});
}
function storeone(theid) {
	// Remove all first
	$('#div_forall').load('index.cfm?fa=c.store_file_search', { fileids: 0 });
	// Add this one id
	$('#div_forall').load('index.cfm?fa=c.store_file_values',{ file_id: theid });
}
// Check all checkboxes
function CheckAll(myform,folderid,thediv,thekind) {
	// Enable select all text again. cloud be set hidden from single selection
	$("#selectstore" + myform).css("display","");
	$("#selectstoreb" + myform).css("display","");
	$("#selectalert" + myform).css("display","");
	$("#selectalertb" + myform).css("display","");
	// Loop over checkboxes and check all
	$('#' + myform + ' :checkbox').prop('checked', true);
	// Show drop down
	$("#folderselection" + myform).slideDown('slow');
	$("#folderselectionb" + myform).slideDown('slow');
	// Remove ui-selected class
	$('.assetbox').removeClass('ui-selected');
	// Decide if this is from the search
	if(folderid != 'x'){
		$('#div_forall').load('index.cfm?fa=c.store_file_all&folder_id=' + folderid + '&thekind=' + thekind );
	}
	else{
		// Get the ids from the hidden field
		var theids = $('#searchlistids').val();
		var theeditids = $('#editids').val();
		$('#div_forall').load('index.cfm?fa=c.store_file_search', { fileids: theids, editids : theeditids });
	}
}

function CheckAllNot(myform){
	// Loop over checkboxes and check/uncheck and set var
	$('#' + myform + ' :checkbox').prop('checked', false);
	// Hide bar
	$("#folderselection" + myform).slideUp('slow');
	$("#folderselectionb" + myform).slideUp('slow');
	// Hide the selectall desc
	$("#selectstore" + myform).css("display","none");
	$("#selectstoreb" + myform).css("display","none");
	$("#selectalert" + myform).css("display","none");
	$("#selectalertb" + myform).css("display","none");
	// Get the ids from the hidden field
	$('#div_forall').load('index.cfm?fa=c.store_file_search', { fileids: 0 });
}

// Site conversion

// Video Preset function
function setpreset(theformat,theform){
	// get value
	var theval = $('#preset_' + theformat + ' option:selected').val();
	// set form fields
	var w = 'convert_width_' + theformat;
	var h = 'convert_height_' + theformat;
	switch(theval){
		case 'hd1080':
			var thew = '1920';
			var theh = '1080';
			break;
		case 'hd720':
			var thew = '1280';
			var theh = '720';
			break;
		case 'hd480':
			var thew = '852';
			var theh = '480';
			break;
		case 'sqcif':
			var thew = '128';
			var theh = '96';
			break;
		case 'qcif':
			var thew = '176';
			var theh = '144';
			break;
		case 'cif':
			var thew = '352';
			var theh = '288';
			break;
		case '4cif':
			var thew = '704';
			var theh = '576';
			break;
		case '16cif':
			var thew = '1408';
			var theh = '1152';
			break;
		case 'qqvga':
			var thew = '160';
			var theh = '120';
			break;
		case 'qvga':
			var thew = '320';
			var theh = '240';
			break;
		case 'vga':
			var thew = '640';
			var theh = '480';
			break;
		case 'svga':
			var thew = '800';
			var theh = '600';
			break;
		case 'xga':
			var thew = '1024';
			var theh = '768';
			break;
		case 'uxga':
			var thew = '1600';
			var theh = '1200';
			break;
		case 'qxga':
			var thew = '2048';
			var theh = '1536';
			break;
		case 'sxga':
			var thew = '1280';
			var theh = '1024';
			break;
		case 'qsxga':
			var thew = '2560';
			var theh = '2048';
			break;
		case 'hsxga':
			var thew = '5120';
			var theh = '4096';
			break;
		case 'wvga':
			var thew = '852';
			var theh = '480';
			break;
		case 'wxga':
			var thew = '1366';
			var theh = '768';
			break;
		case 'wsxga':
			var thew = '1600';
			var theh = '1024';
			break;
		case 'wuxga':
			var thew = '1920';
			var theh = '1200';
			break;
		case 'woxga':
			var thew = '2560';
			var theh = '1600';
			break;
		case 'wqsxga':
			var thew = '3200';
			var theh = '2048';
			break;
		case 'wquxga':
			var thew = '3840';
			var theh = '2400';
			break;
		case 'whsxga':
			var thew = '6400';
			var theh = '4096';
			break;
		case 'whuxga':
			var thew = '7680';
			var theh = '4800';
			break;
		case 'cga':
			var thew = '320';
			var theh = '200';
			break;
		case 'ega':
			var thew = '640';
			var theh = '350';
			break;
		default:
			var thew = '1280';
			var theh = '720';
			break;
	}
	// set the w and h
	document.forms[theform][w].value = thew;
	document.forms[theform][h].value = theh;
}
// Set values for the 3GP format correct
function clickset3gp(theform){
	document.forms[theform].convert_width_3gp.value = '128';
	document.forms[theform].convert_height_3gp.value = '96';
}
function set3gp(theform){
	var thissize = document.forms[theform].convert_wh_3gp.selectedIndex;
	switch(thissize){
		//all values which are 128x96
		case 1: case 2: case 4: case 6: case 8:
		document.forms[theform].convert_width_3gp.value = '128';
		document.forms[theform].convert_height_3gp.value = '96';
		break;
		//all values which are 176x144
		case 3: case 5: case 7: case 9:
		document.forms[theform].convert_width_3gp.value = '176';
		document.forms[theform].convert_height_3gp.value = '144';
		break;
		case 10:
		document.forms[theform].convert_width_3gp.value = '352';
		document.forms[theform].convert_height_3gp.value = '288';
		break;
		case 11:
		document.forms[theform].convert_width_3gp.value = '704';
		document.forms[theform].convert_height_3gp.value = '576';
		break;
		case 12:
		document.forms[theform].convert_width_3gp.value = '1408';
		document.forms[theform].convert_height_3gp.value = '1152';	
		break;
	}
	switch(thissize){
		case 1:
		document.forms[theform].convert_bitrate_3gp.value = '64';
		break;
		case 2: case 3:
		document.forms[theform].convert_bitrate_3gp.value = '95';
		break;
		case 4: case 5:
		document.forms[theform].convert_bitrate_3gp.value = '200';
		break;
		case 6: case 7:
		document.forms[theform].convert_bitrate_3gp.value = '300';
		break;
		case 8: case 9: case 10: case 11: case 12:
		document.forms[theform].convert_bitrate_3gp.value = '600';
		break;
	}
}
// Set values for the Additional rendition for 3GP format correct for rendition template
function clickset3gp_additional(theform,idx){
	document.forms[theform]["convert_width_3gp_"+idx].value = '128';
	document.forms[theform]["convert_height_3gp_"+idx].value = '96';
}
function set3gp_additional(theform,index){
	var thissize = document.forms[theform]["convert_wh_3gp_"+index].selectedIndex;
	switch(thissize){
		//all values which are 128x96
		case 1: case 2: case 4: case 6: case 8:
		document.forms[theform]["convert_width_3gp_"+index].value = '128';
		document.forms[theform]["convert_height_3gp_"+index].value = '96';
		break;
		//all values which are 176x144
		case 3: case 5: case 7: case 9:
		document.forms[theform]["convert_width_3gp_"+index].value = '176';
		document.forms[theform]["convert_height_3gp_"+index].value = '144';
		break;
		case 10:
		document.forms[theform]["convert_width_3gp_"+index].value = '352';
		document.forms[theform]["convert_height_3gp_"+index].value = '288';
		break;
		case 11:
		document.forms[theform]["convert_width_3gp_"+index].value = '704';
		document.forms[theform]["convert_height_3gp_"+index].value = '576';
		break;
		case 12:
		document.forms[theform]["convert_width_3gp_"+index].value = '1408';
		document.forms[theform]["convert_height_3gp_"+index].value = '1152';	
		break;
	}
	switch(thissize){
		case 1:
		document.forms[theform]["convert_bitrate_3gp_"+index].value = '64';
		break;
		case 2: case 3:
		document.forms[theform]["convert_bitrate_3gp_"+index].value = '95';
		break;
		case 4: case 5:
		document.forms[theform]["convert_bitrate_3gp_"+index].value = '200';
		break;
		case 6: case 7:
		document.forms[theform]["convert_bitrate_3gp_"+index].value = '300';
		break;
		case 8: case 9: case 10: case 11: case 12:
		document.forms[theform]["convert_bitrate_3gp_"+index].value = '600';
		break;
	}
}
// Will convert the value given in the width and set it in the heigth
function aspectheight(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	if (inp.value%2 == 1){
		inp.value = inp.value - 1;
	}
	var theheight = inp.value / theaspect;
	num = theheight + '';
	var mynum = parseInt(num);
	if (mynum%2 == 1){
		mynum = mynum - 1;
	}
	document.forms[theform].elements[out].value = mynum;
}
// Will convert the value given in the heigth and set it in the width
function aspectwidth(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	if (inp.value%2 == 1){
		inp.value = inp.value - 1;
	}
	var theheight = inp.value * theaspect;
	num = theheight + '';
	var mynum = parseInt(num);
	if (mynum%2 == 1){
		mynum = mynum - 1;
	}
	document.forms[theform].elements[out].value = mynum;
}
function changeFormat(theform,inpheight,inpwidth,outheight,outwidth,ydpi,xdpi,inheight,inwidth,formatbox) {
			var formatbox = document.forms[theform].elements[formatbox];
			var selectedFormat = formatbox.options[formatbox.selectedIndex].value;
			if(selectedFormat == "inches") {
				var heightinches = Math.round(inpheight.value / ydpi*100)/100;
				document.forms[theform].elements[inheight].value = heightinches;

				document.forms[theform].elements[outheight].style.display='none';
				document.forms[theform].elements[inheight].style.display='';

				var widthinches = Math.round(inpwidth.value / xdpi*100)/100; 
				document.forms[theform].elements[inwidth].value = widthinches;

				document.forms[theform].elements[outwidth].style.display='none';
				document.forms[theform].elements[inwidth].style.display='';
			}

			if(selectedFormat == "pixels") {
				document.forms[theform].elements[outheight].style.display='';
				document.forms[theform].elements[inheight].style.display='none';

				document.forms[theform].elements[outwidth].style.display='';
				document.forms[theform].elements[inwidth].style.display='none';
			}
	   }
function updatePixels(theform,height,width,outheight,outwidth,ydpi,xdpi) {
		var heightpixels = height.value * ydpi;
		document.forms[theform].elements[outheight].value = heightpixels;
		var widthpixels = width.value * xdpi;
		document.forms[theform].elements[outwidth].value = widthpixels;
   }
   // Will convert the value given in the width and set it in the height
function aspectheightin(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	var theheight = Math.round(inp.value / theaspect*100)/100;
	document.forms[theform].elements[out].value = theheight;
}
// Will convert the value given in the heigth and set it in the width
function aspectwidthin(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	var theheight = Math.round(inp.value * theaspect*100)/100;
	document.forms[theform].elements[out].value = theheight;
}

// Save Comment
function addcomment(fileid,type,folderid,iscol){
	var thecomment = $('#assetComment').val();
	$('#comlist').load('index.cfm?fa=c.comments_add', { folder_id:folderid, file_id:fileid, type:type, comment:thecomment } );
	// Reload comment section to re-issue new id
	if(iscol == 'T'){
		loadcontent('divcommentscol','index.cfm?fa=c.comments&file_id=' + fileid + '&type=' + type + '&folder_id=' + folderid);
	}else{
		loadcontent('divcomments','index.cfm?fa=c.comments&file_id=' + fileid + '&type=' + type + '&folder_id=' + folderid);
	}
}
// Update Comment
function updatecomment(fileid,comid,type,folderid){
	var thecomment = $('#commentup').val();
	$('#comlist').load('index.cfm?fa=c.comments_update', { folder_id:folderid, file_id:fileid, com_id:comid, type:type, comment:thecomment } );
	// Hide Window
	destroywindow(2);
}
// BASKET

// Popup window for download of the basket
function createTarget(t){
	// Get the selections
	var artimage = getimageselection();
	var artvideo = getvideoselection();
	var artaudio = getaudioselection();
	var artfile = getfileselection();
}
// Populate form fields
function loadform(theform){
	// Get the selections
	var artimage = getimageselection();
	var artvideo = getvideoselection();
	var artaudio = getaudioselection();
	var artfile = getfileselection();
	// Fill form fields
	$('#' + theform + '_artofimage').val(artimage);
	$('#' + theform + '_artvideo').val(artimage);
	$('#' + theform + '_artaudio').val(artimage);
	$('#' + theform + '_artfile').val(artimage);
}
// Store art values
function storevalues(){
	// Get the selections
	var artimage = getimageselection();
	var artvideo = getvideoselection();
	var artaudio = getaudioselection();
	var artfile = getfileselection();
	// Submit the values so we put them into sessions
	var url = 'index.cfm?fa=c.store_art_values';
	var items = '&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile;
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
		data: items
	});
}
// Get Image Selection
function getimageselection(){
	var artofimage = '';
		// Loop trough the image selection
		for (var i = 0; i<document.thebasket.elements.length; i++) {
		   if ((document.thebasket.elements[i].name.indexOf('artofimage') > -1)) {
			   if (document.thebasket.elements[i].checked) {
				artofimage += document.thebasket.elements[i].value + ',';
				}
			}
		}
	return artofimage;
}
// Get Video Selection
function getvideoselection(){
	var artofvideo = '';
		// Loop trough the video selection
		for (var i = 0; i<document.thebasket.elements.length; i++) {
		   if ((document.thebasket.elements[i].name.indexOf('artofvideo') > -1)) {
			   if (document.thebasket.elements[i].checked) {
				artofvideo += document.thebasket.elements[i].value + ',';
				}
			}
		}
	return artofvideo;
}
// Get Audio Selection
function getaudioselection(){
	var artofaudio = '';
		// Loop trough the audio selection
		for (var i = 0; i<document.thebasket.elements.length; i++) {
		   if ((document.thebasket.elements[i].name.indexOf('artofaudio') > -1)) {
			   if (document.thebasket.elements[i].checked) {
				artofaudio += document.thebasket.elements[i].value + ',';
				}
			}
		}
	return artofaudio;
}
// Get File Selection
function getfileselection(){
	var artoffile = '';
		// Loop trough the file selection
		for (var i = 0; i<document.thebasket.elements.length; i++) {
		   if ((document.thebasket.elements[i].name.indexOf('artoffile') > -1)) {
			   if (document.thebasket.elements[i].checked) {
				artoffile += document.thebasket.elements[i].value + ',';
				}
			}
		}
	return artoffile;
}
// Check selection for ID
function checksel(theid,theckb,kind){
	// Select on the kind which function we load
	if (kind == 'img'){
		var theids = getimageselection();
	}
	if (kind == 'vid'){
		var theids = getvideoselection();
	}
	if (kind == 'aud'){
		var theids = getaudioselection();
	}
	if (kind == 'doc'){
		var theids = getfileselection();
	}
	// Get the ID's
	var ind = theids.indexOf(theid);
	// if the indexof return -1 we prompt and reset the checkbox
	if (ind == '-1'){
		alert('You need to select at least one kind of the asset, else remove it from the basket!');
		$('#' + theckb).prop('checked', true);
	}
}
function addgrp(){
	//Check to ensure group name is entered
	var checkgrp= $('#grpnew').val();
	var upcsize= $('#sizeofupc').val();
	//Folder subscribe radio
	if ($('input:radio[name=folder_subscribe]:checked').length == 0) {
		var folder_subscribe = 'false';
	}
	else {
		var folder_subscribe= $('input:radio[name=folder_subscribe]:checked').val();
	}

	// RAZ-2824 :: Check the UPC folder structure is checked or not
	if ($('input:radio[name=upc_folder_structure]:checked').length == 0) {
		var upc_folder = 'false';
	}
	else {
		var upc_folder = $('input:radio[name=upc_folder_structure]:checked').val();
	}
	if(checkgrp=="")
	{
		alert('Please enter the group name!');
		return false;
	}
	// Add the new group and show the updated list
	loadcontent('admin_groups', 'index.cfm?fa=c.groups_add&kind=ecp&loaddiv=admin_groups&newgrp=' + encodeURIComponent($("#grpnew").val())+'&sizeofupc=' + upcsize +'&upc_folder_structure=' + upc_folder + '&folder_subscribe=' + folder_subscribe);
}
function updategrp(grpid){
	// Hide Window
	destroywindow(2);
	//Check to ensure group name is entered
	var checkgrp= $('#grpname').val();
	var upcsize= $('#editupcsize').val();
	var folder_redirect= $('#folder_redirect').val();
	//Folder subscribe radio
	if ($('input:radio[name=edit_folder_subscribe]:checked').length == 0) {
		var folder_subscribe = 'false';
	}
	else {
		var folder_subscribe= $('input:radio[name=edit_folder_subscribe]:checked').val();
	}
	// RAZ-2824 :: Check the UPC folder structure is checked or not
	if ($('input:radio[name=edit_upc_folder_structure]:checked').length == 0) {
		var upc_folder = 'false';
	}
	else {
		var upc_folder = $('input:radio[name=edit_upc_folder_structure]:checked').val(); 
	}
	if(checkgrp=="")
	{
		alert('Group name can not be empty!');
		return false;
	}
	// Add the new group and show the updated list
	loadcontent('admin_groups', 'index.cfm?fa=c.groups_update&kind=ecp&loaddiv=admin_groups&grp_id=' + grpid + '&grpname=' + encodeURIComponent($("#grpname").val())+'&sizeofupc=' + upcsize +'&upc_folder_structure=' + upc_folder + '&folder_subscribe=' + folder_subscribe + '&folder_redirect=' + folder_redirect);
}

// SCHEDULER

// Upload method: Server, Mail, FTP
function showConnectDetail(kind) {
	// Show Frequency options
	$("#frequency option[value='2']").attr('disabled',false);
	$("#frequency option[value='3']").attr('disabled',false);
	// Get method
	var method = $("#method option:selected").val();
	// Set folder_id by default
	$("#folder_id").val('');
	// Show lower part
	$("#task_lower_part").css('display','');
	// Evaluate
	if (method == "server") { 
		$("#detailsServer_"+kind).css('display','block');
		$("#detailsMail_"+kind).css('display','none');
		$("#detailsFtp_"+kind).css('display','none');
		$("#detailsADUserGroup_"+kind).css('display','none');
	}
	else if (method == "mail") {
		$("#detailsServer_"+kind).css('display','none');
		$("#detailsMail_"+kind).css('display','block');
		$("#detailsFtp_"+kind).css('display','none');
		$("#detailsADUserGroup_"+kind).css('display','none');
	}
	else if (method == "ftp") {
		$("#detailsServer_"+kind).css('display','none');
		$("#detailsMail_"+kind).css('display','none');
		$("#detailsFtp_"+kind).css('display','block');
		$("#detailsADUserGroup_"+kind).css('display','none');
	}
	else if (method == "ADServer"){
		$("#detailsServer_"+kind).css('display','none');
		$("#detailsMail_"+kind).css('display','none');
		$("#detailsFtp_"+kind).css('display','none');
		$("#detailsADUserGroup_"+kind).css('display','block');
		// Set folderid to 0 so we don't get errors
		$("#folder_id").val('0');
		// Hide lower part
		$("#task_lower_part").css('display','none');
	}
	else if (method == "rebuild" || method == "indexing" ) {
		$("#detailsServer_"+kind).css('display','none');
		$("#detailsMail_"+kind).css('display','none');
		$("#detailsFtp_"+kind).css('display','none');
		$("#detailsADUserGroup_"+kind).css('display','none');
		// Set folderid to 0 so we don't get errors
		$("#folder_id").val('0');
		// Hide lower part
		$("#task_lower_part").css('display','none');
		// If rebuild remove repeat time options
		if (method == "rebuild") {
			$("#frequency option[value='2']").attr('disabled','disabled');
			$("#frequency option[value='3']").attr('disabled','disabled');
		}
		// Show frequency
		showFrequencyDetail('new');
	}
}

// Frequency: One-Time, Recurring, Daily
function showFrequencyDetail(kind) {
	var frequency = $("#frequency option:selected").val();
	if (frequency == "1") { 
		document.getElementById("detailsOneTime_"+kind).style.display = "block"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "none"; 
		document.getElementById("detailsDaily_"+kind).style.display = "none"; 
	}
	else if (frequency == "2") {
		document.getElementById("detailsOneTime_"+kind).style.display = "none"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "block"; 
		document.getElementById("detailsDaily_"+kind).style.display = "none"; 
	}
	else if (frequency == "3") {
		document.getElementById("detailsOneTime_"+kind).style.display = "none"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "none"; 
		document.getElementById("detailsDaily_"+kind).style.display = "block"; 
	}
}
// Check and fix time
function fixTime(fld) 
{ // tenacious time correction 
	if(!fld.value.length||fld.disabled) return true; // blank fields are the domain of requireValue 
	var hour= 0; 
	var mins= 0;
	val= fld.value;
	var dt= new Date('1/1/2000 ' + val);
	if(('9'+val) == parseInt('9'+val))
	{ hour= val; }
	else if(dt.valueOf())
	{ hour= dt.getHours(); mins= dt.getMinutes(); }
	else
	{
		val= val.replace(/\D+/g,':');
		hour= parseInt(val);
		mins= parseInt(val.substring(val.indexOf(':')+1,20));
		if(isNaN(hour)) hour= 0;
		if(isNaN(mins)) mins= 0;
		if(val.indexOf('pm') > -1) hour+= 12;
	}
	hour%= 24;
	mins%= 60;
	if(mins < 10) mins= '0' + mins;
	fld.value= hour + ':' + mins;
	return true;
}
// Hide the window
function hidewinscheduler(){
	// Hide Window
	destroywindow(1);
	loadcontent('admin_schedules','index.cfm?fa=c.scheduler_list');
}
// Open FTP connection and show its folder structure
function openFtp(kind) {
	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var ftpServer = document.getElementsByName("ftpServer")[nr].value;
	var ftpUser   = escape(document.getElementsByName("ftpUser")[nr].value);
	var ftpPass   = escape(document.getElementsByName("ftpPass")[nr].value);
	var ftpPath   = document.getElementsByName("ftpFolder")[nr].value;
	var ftppassive   = document.getElementsByName("ftpPassive")[nr].value;
	if (ftpServer == "" || ftpUser == "" || ftpPass == "") {
		alert("Please enter the required fields FTP Server, User and Password!");
	} else {
		showwindow('index.cfm?fa=c.ftp_gologin&thetype=sched&ftp_server='+ftpServer+'&ftp_user='+ftpUser+'&ftp_pass='+ftpPass+'&ftp_passive='+ftppassive,'FTP',600,3);
	}
}
// Open eMail connection and show possible messages
function openMail(kind) {
	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var mailPop  = document.getElementsByName("mailPop")[nr].value;
	var mailUser = document.getElementsByName("mailUser")[nr].value;
	var mailPass = escape(document.getElementsByName("mailPass")[nr].value);
	var mailSubj = document.getElementsByName("mailSubject")[nr].value;
	if (mailPop == "" || mailUser == "" || mailPass == "") {
		alert("Please enter the required fields POP Server, User and Password!");
	} else {
		window.open('dsp_scheduler_email.cfm?pop='+mailPop+'&user='+mailUser+'&pass='+mailPass+'&subject='+mailSubj, 'mailWin', 'toolbar=no,location=0,directories=no,status=no,menubar=0,scrollbars=1,resizable=1,copyhistory=no,width=310,height=350');
	}
}

// CUSTOM FIELDS 

// Add a new field
function customfieldadd(){
	// Get values
	var url = formaction("form_cf_add");
	var items = formserialize("form_cf_add");
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
		data: items,
		success: reloadfields
	});
	return false;
}
// Update field
function customfieldupdate(){
	// Get values
	var url = formaction("form_cf_detail");
	var items = formserialize("form_cf_detail");
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
		data: items,
		success: function(){
			destroywindow(1);
			reloadfields();
		}
	});
	return false;
}
// Reload the fields div
function reloadfields(){
	loadcontent('thefields','index.cfm?fa=c.custom_fields_existing');	
}
// On document ready
$(document).ready(function() {
	// Detect Firebug
	// if (window.console && (window.console.firebug || window.console.exception)) {
	// 	//Firebug is enabled
	// 	$("#firebugalert").css({'display':'','padding':'10px','background-color':'#FFFFE0','color':'#900','font-weight':'bold','text-align':'center'});
	// 	$("#firebugalert").html('Hi there, Developer. The Firebug extension can significantly degrade the performance of Razuna. We recommend that you disable it for Razuna!');
	// 	$("#firebugalert").after('<div style="clear:both;"></div>');
	// }
	// Account window
	function showaccount(){
		win = window.open('','myWin','toolbars=0,location=1,status=1,scrollbars=1,directories=0,width=650,height=600');            
		document.form_account.target='myWin';
		document.form_account.submit();
	}
});

// FOLDER 

function loadfolderpage(theid){
	loadcontent('properties','index.cfm?fa=c.folder_edit&folder_id=' + theid + '&theid=' + theid);
}
function cbnewfolder(){
	// Reload Explorer
	reloadexplorer(theid,isdetail,iscol);
	// Hide Window
	destroywindow(1);
}
// Fire off advanced document search
function searchadv_files(theform, thefa, folderid) {
	// Call subfunction to get fields
	var searchtext = subadvfields(theform);
	// Put together the extend metadata
	var searchtext = subadvfieldsdoc(theform, searchtext);
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// get the first postion
	var p1 = searchtext.substr(searchtext,1);
	// Now check
	if (illegalChars.test(p1)){
		alert('The first character of your search string is an illegal one. Please remove it!');
	}
	else {
		// If we come from a folder search we direct into the folder view
		// if (folderid == '0'){
			var thediv = '#rightside';
		// }
		// else {
		// 	var thediv = '#content_search_all';
		// 	// Enable div
		// 	$('#content_search_all').css('display','');
		// 	// Remove tab (in case there is one already)
		// 	removeTab('tabsfolder_tab','content_search_all');
			
		// 	// Create new tab
		// 	addTab($('#tabsfolder_tab'), 'content_search_all' , 'Search Results');
			
		// 	// Select tab
		// 	var index = $('#tabsfolder_tab div.ui-tabs-panel').length-1;
		// 	$('#tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
		// }
		// Fire search
		$('#loading_searchadv').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$('#loading_searchadv2').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$(thediv).load('index.cfm?fa=' + thefa, { thetype: "doc", search_type: 'adv', folder_id: folderid, searchtext: searchtext, doctype: document.forms[theform].doctype.options[document.forms[theform].doctype.selectedIndex].value, on_day: document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value, on_month: document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value, on_year: document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, change_day: document.forms[theform].change_day.options[document.forms[theform].change_day.selectedIndex].value, change_month: document.forms[theform].change_month.options[document.forms[theform].change_month.selectedIndex].value, change_year: document.forms[theform].change_year.options[document.forms[theform].change_year.selectedIndex].value }, function(){
			// Hide Window
			destroywindow(1);
		});
	}
}
// Fire off advanced videos search
function searchadv_videos(theform, thefa, folderid) {
	// Call subfunction to get fields
	var searchtext = subadvfields(theform);
	// Encode searchtext
	var searchtext = encodeURIComponent(searchtext);
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// get the first postion
	var p1 = searchtext.substr(searchtext,1);
	// Now check
	if (illegalChars.test(p1)){
		alert('The first character of your search string is an illegal one. Please remove it!');
	}
	else {
		// If we come from a folder search we direct into the folder view
		// if (folderid == '0'){
			var thediv = '#rightside';
		// }
		// else {
		// 	var thediv = '#content_search_all';
		// 	// Enable div
		// 	$('#content_search_all').css('display','');
		// 	// Remove tab (in case there is one already)
		// 	removeTab('tabsfolder_tab','content_search_all');
			
		// 	// Create new tab
		// 	addTab($('#tabsfolder_tab'), 'content_search_all' , 'Search Results');
			
		// 	// Select tab
		// 	var index = $('#tabsfolder_tab div.ui-tabs-panel').length-1;
		// 	$('#tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
		// }
		// Fire search
		$('#loading_searchadv').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$('#loading_searchadv2').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$(thediv).load('index.cfm?fa=' + thefa, { thetype: "vid", search_type: 'adv', folder_id: folderid, searchtext: searchtext, on_day: document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value, on_month: document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value, on_year: document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, change_day: document.forms[theform].change_day.options[document.forms[theform].change_day.selectedIndex].value, change_month: document.forms[theform].change_month.options[document.forms[theform].change_month.selectedIndex].value, change_year: document.forms[theform].change_year.options[document.forms[theform].change_year.selectedIndex].value }, function(){
			// Hide Window
			destroywindow(1);
		});
	}
}
// Fire off advanced images search
function searchadv_images(theform, thefa, folderid) {
	// Call subfunction to get fields
	var searchtext = subadvfields(theform);
	// Put together the extend metadata
	var searchtext = subadvfieldsimg(theform, searchtext);
	// Encode searchtext
	var searchtext = encodeURIComponent(searchtext);
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// get the first postion
	var p1 = searchtext.substr(searchtext,1);
	// Now check
	if (illegalChars.test(p1)){
		alert('The first character of your search string is an illegal one. Please remove it!');
	}
	else {
		// If we come from a folder search we direct into the folder view
		// if (folderid == '0'){
			var thediv = '#rightside';
		// }
		// else {
		// 	var thediv = '#content_search_all';
		// 	// Enable div
		// 	$('#content_search_all').css('display','');
		// 	// Remove tab (in case there is one already)
		// 	removeTab('tabsfolder_tab','content_search_all');
			
		// 	// Create new tab
		// 	addTab($('#tabsfolder_tab'), 'content_search_all' , 'Search Results');
			
		// 	// Select tab
		// 	var index = $('#tabsfolder_tab div.ui-tabs-panel').length-1;
		// 	$('#tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
		// }
		// Fire search
		$('#loading_searchadv').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$('#loading_searchadv2').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$(thediv).load('index.cfm?fa=' + thefa, { thetype: "img", search_type: 'adv', folder_id: folderid, searchtext: searchtext, on_day: document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value, on_month: document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value, on_year: document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, change_day: document.forms[theform].change_day.options[document.forms[theform].change_day.selectedIndex].value, change_month: document.forms[theform].change_month.options[document.forms[theform].change_month.selectedIndex].value, change_year: document.forms[theform].change_year.options[document.forms[theform].change_year.selectedIndex].value }, function(){
			// Hide Window
			destroywindow(1);
		});
	}
}
// Fire off advanced images search
function searchadv_audios(theform, thefa, folderid) {
	// Call subfunction to get fields
	var searchtext = subadvfields(theform);
	// Encode searchtext
	var searchtext = encodeURIComponent(searchtext);
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// get the first postion
	var p1 = searchtext.substr(searchtext,1);
	// Now check
	if (illegalChars.test(p1)){
		alert('The first character of your search string is an illegal one. Please remove it!');
	}
	else {
		// If we come from a folder search we direct into the folder view
		// if (folderid == '0'){
			var thediv = '#rightside';
		// }
		// else {
		// 	var thediv = '#content_search_all';
		// 	// Enable div
		// 	$('#content_search_all').css('display','');
		// 	// Remove tab (in case there is one already)
		// 	removeTab('tabsfolder_tab','content_search_all');
			
		// 	// Create new tab
		// 	addTab($('#tabsfolder_tab'), 'content_search_all' , 'Search Results');
			
		// 	// Select tab
		// 	var index = $('#tabsfolder_tab div.ui-tabs-panel').length-1;
		// 	$('#tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
		// }
		// Fire search
		$('#loading_searchadv').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$('#loading_searchadv2').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$(thediv).load('index.cfm?fa=' + thefa, { thetype: "aud", search_type: 'adv', folder_id: folderid, searchtext: searchtext, on_day: document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value, on_month: document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value, on_year: document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, change_day: document.forms[theform].change_day.options[document.forms[theform].change_day.selectedIndex].value, change_month: document.forms[theform].change_month.options[document.forms[theform].change_month.selectedIndex].value, change_year: document.forms[theform].change_year.options[document.forms[theform].change_year.selectedIndex].value }, function(){
			// Hide Window
			destroywindow(1);
		});
	}
}
// Fire off search all
function searchadv_all(theform, thefa) {
	// Call subfunction to get fields
	var searchtext = subadvfields(theform);
	// Encode searchtext
	var searchtext = encodeURIComponent(searchtext);
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// get the first postion
	var p1 = searchtext.substr(searchtext,1);
	// Now check
	if (illegalChars.test(p1)){
		alert('The first character of your search string is an illegal one. Please remove it!');
	}
	else {
		// If we come from a folder search we direct into the folder view
		// if (folderid == '0'){
		
		var thediv = '#rightside';

		// Get folderid
		var folderid = $('#adv_folder_id').val();

		// }
		// else {
		// 	var thediv = '#content_search_all';
		// 	// Enable div
		// 	$('#content_search_all').css('display','');
		// 	// Remove tab (in case there is one already)
		// 	removeTab('tabsfolder_tab','content_search_all');
			
		// 	// Create new tab
		// 	addTab($('#tabsfolder_tab'), 'content_search_all' , 'Search Results');
			
		// 	// Select tab
		// 	var index = $('#tabsfolder_tab div.ui-tabs-panel').length-1;
		// 	$('#tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
			
		// }
		// Fire search
		$('#loading_searchadv').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$('#loading_searchadv2').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		$(thediv).load('index.cfm?fa=' + thefa, { thetype: "all", search_type: 'adv', folder_id: folderid, searchtext: searchtext, on_day: document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value, on_month: document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value, on_year: document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, change_day: document.forms[theform].change_day.options[document.forms[theform].change_day.selectedIndex].value, change_month: document.forms[theform].change_month.options[document.forms[theform].change_month.selectedIndex].value, change_year: document.forms[theform].change_year.options[document.forms[theform].change_year.selectedIndex].value }, function(){
			// Hide Window
			destroywindow(1);
		});
	}
}

function addTab(tabs, id, label){
	li = "<li><a href='#"+ id +"'>"+ label +"</a></li>";
	tabs.find( ".ui-tabs-nav" ).append( li );
	tabs.append( "<div id='" + id + "'><p></p></div>" );
	tabs.tabs( "refresh" );
} 

function removeTab(tabContainerID,tabID){
	$('#'+tabContainerID+' li a[href="#'+tabID+'"]').remove();
	$('#'+tabContainerID+' div#'+tabID).remove();
	$('#'+tabContainerID).tabs( "refresh" );
}
function getIndexForId( tabsDivId, searchedId )
{
	var index = -1;
	var i = 0, els = $("#" + tabsDivId).find("a");
	var l = els.length, e;
	while ( i < l && index == -1 ) {
		e = els[i];
		var tabName=$(e).find("span").html();
		if (searchedId == tabName) {//$(e).attr('href'))
			index = i;
		}
		i++;
	};
	return index;
}
function emptybasket(){
	loadcontent('rightside','index.cfm?fa=c.basket_full_remove_all');
	// setTimeout("loadbasket()", 1250);
	destroywindow(1);
}
function loadbasket(){
	loadcontent('basket','index.cfm?fa=c.basket');
}
function subadvfieldsdoc(theform,searchtext){
	// Get values
	var author = document.forms[theform].author.value;
	var authorsposition = document.forms[theform].authorsposition.value;
	var captionwriter = document.forms[theform].captionwriter.value;
	var webstatement = document.forms[theform].webstatement.value;
	var rights = document.forms[theform].rights.value;
	var rightsmarked = document.forms[theform].rightsmarked.value;
	var andor = document.forms[theform].andor.options[document.forms[theform].andor.selectedIndex].value;
	// Put together the search
	if (author != '') var author = 'author:(' + author + ')';
	if (authorsposition != '') var authorsposition = 'authorsposition:(' + authorsposition;
	if (captionwriter != '') var captionwriter = 'captionwriter:(' + captionwriter+ ')';
	if (webstatement != '') var webstatement = 'webstatement:(' + webstatement;+ ')'
	if (rights != '') var rights = 'rights:' + rights;
	if (rightsmarked != '') var rightsmarked = 'rightsmarked:(' + rightsmarked+ ')';
	// Create the searchtext
	if (searchtext != '' && author != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + author;
	}
	else {
		var searchtext = searchtext + author;
	}
	if (searchtext != '' && authorsposition != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + authorsposition;
	}
	else {
		var searchtext = searchtext + authorsposition;
	}
	if (searchtext != '' && captionwriter != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + captionwriter;
	}
	else {
		var searchtext = searchtext + captionwriter;
	}
	if (searchtext != '' && webstatement != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + webstatement;
	}
	else {
		var searchtext = searchtext + webstatement;
	}
	if (searchtext != '' && rights != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + rights;
	}
	else {
		var searchtext = searchtext + rights;
	}
	if (searchtext != '' && rightsmarked != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + rightsmarked;
	}
	else {
		var searchtext = searchtext + rightsmarked;
	}
	return searchtext;
}
function subadvfieldsimg(theform,searchtext){
	// Get values
	var subjectcode = document.forms[theform].subjectcode.value;
	var creator = document.forms[theform].creator.value;
	var title = document.forms[theform].title.value;
	var authorsposition = document.forms[theform].authorsposition.value;
	var captionwriter = document.forms[theform].captionwriter.value;
	var ciadrextadr = document.forms[theform].ciadrextadr.value;
	var category = document.forms[theform].category.value;
	var supplementalcategories = document.forms[theform].supplementalcategories.value;
	var urgency = document.forms[theform].urgency.value;
	var ciadrcity = document.forms[theform].ciadrcity.value;
	var ciadrctry = document.forms[theform].ciadrctry.value;
	var location = document.forms[theform].location.value;
	var ciadrpcode = document.forms[theform].ciadrpcode.value;
	var ciemailwork = document.forms[theform].ciemailwork.value;
	var ciurlwork = document.forms[theform].ciurlwork.value;
	var citelwork = document.forms[theform].citelwork.value;
	var intellectualgenre = document.forms[theform].intellectualgenre.value;
	var instructions = document.forms[theform].instructions.value;
	var source = document.forms[theform].source.value;
	var usageterms = document.forms[theform].usageterms.value;
	var copyrightstatus = document.forms[theform].copyrightstatus.value;
	var transmissionreference = document.forms[theform].transmissionreference.value;
	var webstatement = document.forms[theform].webstatement.value;
	var headline = document.forms[theform].headline.value;
	var datecreated = document.forms[theform].datecreated.value;
	var city = document.forms[theform].city.value;
	var ciadrregion = document.forms[theform].ciadrregion.value;
	var country = document.forms[theform].country.value;
	var countrycode = document.forms[theform].countrycode.value;
	var scene = document.forms[theform].scene.value;
	var state = document.forms[theform].state.value;
	var credit = document.forms[theform].credit.value;
	var rights = document.forms[theform].rights.value;
	var andor = document.forms[theform].andor.options[document.forms[theform].andor.selectedIndex].value;
	// Put together the search
	if (subjectcode != '') var subjectcode = 'subjectcode:(' + subjectcode + ')';
	if (creator != '') var creator = 'creator:(' + creator+ ')';
	if (title != '') var title = 'title:(' + title+ ')';
	if (authorsposition != '') var authorsposition = 'authorsposition:(' + authorsposition+ ')';
	if (captionwriter != '') var captionwriter = 'captionwriter:(' + captionwriter+ ')';
	if (ciadrextadr != '') var ciadrextadr = 'ciadrextadr:(' + ciadrextadr+ ')';
	if (category != '') var category = 'category:(' + category+ ')';
	if (supplementalcategories != '') var supplementalcategories = 'supplementalcategories:(' + supplementalcategories+ ')';
	if (urgency != '') var urgency = 'urgency:(' + urgency+ ')';
	if (ciadrcity != '') var ciadrcity = 'ciadrcity:(' + ciadrcity+ ')';
	if (ciadrctry != '') var ciadrctry = 'ciadrctry:(' + ciadrctry+ ')';
	if (location != '') var location = 'location:(' + location+ ')';
	if (ciadrpcode != '') var ciadrpcode = 'ciadrpcode:(' + ciadrpcode+ ')';
	if (ciemailwork != '') var ciemailwork = 'ciemailwork:(' + ciemailwork+ ')';
	if (ciurlwork != '') var ciurlwork = 'ciurlwork:(' + ciurlwork+ ')';
	if (citelwork != '') var citelwork = 'citelwork:(' + citelwork+ ')';
	if (intellectualgenre != '') var intellectualgenre = 'intellectualgenre:(' + intellectualgenre+ ')';
	if (instructions != '') var instructions = 'instructions:(' + instructions+ ')';
	if (source != '') var source = 'source:(' + source+ ')';
	if (usageterms != '') var usageterms = 'usageterms:(' + usageterms+ ')';
	if (copyrightstatus != '') var copyrightstatus = 'copyrightstatus:(' + copyrightstatus+ ')';
	if (transmissionreference != '') var transmissionreference = 'transmissionreference:(' + transmissionreference+ ')';
	if (webstatement != '') var webstatement = 'webstatement:(' + webstatement+ ')';
	if (headline != '') var headline = 'headline:(' + headline+ ')';
	if (datecreated != '') var datecreated = 'datecreated:(' + datecreated+ ')';
	if (city != '') var city = 'city:(' + city+ ')';
	if (ciadrregion != '') var ciadrregion = 'ciadrregion:(' + ciadrregion+ ')';
	if (country != '') var country = 'country:(' + country+ ')';
	if (countrycode != '') var countrycode = 'countrycode:(' + countrycode+ ')';
	if (scene != '') var scene = 'scene:(' + scene+ ')';
	if (state != '') var state = 'state:(' + state+ ')';
	if (credit != '') var credit = 'credit:(' + credit+ ')';
	if (rights != '') var rights = 'rights:(' + rights+ ')';
	// Create the searchtext
	if (searchtext != '' && subjectcode != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + subjectcode;
	}
	else {
		var searchtext = searchtext + subjectcode;
	}
	if (searchtext != '' && creator != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + creator;
	}
	else {
		var searchtext = searchtext + creator;
	}
	if (searchtext != '' && title != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + title;
	}
	else {
		var searchtext = searchtext + title;
	}
	if (searchtext != '' && authorsposition != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + authorsposition;
	}
	else {
		var searchtext = searchtext + authorsposition;
	}
	if (searchtext != '' && captionwriter != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + captionwriter;
	}
	else {
		var searchtext = searchtext + captionwriter;
	}
	if (searchtext != '' && ciadrextadr != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciadrextadr;
	}
	else {
		var searchtext = searchtext + ciadrextadr;
	}
	if (searchtext != '' && category != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + category;
	}
	else {
		var searchtext = searchtext + category;
	}
	if (searchtext != '' && supplementalcategories != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + supplementalcategories;
	}
	else {
		var searchtext = searchtext + supplementalcategories;
	}
	if (searchtext != '' && urgency != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + urgency;
	}
	else {
		var searchtext = searchtext + urgency;
	}
	if (searchtext != '' && ciadrcity != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciadrcity;
	}
	else {
		var searchtext = searchtext + ciadrcity;
	}
	if (searchtext != '' && ciadrctry != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciadrctry;
	}
	else {
		var searchtext = searchtext + ciadrctry;
	}
	if (searchtext != '' && location != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + location;
	}
	else {
		var searchtext = searchtext + location;
	}
	if (searchtext != '' && ciadrpcode != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciadrpcode;
	}
	else {
		var searchtext = searchtext + ciadrpcode;
	}
	if (searchtext != '' && ciemailwork != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciemailwork;
	}
	else {
		var searchtext = searchtext + ciemailwork;
	}
	if (searchtext != '' && ciurlwork != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciurlwork;
	}
	else {
		var searchtext = searchtext + ciurlwork;
	}
	if (searchtext != '' && citelwork != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + citelwork;
	}
	else {
		var searchtext = searchtext + citelwork;
	}
	if (searchtext != '' && intellectualgenre != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + intellectualgenre;
	}
	else {
		var searchtext = searchtext + intellectualgenre;
	}
	if (searchtext != '' && instructions != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + instructions;
	}
	else {
		var searchtext = searchtext + intellectualgenre;
	}
	if (searchtext != '' && source != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + source;
	}
	else {
		var searchtext = searchtext + source;
	}
	if (searchtext != '' && usageterms != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + usageterms;
	}
	else {
		var searchtext = searchtext + usageterms;
	}
	if (searchtext != '' && copyrightstatus != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + copyrightstatus;
	}
	else {
		var searchtext = searchtext + copyrightstatus;
	}
	if (searchtext != '' && transmissionreference != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + transmissionreference;
	}
	else {
		var searchtext = searchtext + transmissionreference;
	}
	if (searchtext != '' && webstatement != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + webstatement;
	}
	else {
		var searchtext = searchtext + webstatement;
	}
	if (searchtext != '' && headline != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + headline;
	}
	else {
		var searchtext = searchtext + headline;
	}
	if (searchtext != '' && datecreated != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + datecreated;
	}
	else {
		var searchtext = searchtext + datecreated;
	}
	if (searchtext != '' && city != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + city;
	}
	else {
		var searchtext = searchtext + city;
	}
	if (searchtext != '' && ciadrregion != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + ciadrregion;
	}
	else {
		var searchtext = searchtext + ciadrregion;
	}
	if (searchtext != '' && country != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + country;
	}
	else {
		var searchtext = searchtext + country;
	}
	if (searchtext != '' && countrycode != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + countrycode;
	}
	else {
		var searchtext = searchtext + countrycode;
	}
	if (searchtext != '' && scene != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + scene;
	}
	else {
		var searchtext = searchtext + scene;
	}
	if (searchtext != '' && state != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + state;
	}
	else {
		var searchtext = searchtext + state;
	}
	if (searchtext != '' && credit != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + credit;
	}
	else {
		var searchtext = searchtext + credit;
	}
	if (searchtext != '' && rights != '') {
		var searchtext = searchtext + ' ' + andor + ' ' + rights;
	}
	else {
		var searchtext = searchtext + rights;
	}	
	return searchtext;
}
// Focus tree
function razunatreefocus(folderid){

	try {
		setTimeout(function() {
			razunatreefocusdelay(folderid);
		}, 1250)
	}
	catch(e) {};
}
function razunatreefocusbranch(folderidr,folderid){
	try{
		$.tree.focused().open_branch('#' + folderidr);
		$.tree.focused().select_branch('#' + folderid);
	}
	catch(e) {};
}
function razunatreefocusdelay(folderid){
	try{
		$.tree.focused().select_branch('#' + folderid);
	}
	catch(e) {};
}
// Toggle Slide
function toggleslide(theclickid,thefield){
	$('#' + theclickid).slideToggle('slow');
	$('#' + thefield).select();
	$('#' + thefield).click(function(){ 
		this.select(); 
	});
	$('#' + thefield + 'd').click(function(){ 
		this.select(); 
	});
};
function SetVideo(source, title) {
	//$('#videoPlayerDiv').dialog('destroy');
	$('#videoPlayerDiv').dialog({
		title: title,
		modal: true,
		autoOpen: false,
		width: 830,
		height: 'auto',
		position: 'top',
		//minHeight: 600,
		overlay: {
			backgroundColor: '#000',
			opacity: 0.5
		}
	});
	$('#introRazVideo').attr('src', source);
	// Open window
	$('#videoPlayerDiv').dialog('open');
	$('#videoPlayerDiv').dialog({
		close: function(event, ui) {
			$('#introRazVideo').attr('src','');
			$('#videoPlayerDiv').dialog('destroy');
		}
	});
	// $('.ui-widget-overlay').click(function(){
		
	// 	$('#introRazVideo').attr('src','');
	// 	$('#videoPlayerDiv').dialog('destroy');
	// });
}
// Focus tree
function loadfolderwithdelay(folderid){
	try {
		setTimeout(function() {
			loadfolder(folderid);
		}, 1500)
	}
	catch(e) {};
}
function loadfolder(folderid){
	try {
		$('#rightside').load('index.cfm?fa=c.folder&folder_id=' + folderid);
	}
	catch(e) {};
}
// Check for same folder name
function samefoldernamecheck(theid){
	// Values
	var foldername = $("#folder_name").val();
	var folderidr = $("#rid").val();
	$('#samefoldername').load('index.cfm?fa=c.folder_namecheck', { folder_name:foldername, folder_id_r:folderidr, folder_id:theid } );
}
// Check for invalid characters in folder name
function foldernamecheck_invalidchars(theid){
	// Values
	var foldername = $("#folder_name").val();
	var folderidr = $("#rid").val();
	$('#invalidchars').load('index.cfm?fa=c.folder_name_invalidchars', { folder_name:foldername, folder_id_r:folderidr, folder_id:theid} );
}
// Check for same collection name
function samecollectionnamecheck(theid){
	// Values
	var colname = $("#collectionname").val();
	var folder_id = $("#folder_id").val();
	$('#samecollectionname').load('index.cfm?fa=c.collection_namecheck', { collection_name:colname, col_id:theid, folder_id:folder_id } );
}
// Reset DL
function resetdl(divorg,divthumb,folderid,thestatusddiv){
	var thevalue = $('#' + divorg + ':checked').val();
	if (thevalue == 'T'){
		thevalue = 1;
	}
	else{
		thevalue = 0;
	}
	var thevaluethumb = $('#' + divthumb + ':checked').val();
	if (thevaluethumb == 'T'){
		thevaluethumb = 1;
	}
	else{
		thevaluethumb = 0;
	}
	// For collections the collectionid is sent instead of folderid
	if (thestatusddiv=='colreset')
		$('#div_forall').load('index.cfm?fa=c.share_reset_dl&collection_id=' + folderid + '&setto=' + thevalue + '&settothumb=' + thevaluethumb);
	else
		$('#div_forall').load('index.cfm?fa=c.share_reset_dl&folder_id=' + folderid + '&setto=' + thevalue + '&settothumb=' + thevaluethumb);

	$('#' + thestatusddiv + '_thumb').html('Reset all individual download setting successfully');
	$('#' + thestatusddiv + '_org').html('Reset all individual download setting successfully');
}
// Switch section
function switchmainselection(thetype,thelinktext){
	// Load section
	if (thetype == 'folders'){
		$('#explorer').load('index.cfm?fa=c.explorer');
	}
	else if (thetype == 'collections'){
		$('#explorer').load('index.cfm?fa=c.explorer_col');
	}
	else if (thetype == 'labels'){
		$('#explorer').load('index.cfm?fa=c.labels_list');
	}
	else if (thetype == 'smart_folders'){
		$('#explorer').load('index.cfm?fa=c.smart_folders');
	}
	// Toogle
	$('#mainselection').toggle();
	// Remove the image in all marks
	$('#section_folders').html('&nbsp;');
	$('#section_smart_folders').html('&nbsp;');
	$('#section_collections').html('&nbsp;');
	$('#section_labels').html('&nbsp;');
	// Now set the correct CSS
	$('#section_folders').css({'float':'left','padding-right':'14px','padding-top':'3px'});
	$('#section_smart_folders').css({'float':'left','padding-right':'14px','padding-top':'3px'});
	$('#section_collections').css({'float':'left','padding-right':'14px','padding-top':'3px'});
	$('#section_labels').css({'float':'left','padding-right':'14px','padding-top':'3px'});
	// Now mark the div
	$('#section_' + thetype).css({'float':'left','padding-right':'3px'});
	$('#section_' + thetype).html('<img src="' + dynpath + '/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0">');
	// Change the link text itself
	$('#mainsectionchooser').text(thelinktext);
}
// Image Tooltip
$(document).tooltip({
	items: "[img-tt]",
	show: { delay: 800 },
	content: function() {
		 var element = $( this );
		 var theimg = element.attr("src");
		 return "<img src='" + theimg + "' border='0' style='max-width:400px;max-height:400px;'>";
	},
	position: {
		my: "center bottom",
		at: "center top",
		collision: "flipfit"
	}
});
// Remove label while click on X
function removeLabel(assetID,assetType,labelID,aHrefElement,text){
	//console.log(aHrefElement);
	$(aHrefElement).parent('.singleLabel').remove();
	loadcontent('div_forall','index.cfm?fa=c.asset_label_add_remove&fileid=' +assetID+ '&thetype=' +assetType+ '&checked=false&labels=' + labelID);
	// For RAZ-2708 Advanced Search : Check the condition for remove labels
	if (assetID != '0') {
		$.sticky(text);
	}
}
//Check the label name, first char should be charactors or numbers
function isValidLabel(labelName){
	var exp = new RegExp(/^[^a-zA-Z0-9]/g);
	return !exp.test($('#'+labelName).val());
		
}
