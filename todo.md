### ToDo:
- add ability to manage module configuration via cmdlet in module, instead of requiring user to manually edit configuration file in module directory
  - by leveraging JSON-based configs file, and new `Get-HtmlReportConfiguration` and `Set-HtmlReportConfiguration` cmdlets?
  - remove the global $str* variables currently in use by module (put them into the `hshConfigItems` hashtable)
- add pipeline support to accept objects from pipeline
- update tests for parameter usage in functions (instead of `if ($param) {}..`, use `if ($PSBoundParameters.ContainsKey('MyParam')) {}..`)
- add some sample HTML files (but, with doctored paths to resource files)
