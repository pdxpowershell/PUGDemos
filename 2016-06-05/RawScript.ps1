<#
    Set up base configuration variables
#>
$baseUri =  'http://bhurtdemo.cloudapp.net'

# Chrome's Agent String
$userAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'

$jobToInvoke = "Test Automation Step"

<#
    Grab the home page. Talk about Invoke-WebRequest, the session variable and why we need a explicit userAgent String
#>
$homepageResponse = Invoke-WebRequest `
                        -uri "$baseUri/login?from=%2F" `
                        -SessionVariable session `
                        -UserAgent $userAgent

<#
    Examine the session variable and what it's doing for us
#>
$session

<#
    Call the response variable and talk about some of the properties it gives us and why this is so much better than parsing
    a string return to get the information we need.
#>
$homepageResponse

<#
    Talk about the forms we see and just touch briefly on how web form works
#>
$homepageResponse.Forms

<#
    Talk briefly about this form field value assignment
#>

$loginForm = $homepageResponse.Forms['login']

$loginForm.Fields.j_username = 'bill'
$loginForm.Fields.j_password = 'nothing1'

$loginUri = "$baseUri/$($loginForm.Action)"

<#
    Talk about using Invoke-WebRequest to submit forms and the params we need like Method, WebSession, and Body
#>
$loginResponse = Invoke-WebRequest `
                    -Uri $loginUri `
                    -Method Post `
                    -Body $loginForm.Fields `
                    -WebSession $session `
                    -userAgent $userAgent

<#
    Examine the links we see here and compare to those found in the browser
#>
$loginResponse.Links | Format-Table innerText, href

<#
    Touch on the use of the Where() method and method chaining
#>
$jobUri = "$baseUri/$($loginResponse.Links.Where({$_.innerText -eq $jobToInvoke}).href)"


$jobPage = Invoke-WebRequest `
                    -Uri $jobUri `
                    -WebSession $session `
                    -userAgent $userAgent

<#
    Note the latest build link and that we'll come back to it.
#>
$jobPage.Links | Format-Table innerText, href

$buildUri = "$baseUri$($jobPage.Links.Where({$_.innerText -eq "Build Now"}).href)"

$buildResponse = Invoke-WebRequest `
                    -Uri $buildUri `
                    -WebSession $session `
                    -userAgent $userAgent `
                    -Method POST

$lastBuildConsoleUri = "$($jobUri)lastBuild/console"

$lastConsole = Invoke-WebRequest `
                    -Uri $lastBuildConsoleUri `
                    -WebSession $session `
                    -userAgent $userAgent

<#
    
#>
$output = $lastConsole.ParsedHtml.body.getElementsByClassName("console-output")

$props = $data = ($output.item().outerText).Split() | Select-String "=" | ConvertFrom-CSV -Delimiter "=" -Header "key","value"

$hashtable = @{}
foreach($prop in $props)
{
    $hashtable[$prop.key] = $prop.value
}


<#
Set up a pester test. This is kind of a cherry on top for the experienced people so we will go through this a little quickly.
#>

Set-Location "$env:userprofile\documents"

New-Item -ItemType directory -Path .\Pester

Import-Module Pester

New-Fixture -Path JenkinsOpTest -Name Verify-JenkinsJobResult
