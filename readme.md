## NewHtmlReport PowerShell Module

The NewHtmlReport PowerShell module provides some functions for easily creating consistent, functional HTML reports from data. The tables in which data is presented use the [jQuery](https://jquery.com) framework and the [TableSorter](http://tablesorter.com) jQuery plugin, to provide sorting capabilities by default on all tables.  Additionally, with the default CSS, consistent and useful style comes standard -- including alternating row background color (a.k.a., "zebra-striped" row background colors).

These supporting web libraries reside on your webserver (you place them there as part of preparing to use this module).

### QuickStart
Short on patience? Want to just get going with using this module? Go like this:
- download the module, either from the latest .zip file on the [NewHtmlReport Releases](https://github.com/mtboren/NewHtmlReport/releases) page, or by cloning the project to some local folder with Git via:  
  `PS C:\> git clone https://github.com/mtboren/NewHtmlReport.git C:\temp\MyNewHtmlReportRepoCopy`
- put the actual PowerShell module directory in some place that you like to keep your modules, say, like this, which copies the module to your personal Modules directory:  
  `PS C:\> Copy-Item -Recurse -Path C:\temp\MyNewHtmlReportRepoCopy\NewHtmlReport\ -Destination ~\Documents\WindowsPowerShell\Modules\NewHtmlReport`
- put the supporting web document/image resources (files) on your web server, or locate CDNs that are kind enough to host the versions of things like jQuery and jQuery TableSorter (sample copies of such files are in the `C:\temp\MyNewHtmlReportRepoCopy\resources\` folder in our example)
- update the NewHtmlReport configuration file (`~\Documents\WindowsPowerShell\Modules\NewHtmlReport\New-HtmlReport_configItems.ps1` in our example) to point at the web paths at which you just made the supporting web resources available (or the CDNs, like `https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js` for the jQuery JavaScript library)
- import the PowerShell module:  
  `PS C:\> Import-Module -Name NewHtmlReport`
- start using the module! The following makes a new HTML report of some VMHosts and a few select properties, with a title, header, and footer:  
  `PS C:\> New-HtmlReport -Title "My VMHosts" -PreContent "My VMHosts Report" -PostContent "<SPAN CLASS='footerInfo'>I just made this at $(Get-Date)</SPAN>" -InputObject (Get-VMHost | select Name,State,CpuUsageMhz,CpuTotalMhz,MemoryUsageGB,MemoryTotalGB) | Out-File -Encoding ascii C:\temp\myReport0.htm`
- open and admire your new report:  
  `PS C:\> Invoke-Item -Path C:\temp\myReport0.htm`

### Configuration and Usage
Use `Get-Help -Full about_NewHtmlReport` upon loading the module in your PowerShell session to consume the help in traditional PowerShell fashion.  Or, you can read the file directly in the Git repo or PowerShell module directory: `<moduleDirectory>\en-us\about_NewHtmlReport.help.txt`

Quick hint:  as you will read in the about-module help, the module configuration points at a couple of JavaScript files for functionality and a CSS file for style.  Example copies of these files are provided in the Git repo for this module, on which you can build if desired.  As the configuration section of the help mentions, you should probably grab the latest/greatest versions of the JavaScript files.  But, the CSS file has a few decent style elements already defined, and should make a good base.  Additionally, there are a few image files in the resources folder -- these files are of the names used in the example CSS.  The help doc discusses using these (or other) images, and points out an example statement in the sample CSS that uses said images.

### Example Output
Want to see some sample output reports that result from the commands in the examples sections of the cmdlets' help?  Of course you do.  See the GitHub Pages page for this project at <https://mtboren.github.io/NewHtmlReport> to enjoy such sample reports.  The reports contain little/no fluff:  they are there to provide examples of the interactive tables, styling, captions, highlighting, etc., features provided by this PowerShell module.
