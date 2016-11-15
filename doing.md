[feat_AddPipelineSupport]
done:
- added support for accepting objects from pipeline in `New-HtmlReport` function
- changed scope of 'static' config items -- by moving from `ScriptsToProcess` to `NestedModules` in .psd1; verified -- `NestedModules` is available in PowerShell v2

[feat_AddCfgCmdlet]
- add ability to manage module configuration via cmdlet in module, instead of requiring user to manually edit configuration file in module directory
  - leverages JSON-based configs file, and new cmdlets `Get-NewHtmlReportConfiguration`, and `Set-NewHtmlReportConfiguration`, and `Reset-NewHtmlReportConfiguration`
  - allows for scope of setting:  Session, AllUsers
  	- if not already loaded at module import time (say, from previous module import), reads from disk; else, does not disturb the config that is already defined in the session
  	- stores and returns both AllUsers and Session scopes' configuration via Get-NewHtmlReportConfiguration
  	- behavior:
  		- invoke Get-NewHtmlReportConfiguration at module load, creating module-private variable
		- `Get-NewHtmlReportConfiguration`:
  			- stores those in module-private variable
  			- if said variable not defined:  AllUsers and Session are the same, are read from json, and variable is defined, and they are returned (two objects)
  			- else, return said variable
  		- `Set-NewHtmlReportConfiguration`:
  			- set values in proper scope
  			- if scope is AllUsers, export to json
  		- `Reset-NewHtmlReportConfiguration`:  resets all scopes to the values in the default configs JSON file included with the module, as a "revert to factory settings" kind of option, overwriting the saved configs on disk with the original default values
  		- cmdlets in module use private-variable's Session cfg
  - updated cmdlets in module to use the Session-scoped config settings for places where config items are leveraged (replaced use of `$hshConfigItems`)
  - removed the $str* variables previously in use by module (put them into the module-wide configuration store)
  - updated readme
  - update `Set-NewHtmlReportConfiguration` and `Reset-NewHtmlReportConfiguration` help to mention that setting config items for AllUsers scope requires Write rights in the module's directory (so, if using the module from some read-only location, those cmdlets will not be able to update config items in the AllUsers scope)
  - updated about_NewHtmlReport to hold new info about config files and whatnot
  - include CSS for page footer class, tbody tr.highlightRow td, etc.
  - removed resources\ folder from project, since things are provided via CDN, now
  - updated tests to include:
      - one that uses row-highlighting example
      - one that uses multiple tables in one page
  - updated changelog
  - updated examples in GitHub page for this module

do:
  - move doing to done