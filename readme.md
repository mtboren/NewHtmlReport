## NewHtmlReport PowerShell Module

The NewHtmlReport PowerShell module provides some functions for easily creating consistent, functional HTML reports from data. The tables in which data is presented use the [jQuery](https://jquery.com) framework and the [TableSorter](http://tablesorter.com) jQuery plugin, to provide sorting capabilities by default on all tables.  Additionally, with the default CSS, consistent and useful style comes standard -- including alternating row background color (a.k.a., "zebra-striped" row background colors). 

### Configuration and Usage
Use `Get-Help -Full about_NewHtmlReport` upon loading the module in your PowerShell session to consume the help in traditional PowerShell fashion.  Or, you can read the file directly in the Git repo or PowerShell module directory: `<moduleDirectory>\en-us\about_NewHtmlReport.help.txt`

Quick hint:  as you will read in the about-module help, the module configuration points at a couple of JavaScript files for functionality and a CSS file for style.  Example copies of these files are provided in the Git repo for this module, on which you can build if desired.  As the configuration section of the help mentions, you should probably grab the latest/greatest versions of the JavaScript files.  But, the CSS file has a few decent style elements already defined, and should make a good base.  
