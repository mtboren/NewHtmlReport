## making module: (May 2013, Matt Boren)
#   0) make the PowerShell Script Module (.psm1) file with the exported functions/variables/aliases/etc.
#   1) make the PowerShell Data (.psd1) file (the Module Manifest) by calling New-ModuleManifest as shown below

## parameters for New-ModuleManifest version from PowerShell v3 or newer:
$strFilespecForPsd1 = "$PSScriptRoot\NewHtmlReport\NewHtmlReport.psd1"

$hshModManifestParams = @{
	Path = $strFilespecForPsd1
	Author = "Matt Boren, Jaron Hilger"
	CompanyName = "None"
	Copyright = "None"
	## when setting value for DefaultCommandPrefix in module, need to account for that when setting value for Aliases anywhere (need to code those to point at what the functions _will_ be called when the DefaultCommandPrefix is applied)
	#DefaultCommandPrefix = ""
	#FormatsToProcess = "SomeModule.format.ps1xml"
	ModuleToProcess = "NewHtmlReport.psm1"
	ModuleVersion = "1.2.1"
	## scripts (.ps1) that are listed in the NestedModules key are run in the module's session state, not in the caller's session state. To run a script in the caller's session state, list the script file name in the value of the ScriptsToProcess key in the manifest
	NestedModules = @('NewHtmlReport_configItems.ps1')
	PowerShellVersion = [System.Version]"2.0"
	Description = "Module with function to create HTML output with nice layout/features (jQuery integration, for example)"
	## specifies script (.ps1) files that run in the caller's session state when the module is imported. You can use these scripts to prepare an environment, just as you might use a login script
	# ScriptsToProcess = "New-HtmlReport_configItems.ps1"
	VariablesToExport = @()
	AliasesToExport = @()
	CmdletsToExport = @()
	FileList = Write-Output NewHtmlReport.psd1, NewHtmlReport.psm1, NewHtmlReport_configItems.ps1, NewHtmlReport_config_stored.json, NewHtmlReport_config_stored_default.json
	Verbose = $true
}
## using -PassThru so as to pass the generated module manifest contents to a var for later output as ASCII (instead of having a .psd1 file of default encoding, Unicode)
$oManifestOutput = New-ModuleManifest @hshModManifestParams -PassThru
## have to do in separate step, as PSD1 file is "being used by another process" -- the New-ModuleManifest cmdlet, it seems
#   in order to have this module usable (importable) via PowerShell v2, need to update the newly created .psd1 file, replacing the 'RootModule' keyword with 'ModuleToProcess'
# $oManifestOutput | Out-File -Verbose $strFilespecForPsd1 -Encoding ASCII
($oManifestOutput -split "`n" | Foreach-Object {$_ -replace "^RootModule = ", "ModuleToProcess = "}) -join "`n" | Out-File -Verbose -FilePath $strFilespecForPsd1 -Encoding ASCII
