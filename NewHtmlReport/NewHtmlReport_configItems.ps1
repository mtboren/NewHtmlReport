<#	.Description
	config items to be used for creating wonderful reporting output in structured way, from one or more input objects.  May, 2013 -- Matt Boren
	This config file gets consumed by main report module
#>


## the CSS class name to use for Tablesorter sortable tables
# $strTablesorterTableCssClass = "tSorter"
$strTablesorterTableCssClass = "tablesorter-default"

## the Tablesorter scriptblock code for the HEAD HTML tag; can be updated to add different Tablesorter widgets, for example
$strTablesorterHeadScriptblock = @"
<script type="text/javascript">
	// extend the default setting to always include the zebra widget (which does the alternating row background colors)
	`$.tablesorter.defaults.widgets = ['zebra'];
	// get the object of class "$strTablesorterTableCssClass" and call the TableSorter() method on it
	`$(document).ready(function() {`$(".$strTablesorterTableCssClass").tablesorter();} );
</script>
"@

## small bit of CSS to include by default
$strHtmlReportDefaultCssBlock = @"
<style>
/* for table caption */
table.$strTablesorterTableCssClass caption.tblCaption {
	caption-side: bottom;
	font-size: small;
	vertical-align: bottom;
}
/* for table rows that are to be "highlighted" */
table.$strTablesorterTableCssClass tbody tr.highlightRow td {color: #FF0000;}
/* for footer-type info areas */
.footerInfo {
	color: #666666;
	display: block;
	font-size: 12px;
	font-style: italic;
	margin-top: 5px;
}
</style>
"@
#### end of adjustable-by-consumer config items


## hashtable of internal configuration items for this module (not to be updated by standard module consumer)
$hshInternalConfigItems_NewHtmlReport = @{
	## filespecs of the module's stored configurations' files (current and module default (for resets))
	ModCfgJsonFilespec = "$PSScriptRoot\NewHtmlReport_config_stored.json"
	ModCfg_originalDefaults_JsonFilespec = "$PSScriptRoot\NewHtmlReport_config_stored_default.json"
	## the CSS class name to use for Tablesorter tables
	TablesorterTableCssClass = $strTablesorterTableCssClass
	## the HEAD HTML string that is the script block for TableSorter invocation/initiation
	TablesorterHeadScriptblock = $strTablesorterHeadScriptblock
} ## end hsh