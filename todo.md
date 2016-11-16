### ToDo:
- add MIT license
- add Related Links items to cmdlets (via .LINK keyword in comment-based help, and to list related cmdlets for each cmdlet, like the get/set/reset config cmdlets)
- work on release automation (update make file, license year check/update, module .zip creation, etc)
- add support to `New-PageBodyTableHtml` to take InputObject from pipeline?
- update tests for parameter usage in functions (instead of `if ($param) {}..`, use `if ($PSBoundParameters.ContainsKey('MyParam')) {}..`)
- add some sample HTML files (but, with doctored paths to resource files)
- for `New-HtmlReport` function:  make function to create HTML that uses datasource from JSON -- likely involving using DataTables
	- eventually support CSV, XML, or whatevs for data format?
- add support for multiple values to CssUri in `New-HtmlReport`
- for having set default values for jQuery and TableSorter URLs to be CDN links:
	- ?also add something like the following, which essentially "falls back" to adding ref to local .js copy if the page was unable to grab the CDN-based .js (as described at http://webcache.googleusercontent.com/search?q=cache:http://www.impressivewebs.com/linking-to-jquery/):

		`<script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>`
    `<script>window.jQuery || document.write('<script src="js/jquery-1.7.2.min.js"><\/script>')</script>`
    - ?add options to set Tablesorter theme (as shown to be available at https://mottie.github.io/tablesorter/docs/themes.html); do so via TablesorterThemeName type of enumerated config option, which updates the table class and somehow the .CSS file?
- add option to make [DataTables](https://datatables.net) table instead of TableSorter:
	- make the HTML that will support/enable such tables
	- for data, either embed as JSON array in the HTML, or give option to generate JSON from input objects
		- if "generate JSON", take JSON path param (and JSON URL, if that exposes JSON on a web server or something, like if the JSON file path is not relative to current HTML doc being generated)
		- explain subsequent use can just be, `$arrMyObjects | ConvertTo-Json | Out-File -Encoding utf8 .\some\path\data.json` to "refresh" data and without need to employ `New-HtmlReport`
	- for DataTables search box, add JS that will clear search box when `ESC` key is pressed with focus in search box
	- add additional config items for:
		- DataTables JS, CSS URLs
	- ?include .css that overrides the sorting icon PNGs from default DataTables CSS -- need a way to enable/disable that, if not using default DataTables CSS (else would override people's customized/local DataTables CSS)
  - will .js and .css from CDNs work for all for datatables.net?  Like, imgs and whatnot? Or, need .css overrides for PNGs for when default CDN .css is in use?
- need to consider how to not change/overwrite module settings at module upgrade time (make settings sticky across module upgrades, make settings exportable?)
