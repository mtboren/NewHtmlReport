<#	.Description
	config items to be used for creating wonderful reporting output in structured way, from one or more input objects.  May, 2013 -- Matt Boren
	This config file gets consumed by main report module
#>

## path to root of web server (or given folder to use as root), with _no_ trailing slash; comment out to have resulting URIs be absolute, but only from the current web root (not fully qualified)
$strWebServerRootUri = "http://somewebserver.dom.com"

## the path to the jQuery JS file on the web server (or on another web server)
$strDefaultJQueryJSUri = "$strWebServerRootUri/scripts/jquery-1.9.1.min.js"
## the path to the TableSorter jQuery add-on JS file on the web server (or on another web server)
$strDefaultTableSorterJSUri = "$strWebServerRootUri/scripts/jquery.tablesorter.min.js"
## the path to the default CSS file to use
$strDefaultCssUri = "$strWebServerRootUri/incl/reportingDefault.css"
## the CSS class name to use for sortable tables
$strSortableTableCssClass = "tSorter"


## the default HTML to put into the HEAD tag
$strDefaultHeadHtml = @"
<script type="text/javascript" src="$strDefaultJQueryJSUri"></script>
<script type="text/javascript" src="$strDefaultTableSorterJSUri"></script>
<script type="text/javascript">
	// extend the default setting to always include the zebra widget (which does the alternating row background colors)
	`$.tablesorter.defaults.widgets = ['zebra'];
	// get the object of class "$strSortableTableCssClass" and call the TableSorter() method on it
	`$(document).ready(function() {`$(".$strSortableTableCssClass").tablesorter();} );
</script>
"@

## the default HTML to put into the TITLE tag
$strDefaultTitleHtml = "Reporting Info"
#### end of adjustable config items


## hashtable of default values for config items
$hshConfigItems_NewHtmlReport = @{
	CssUri = $strDefaultCssUri
	HeadHtmlValue_NoTitleTag = $strDefaultHeadHtml
	TitleHtml = $strDefaultTitleHtml
	SortableTableCssClass = $strSortableTableCssClass
} ## end hsh

## hashtable of internal configuration items for this module
$hshInternalConfigItems_NewHtmlReport = @{
	## filespecs of the module's stored configurations' files (current and module default (for resets))
	ModCfgJsonFilespec = "$PSScriptRoot\New-HtmlReport_config_stored.json"
	ModCfg_originalDefaults_JsonFilespec = "$PSScriptRoot\New-HtmlReport_config_stored_default.json"
} ## end hsh