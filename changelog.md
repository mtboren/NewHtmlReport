### NewHtmlReport PowerShell Module Changelog
### v1.2.1, 11 Dec 2016:
- \[fix] fixed [issue #1](https://github.com/mtboren/NewHtmlReport/issues/1) about default property order from input object if no `-Property` value specified -- order of properties is now maintained for when `-Property` parameter not used, instead of having been changed to alphabetical order
- \[update] style: added override for default table width, setting to "auto" (default TableSorter theme from Mottie sets width to "100%")
- \[update] style: added left/right borders to TD items, for legibility of columns
- \[improvement] added Related Links items to cmdlets to list related cmdlets
- \[new] added MIT license


### v1.2, Nov 2016:
- \[new] added ability to manage module configuration via cmdlets in module, instead of requiring user to manually edit configuration file in module directory
	- leverages JSON-based config file and new cmdlets `Get-NewHtmlReportConfiguration`, `Set-NewHtmlReportConfiguration`, and `Reset-NewHtmlReportConfiguration`
	- allows for scope of setting:  Session, AllUsers
	- enables module configuration in more natural, cmdlet-based way
- \[new] added support for accepting objects from pipeline in `New-HtmlReport` function
- \[update] changed from defaulting to local resources (JS and CSS files) to now defaulting to online CDN locations for such resources
	- consequently, removed `resources\` folder and contents from project
	- while this makes getting started much easier/quicker (see Quick Start section in [readme.md](./readme.md)), to be clear about what else this does:  this new default configuration makes the HTML that this module generates dependent upon the consumer of the HTML document having internet access when viewing the HTML document
- \[update] changed from using Christian Bach's [original TableSorter](http://tablesorter.com/) jQuery plugin to using the [Mottie's](https://github.com/Mottie) more actively developed [tablesorter fork](https://github.com/Mottie/tablesorter)
	- props still go to CBach for providing the great plugin!
	- now using the default theme provided by this forked plugin, too
	- still using a minor bit of the original CSS styling that has been a part of this `NewHtmlReport` module since the beginning


### v1.1, Dec 2015:
- first public release
- added piece to `makeModule.ps1` that replaces keyword in .psd1 file so as to maintain PowerShell v2 compatibility


### v1.0.4, 22 Apr 2015:
- added some logic to only use unique properties from input objects for property selection if no value supplied for -Property param (without this, properties could be listed twice in the output in certain cases, like when an array of file _and_ directory objects was passed as the -InputObject -- both object types have mostly the same properties, and the original logic here was returning each property name, even if duplicate)


### v1.0.3, 08 Aug 2014:
- replaced internal references
- added parameters `-RoundNumber` and `-NumDecimalPlace` to functions `New-HtmlReport`, `New-PageBodyTableHtml`
	- so that one can have these functions round items that are numbers to the given number of decimal places, instead of having to format each property individually beforehand


### updated 01 Jul 2014:
- changed `New-HtmlReport.psm1` so that the function `New-PageBodyTableHtml` is now exposed.  This function can be called with minimal parameters to insert a table on a page that was already created with a table and share the same formatting.


### updated 19 Sep 2013:
- changed manifest to have explicitly defined items (instead of wildcard, which is not supported in PowerShell v3)


### updated 23 Jul 2013:
- new parameter to `New-HtmlReport` function:  `TableCaption`, used to specify a caption for the table that is returned in the output
	- the caption is of CSS class `tblCaption`
	- added default style in for `tblCaption` class in default .CSS file


### updated 19 Jul 2013:
- new property for InputObjects, `bDoRowHighlight`, used to specify that given row should be "highlighted", which is handled by adding a CSS class to the TR for that object
	- if `bDoRowHighlight` is `$true` on given object, the CSS class of `highlightRow` is set for that row
	- the module does not display any property by this name (`bDoRowHighlight`) -- it is taken to be a switch that says to add said CSS to this object's TR in the output
	- to use, just add property of `bDoRowHighlight` to the desired input objects, with a value of `$true`
	- suggested CSS selector to set style for this:  `table.tSorter tbody tr.highlightRow td {...}`; the `td` is part of this, as the style seems to get overridden if stopping at the `tr` level, due to some TableSorter JavaScript code
