### Changelog

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
