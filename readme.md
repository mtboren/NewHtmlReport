## NewHtmlReport PowerShell Module

The NewHtmlReport PowerShell module provides some functions for easily creating consistent, functional HTML reports from data. The tables in which data is presented use the [jQuery](https://jquery.com) framework and the [TableSorter](http://tablesorter.com) jQuery plugin, to provide sorting capabilities by default on all tables.  Additionally, with the default CSS, consistent and useful style comes standard -- including alternating row background color (a.k.a., "zebra-striped" row background colors).

These supporting web libraries can reside anywhere you like -- your web server, your favorite content distribution network provider, etc.  By default, the module points at CloudFlare CDN for the JavaScript libraries that are used by the HTML.  You can easily change these default URIs to be any valid location at which you have functioning copies of the JS and corresponding CSS.  See the QuickStart section below for more information about getting- and setting these configuration items in your instance of this module.

### QuickStart
Short on patience? Want to just get going with using this module? Go like this:
- download the module, either from the latest release's .zip file on the [NewHtmlReport Releases](https://github.com/mtboren/NewHtmlReport/releases) page, or by cloning the project to some local folder with Git via:  
  `PS C:\> git clone https://github.com/mtboren/NewHtmlReport.git C:\temp\MyNewHtmlReportRepoCopy`
- put the actual PowerShell module directory in some place that you like to keep your modules, say, like this, which copies the module to your personal Modules directory:  
  `PS C:\> Copy-Item -Recurse -Path C:\temp\MyNewHtmlReportRepoCopy\NewHtmlReport\ -Destination ~\Documents\WindowsPowerShell\Modules\NewHtmlReport`
- import the PowerShell module into the current PowerShell session:  
  `PS C:\> Import-Module -Name NewHtmlReport`  
  or, if the NewHtmlReport module folder is not in your `Env:\PSModulePath`, specify the whole path to the module folder, like:  
  `PS C:\> Import-Module -Name \\myserver.dom.com\PSModules\NewHtmlReport`
- check the configurations for the web resources to be used for the module:  
  `PS C:\> Get-NewHtmlConfiguration | Format-List`  
  note:  these are set to use JS/CSS supporting files from a CDN, with ease of module setup/use in mind; change these configuration values to suit your needs/requirements via the `Set-NewHtmlConfiguration` cmdlet
- start using the module! The following makes a new HTML report of some VMHosts and a few select properties, with a title, header, and footer:  
  `PS C:\> New-HtmlReport -Title "My VMHosts" -PreContent "My VMHosts Report" -PostContent "<SPAN CLASS='footerInfo'>I just made this at $(Get-Date)</SPAN>" -InputObject (Get-VMHost | select Name,State,CpuUsageMhz,CpuTotalMhz,MemoryUsageGB,MemoryTotalGB) | Out-File -Encoding ascii C:\temp\myReport0.htm`
- open and admire your new report:  
  `PS C:\> Invoke-Item -Path C:\temp\myReport0.htm`

### Configuration and Usage
Use `Get-Help -Full about_NewHtmlReport` upon loading the module in your PowerShell session to consume the help in traditional PowerShell fashion.  Or, you can read the file directly in the Git repo or PowerShell module directory: `<moduleDirectory>\en-us\about_NewHtmlReport.help.txt`

### Example Output
Want to see some sample output reports that result from the commands in the examples sections of the cmdlets' help?  Of course you do.  See the GitHub Pages page for this project at <https://mtboren.github.io/NewHtmlReport> to enjoy such sample reports.  The reports contain little/no fluff:  they are there to provide examples of the interactive tables, styling, captions, highlighting, etc., features provided by this PowerShell module.

### Other Information
- Earlier versions of the `NewHtmlReport` module expected you to get started by putting the supporting web document/image resources (JS/CSS/PNG files) on your web server, or locate CDNs that are kind enough to host the versions of things like jQuery (like Google as detailed at https://developers.google.com/speed/libraries/) and jQuery TableSorter (like CloudFlare as detailed at https://cdnjs.com/libraries/jquery.tablesorter). This has changed: the module now comes with default configurations that leverage a Content Delivery Network ("CDN") for the supporting web resources.
- Earlier versions of the module also expected you to manually update a `NewHtmlReport` configuration file by editing it directly to point at the web paths at which you just made the supporting web resources available.  This has also changed:  the module now provides cmdlets for getting, setting, and resetting the module configuration items more naturally, from within PowerShell (see cmdlets `Get-NewHtmlReportConfiguration`, `Set-NewHtmlReportConfiguration`, and `Reset-NewHtmlReportConfiguration`)
