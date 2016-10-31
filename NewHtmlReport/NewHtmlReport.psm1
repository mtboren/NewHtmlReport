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
		## the current Session configuration items
		$oCurrentSessionModuleConfig = Get-NewHtmlReportConfiguration -Scope Session

		## the ModuleManifest, via ScriptsToProcess, "imports" the default values from the given config file <thisModuleDir>\NewHtmlReport_configItems.ps1
		<# values that were imported from the default values file:  $hshInternalConfigItems_NewHtmlReport with keys:
			TablesorterHeadScriptblock
			TitleHtml
			TablesorterTableCssClass
		#>
		## the JS script blocks for including appropriate table-sorting libraries, to be used in the HEAD HTML tag
		$strTableSortingJSScriptblocksForHead = ("jQueryURI", "jQueryTableSorterURI" | Foreach-Object {"<script type='text/javascript' src='$($oCurrentSessionModuleConfig.$_)'></script>"}) -join "`n"

		## the start of the TABLE HTML tag, and with caption tag if given param is not $null or empty
		$strTableStartHtml = "`n<TABLE CLASS='$($hshInternalConfigItems_NewHtmlReport['TablesorterTableCssClass'])'>{0}" -f $(if (-not [System.String]::IsNullOrEmpty($TableCaption)) {"`n<CAPTION CLASS='tblCaption'>$TableCaption</CAPTION>"})

		## the finish of the TABLE HTML
		$strTableFinishHtml = "</TABLE>"

		## make string of the one or more PreContent strings
		$strPreContent = if ($PSBoundParameters.ContainsKey("PreContent")) {$PreContent -join "<BR />`n"}
		## make string of the one or more PreContent strings
		$strPostContent = if ($PSBoundParameters.ContainsKey("PostContent")) {$PostContent -join "<BR />`n"}

		## an ArrayList in which to keep the input object to eventually be used in the end{} scriptblock (better data structure than "normal" array in terms of performance for the appending that will occur in the process{} scriptblock, especially as the number of items grows)
		$arrlInputObj = New-Object -Type System.Collections.ArrayList
	} ## end begin

	process {
		## add this object to the ArrayList, grabbing the returned index value in a variable to never use
		$oIndexThisAdd = $arrlInputObj.Add($InputObject)
	} ## end process

	end {
		$hshParamsForNewPageBodyTable = @{
			InputObject = $arrlInputObj.GetEnumerator() | Foreach-Object {$_.Item(0)}
			TableStartHtml = $strTableStartHtml
			TableFinishHtml = $strTableFinishHtml
		} ## end hsh
		if ($PSBoundParameters.ContainsKey("Property")) {$hshParamsForNewPageBodyTable["Property"] = $Property}
		if ($RoundNumber) {$hshParamsForNewPageBodyTable["RoundNumber"] = $true; $hshParamsForNewPageBodyTable["NumDecimalPlace"] = $NumDecimalPlace}


		## make new object that holds all of the items to be passed to ConvertTo-Html cmdlet (or references to the variables with said info):
		$hshConfigForConverttoHtml = @{
			CssUri = if ($CssUri) {$CssUri} else {$oCurrentSessionModuleConfig.TableSorterCssURI}
			## generate the Pre / Body table / Post content string for the body
			Body = ($strPreContent, (New-PageBodyTableHtml @hshParamsForNewPageBodyTable), $strPostContent) -join "`n"
			## the HEAD HTML tag, with TITLE and any JS scriptblocks
			Head = "<TITLE>{0}</TITLE>`n{1}`n{2}" -f $(if ($PSBoundParameters.ContainsKey("Title")) {$Title} else {$oCurrentSessionModuleConfig.DefaultReportTitleHtml}), $strTableSortingJSScriptblocksForHead, $($hshInternalConfigItems_NewHtmlReport["TablesorterHeadScriptblock"])
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
		[string]$TableStartHtml = "`n<TABLE CLASS='$($hshInternalConfigItems_NewHtmlReport["TablesorterTableCssClass"])'>",
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
	$arrNamesOfPropertiesToUse = if ($PSBoundParameters.ContainsKey("Property")) {$Property} else {$InputObject | Get-Member -MemberType *Property* | Where-Object {$_.Name -ne $strDoHighlightPropName} | Foreach-Object {$_.Name} | Select-Object -Unique}

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



<#	.Description
	Function to get the current configuration for the NewHtmlReport module
	.Example
	Get-NewHtmlReportConfiguration
	Gets the current configuration (all scopes) for the NewHtmlReport module
	.Example
	Get-NewHtmlReportConfiguration
	Gets the current configuration for the Session scope for the NewHtmlReport module
	.Outputs
	PSCustomObject
#>
function Get-NewHtmlReportConfiguration {
	[CmdletBinding()]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param(
		## The scope from which to get the NewHtmlReport configuration:  AllUsers or Session, where Session is just the volatile set of setting that exist in _this_ PowerShell session. If not specified, all scopes' configurations are returned
		[ValidateSet("AllUsers", "Session")][String[]]$Scope
	) ## end param

	process {
		## $hshInternalConfigItems_NewHtmlReport is a module-private variable with module-specific configuration information, defined in New-HtmlReport_configItems.ps1
		if (-not (Get-Variable -Name "arrNewHtmlReportConfigs_current" -ErrorAction:SilentlyContinue)) {
			Write-Verbose "script-scope var 'arrNewHtmlReportConfigs_current' not present, yet -- creating now"
			## get the configuration from the given, "persistent configuration" JSON filespec
			$script:arrNewHtmlReportConfigs_current = _Get-NewHtmlConfigFromJsonFile -JsonFilespec $script:hshInternalConfigItems_NewHtmlReport["ModCfgJsonFilespec"]
		} ## end if

		## if a particular scope is desired, return just it
		if ($PSBoundParameters.ContainsKey("Scope")) {return ($script:arrNewHtmlReportConfigs_current | Where-Object {$Scope -contains $_.Scope})}
		else {return $script:arrNewHtmlReportConfigs_current}
	} ## end process
} ## end function


<#	.Description
	Internal helper function for getting the configuration from a given JSON filespec
#>
function _Get-NewHtmlConfigFromJsonFile {
	param(
		## Full path to JSON file that holds configuration data, from which to get the stored config for the module
		[String]$JsonFilespec
	) ## end param
	process {
		## get the JSON text from the given filespec, to be used to return objects containing configuration information
		$strTmpCurrentCfgJsonTxtFromDisk = Get-Content -Path $JsonFilespec | Out-String
		## create objects of current configs, one for each scope
		"AllUsers","Session" | Foreach-Object {
			$strThisScopeName = $_
			$oCurrentCfgFromJson = $strTmpCurrentCfgJsonTxtFromDisk | ConvertFrom-Json
			$oCurrentCfgFromJson."Scope" = $strThisScopeName
			$oCurrentCfgFromJson
		} ## end foreach-object
	} ## end process
} ## end internal function


<#	.Description
	Function to set the configuration option(s) for the given scope(s) for the NewHtmlReport module.

	Note:  When updating the configuration for the AllUsers scope, the function expects that the user as which PowerShell is running has Write filesystem rights at the location where this module's files reside -- the AllUser configuration is stored in a JSON file therein.  Else, if the module's files are in some read-only location, the user will only be able to set the configuration in the Session scope (does not write to disk).
	.Example
	Set-NewHtmlReportConfiguration -Scope AllUsers -jQueryURI https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js
	Sets the jQueryURI configuration item value for the AllUsers scope (does not affect current session setting)
	.Example
	Set-NewHtmlReportConfiguration -jQueryURI https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js
	Sets the jQueryURI configuration item value for the current PowerShell Session's scope (persists in the current PowerShell session, except if this PowerShell module is re-imported with the -Force parameter)
	.Outputs
	PSCustomObject
#>
function Set-NewHtmlReportConfiguration {
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param(
		## The scope for which to save this configuration setting. AllUsers writes configuration update to the module directory, Session only updates the configuration in the current PowerShell session. If not specified, only "Session" configuration is changed
		[ValidateSet("AllUsers", "Session")][String[]]$Scope = "Session",
		## URI at which resides the jquery.js variant to use
		[ValidateNotNullOrEmpty()][String]$jQueryURI,
		## URI at which resides the TableSorter jQuery add-on JS file to use
		[ValidateNotNullOrEmpty()][String]$jQueryTableSorterURI,
		## URI at which resides the default CSS file to use for this module, if using TableSorter for the table-management in the HTML
		[ValidateNotNullOrEmpty()][String]$TableSorterCssURI,
		## The default HTML to put into the TITLE tag for the resulting HTML output, to be used if not overridden by parameters to creating new HTML reports
		[ValidateNotNullOrEmpty()][String]$DefaultReportTitleHtml
	) ## end param

	begin {
		## the Configuration settings' parameter names to check/use
		$arrPossibleConfigSettingNames = Write-Output jQueryURI, jQueryTableSorterURI, TableSorterCssURI, DefaultReportTitleHtml
	} ## end begin

	process {
		$arrNamesOfSettingsToUpdate = $PSBoundParameters.Keys | Where-Object {$arrPossibleConfigSettingNames -contains $_}
		$strMessageForShouldProcess = "Update {0} setting{1}" -f $arrNamesOfSettingsToUpdate.Count, $(if (($arrNamesOfSettingsToUpdate | Measure-Object).Count -gt 1) {"s"})
		$strTargetForShouldProcess = "{0} scope{1}" -f $($Scope -join ", "), $(if (($Scope | Measure-Object).Count -gt 1) {"s"})
		if ($PSCmdlet.ShouldProcess($strTargetForShouldProcess, $strMessageForShouldProcess)) {
			## do the actual setting of values
			$arrNamesOfSettingsToUpdate | Foreach-Object {
				## the configuration item name to set
				$strThisParamName = $_
				## for the configuration objects of the given scope(s), set the given config property to the specified value
				$script:arrNewHtmlReportConfigs_current | Where-Object {$Scope -contains $_.Scope} | Foreach-Object {$_.$strThisParamName = $PSBoundParameters[$strThisParamName]}
			} ## end foreach-object

			## if the AllUsers scope is included in this set, write out the configuration to disks
			if ($Scope -contains "AllUsers") {
				Write-Verbose "writing updated AllUsers configuration to persistence data file at '$($script:hshInternalConfigItems_NewHtmlReport["ModCfgJsonFilespec"])'"
				$script:arrNewHtmlReportConfigs_current | Where-Object {$_.Scope -eq "AllUsers"} | Convertto-Json | Out-File -Encoding utf8 -FilePath $script:hshInternalConfigItems_NewHtmlReport["ModCfgJsonFilespec"]
			} ## end if

			## return the updated in-memory configurations
			return $script:arrNewHtmlReportConfigs_current
		} ## end if
	} ## end process
} ## end function


<#	.Description
	Function to get the reset the current configurations for all scopes for the NewHtmlReport module to the original values that were the defaults that came with the module itself. This overwrites any customized module settings with the orignal, "factory default" values.

	Note:  This expects that the user as which PowerShell is running has Write filesystem rights at the location where this module's files reside -- the AllUser configuration is stored in a JSON file therein.
	.Example
	Reset-NewHtmlReportConfiguration
	Resets to "factory defaults" the configuration (all scopes) for the NewHtmlReport module
	.Outputs
	PSCustomObject
#>
function Reset-NewHtmlReportConfiguration {
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param() ## end param

	process {
		## messages for ShouldProcess
		$strTargetForShouldProcess = "All module configuration options"
		$strMessageForShouldProcess = "Reset to their original, 'factory default' values"
		if ($PSCmdlet.ShouldProcess($strTargetForShouldProcess, $strMessageForShouldProcess)) {
			## get the configuration from the given, "_original_ configuration" JSON filespec
			$script:arrNewHtmlReportConfigs_current = _Get-NewHtmlConfigFromJsonFile -JsonFilespec $script:hshInternalConfigItems_NewHtmlReport["ModCfg_originalDefaults_JsonFilespec"]
			## then, write the configuration to the "current config" destination
			Set-NewHtmlReportConfiguration -Confirm:$false -Scope AllUsers
		} ## end if
	} ## end process
} ## end function



## Initialization
## if the NewHtmlReport config is not already present (say, from the module having been loaded in this session once before), load the configuration from disk
#   the purpose of this check is to not overwrite the configuration in the current session; important in the case that someone set a session-specific config item for the module, and then reloaded the module
if (-not (Get-Variable -Name arrNewHtmlReportConfigs_current -ErrorAction:SilentlyContinue)) {
	Get-NewHtmlReportConfiguration | Out-Null
} ## end if
else {Write-Verbose "[NewHtmlReport init] Configuration already loaded in session -- not reloading from disk"}

Export-ModuleMember -Function New-HtmlReport, New-PageBodyTableHtml, Get-NewHtmlReportConfiguration, Reset-NewHtmlReportConfiguration, Set-NewHtmlReportConfiguration
