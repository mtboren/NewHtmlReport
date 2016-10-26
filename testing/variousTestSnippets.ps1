## some test snippets, for interactive testing for now

## make a new, GUID-named dir so as to avoid any overwrites and name-collisions
$oTmpDir = New-Item -ItemType Directory -Path "${env:temp}\$(([System.Guid]::NewGuid()).Guid)"
$strTmpDirFilespec = $oTmpDir.FullName
## numbers for the tests
$intTestNum = 0

## pipeline testing
## make a test report using just the contents of a temp dir with just the given properties (properties will be in property-name alphabetical order, since no -Property value specified to New-HtmlReport)
Get-ChildItem ${env:temp} | Select-Object Mode, LastWriteTime, Length, Name | New-HtmlReport -Title "test HTML report" | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm

## make a test report using just the contents of a temp dir with just the given properties, but setting the particular property order by having specified the -Property param to New-HtmlReport
$intTestNum++
Get-ChildItem ${env:temp} | New-HtmlReport -PreContent "<H3>Sweet report -- objects from pipeline</H3>" -Property Mode, LastWriteTime, Length, Name -Title "objects from pipeline test HTML report" | Out-File -Encoding utf8 -FilePath $strTmpDirFilespec\testOut${intTestNum}.htm

explorer.exe $strTmpDirFilespec
## clean-up:  remove the temporary directory and its contents
$oTmpDir | Remove-Item -Recurse