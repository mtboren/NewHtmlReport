<#	.Description
	Code to encapsulate the creation of HTML report files from objects.  May 2013, Matt Boren
	.Example
	New-HtmlReport -InputObject (dir c:\temp -filter *txt) -PreContent "blahh0","blahh1" -CssUri "/someFolder/someFile.css" -Property Name,LastWriteTime -Title "another test of output"
	Create HTML output for an array of objects, with given stylesheet, and using built-in HTML for creating sortable table
	.Example
	Get-VMHost | Select-Object Name,ConnectionState,MemoryTotalGB,@{n="bDoRowHighlight"; e={$_.ConnectionState -ne "Connected"}} | New-HtmlReport -Title "My VMHost Report" -PreContent "<H3>VMHosts Info</H3>" -PostContent "Generated $(Get-Date -Format 'yyyy-MMM-dd HH:mm:ss \G\M\Tz')" -TableCaption "highlighted rows are of VMHosts that are not in 'Connected' state" -RoundNumber -NumDecimalPlace 1 | Out-File -Encoding ascii c:\temp\myVMHostReport.htm
	Create an HTML report for some VMHosts, highlighting any row where the given VMhost is in a state other than "Connected", and write the HTML to a file
	.Example
	New-HtmlReport -Title "My Combined Report" -PostContent "<BR />",(New-PageBodyTableHtml -InputObject (Get-Cluster) -Property Name, EVCMode, VsanEnabled) -InputObject (Get-Datastore) -Property Name,FreeSpaceGB,CapacityGB -RoundNumber -PreContent "<H3>Combined report of datastores and clusters</H3>" | Out-File -Encoding ascii c:\temp\myCombinedReport.htm
	Create an HTML report for a few things:  the Datastores in the current vCenter, and the clusters there as well. Then, write the HTML to a file.  Maybe not the most common/useful data to combine in a single report, but this example is to show how to place multiple interactive tables into the same new HTML report
	.Outputs
	String
#>
function New-HtmlReport {
	[CmdletBinding()]
	param(
		## The Uniform Resource Identifier (URI) of the CSS to apply to the HTML; examples:  "http://myserver.com/mystyle.css" or "/incl/style.css"
		[string]$CssUri,
		## Homogenous input objects (all have the same properties defined) from which to make the HTML table in the new report
		[parameter(ValueFromPipeline=$true, Mandatory=$true)][PSObject[]]$InputObject,
		## Text/HTML to add after the closing </TABLE> tag
		[string[]]$PostContent,
		## Text/HTML to add before the opening <TABLE> tag
		[string[]]$PreContent,
		## The properties of the input objects to use in the output; if not specified, all properties are output
		[string[]]$Property,
		## String to place in the <title> </title> tag in the <HEAD> </HEAD>
		[string]$Title,
		## String to use as caption for table in output
		[string]$TableCaption,
		## Switch:  Round numbers to sum number of decimal places?
		[parameter(ParameterSetName="RoundNumbers")][switch]$RoundNumber,
		## Number of decimal places to which to round. Default is zero.
		[parameter(ParameterSetName="RoundNumbers")][int]$NumDecimalPlace = 0
	) ## end param

	begin {
		## the ModuleManifest, via ScriptsToProcess, "imports" the default values from the given config file <thisModuleDir>\New-HtmlReport_configItems.ps1
		<# values that were imported from the default values file:  $hshConfigItems_NewHtmlReport with keys:
			CssUri
			HeadHtmlValue_NoTitleTag
			TitleHtml
			SortableTableCssClass
		#>
		## the start of the TABLE HTML
		$strTableStartHtml = "`n<TABLE CLASS='$($hshConfigItems_NewHtmlReport["SortableTableCssClass"])'>"
		## add caption tag to table, if given param is not $null
		if ($null -ne $TableCaption) {$strTableStartHtml += "`n<CAPTION CLASS='tblCaption'>$TableCaption</CAPTION>"}
		## the finish of the TABLE HTML
		$strTableFinishHtml = "</TABLE>"

		## make string of the one or more PreContent strings
		$strPreContent = if ($PSBoundParameters.ContainsKey("PreContent")) {$PreContent -join "<BR />`n"}
		## make string of the one or more PreContent strings
		$strPostContent = if ($PSBoundParameters.ContainsKey("PostContent")) {$PostContent -join "<BR />`n"}

		## an array in which to keep the input object to eventually be used in the end{} scriptblock
		$arrInputObj = @()
	} ## end begin

	process {$arrInputObj += $InputObject}

	end {
		$hshParamsForNewPageBodyTable = @{
			InputObject = $arrInputObj
			Property = $Property
			TableStartHtml = $strTableStartHtml
			TableFinishHtml = $strTableFinishHtml
		} ## end hsh
		if ($RoundNumber) {$hshParamsForNewPageBodyTable["RoundNumber"] = $true; $hshParamsForNewPageBodyTable["NumDecimalPlace"] = $NumDecimalPlace}

		## make new object that holds all of the items to be passed to ConvertTo-Html cmdlet (or references to the variables with said info):
		$hshConfigForConverttoHtml = @{
			CssUri = if ($CssUri) {$CssUri} else {$hshConfigItems_NewHtmlReport["CssUri"]}
			## generate the Pre / Body table / Post content string for the body
			Body = ($strPreContent, (New-PageBodyTableHtml @hshParamsForNewPageBodyTable), $strPostContent) -join "`n"
			Head = "<TITLE>$(if ($Title) {$Title} else {$hshConfigItems_NewHtmlReport["TitleHtml"]})</TITLE>`n$($hshConfigItems_NewHtmlReport["HeadHtmlValue_NoTitleTag"])"
		} ## end hsh

		## do the actual ConvertTo-Html, using (splatting) the given hashtable for params
		ConvertTo-Html @hshConfigForConverttoHtml
	} ## end end
}

<#	.Description
	Function to make, for the body of the whole HTML page to create, table strings from input objects; returns HTML code for the table to represent the info the in array of objects passed in.  The special property, "bDoRowHighlight", will trigger the highlighting of that object's row in the resultant HTML table.  This means that the row is assigned a particular CSS class, which will presumably have a different style such that the text in that row will be "highlighted" with the style specified in the CSS file used.
	.Example
	New-PageBodyTableHtml -InputObject (Get-ChildItem C:\temp | Select Name,@{n="LengthMB"; e={$_.Length / 1MB}},LastWriteTime) -RoundNumber -NumDecimalPlace 2
	Makes HTML for a table that has the three properties of the input objects, and rounds number values to two decimal places
	.Example
	New-PageBodyTableHtml -InputObject (Get-VMHost | Select Name,ConnectionState,MemoryTotalGB,@{n="bDoRowHighlight"; e={if ($_.ConnectionState -ne "Connected") {$true}}}) -RoundNumber -NumDecimalPlace 1
	Makes HTML for a table that has the three properties of the input objects, rounds number values to two decimal places, and highlights any row where the ConnectionState was not "Connected".  This row highlighting is achieved by adding a "bDoRowHighlight" property with a value of $true to the given object whose row to highlight
	.Outputs
	String
#>
function New-PageBodyTableHtml {
	param (
		## Object(s) from which to make HTML table
		[parameter(Mandatory=$true)][PSObject[]]$InputObject,
		## The properties of the input object(s) to use in the output; if none specified, all of the object's properties are output
		[string[]]$Property,
		## The starting HTML to use for the table
		[string]$TableStartHtml = "`n<TABLE CLASS='$($hshConfigItems_NewHtmlReport["SortableTableCssClass"])'>",
		## The ending HTML to use for the table
		[string]$TableFinishHtml = "</TABLE>",
		## Switch:  Round numbers to sum number of decimal places?
		[parameter(ParameterSetName="RoundNumbers")][switch]$RoundNumber,
		## Number of decimal places to which to round if rounding
		[parameter(ParameterSetName="RoundNumbers")][int]$NumDecimalPlace = 0
	) ## end param

	## the name of the property of an input object that signifies that that object's HTML row should be "highlighted" with style
	$strDoHighlightPropName = "bDoRowHighlight"

	## the NoteProperties of this input objects, excluding property by given "doHighlight" predefined name (see above)
	$arrNamesOfPropertiesToUse = if ($Property) {$Property} else {$InputObject | Get-Member -MemberType *Property* | Where-Object {$_.Name -ne $strDoHighlightPropName} | Foreach-Object {$_.Name} | Select-Object -Unique}

	$strTableHeadHtml = @"
<THEAD>
	<TR>$(# make the header items here, taking the specified properties into acct
		foreach ($strHeaderName in $arrNamesOfPropertiesToUse) {"<TH>$strHeaderName</TH>"}
)</TR>
</THEAD>
"@

	$strTableBodyHtml = @"
<TBODY>
	$(# iterate through and make all the body TRs, taking the specified properties into acct
		$(foreach ($oItemToOuput in $InputObject) {
			## if this row is to be "highlighted" with row-highlighting style, make a class string for it
			$strRowStyle = if ($true -eq $oItemToOuput.${strDoHighlightPropName}) {" CLASS='highlightRow'"} else {$null}
			"<TR${strRowStyle}>$(foreach ($strPropertyName in $arrNamesOfPropertiesToUse) {"<TD>$(if ($RoundNumber -and [Double]::TryParse($oItemToOuput.$strPropertyName, [ref]$null)) {[Math]::Round($oItemToOuput.$strPropertyName, $NumDecimalPlace)} else {$oItemToOuput.$strPropertyName})</TD>"})</TR>"
		}) -join "`n`t"
	)
</TBODY>
"@

	($TableStartHtml, $strTableHeadHtml, $strTableBodyHtml, $TableFinishHtml) -join "`n"
} ## end function


Export-ModuleMember -Function New-HtmlReport,New-PageBodyTableHtml
## workaround for PowerShell bug that adds ScriptsToProcess items as a module, which shows up at Get-Module time
Remove-Module -Name New-HtmlReport_configItems