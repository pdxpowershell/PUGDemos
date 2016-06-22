function Verify-JenkinsJobResult {

    $baseUri =  'http://bhurtdemo.cloudapp.net'

    $userAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'

    $jobToInvoke = "Test Automation Step"

    $homepageResponse = Invoke-WebRequest `
                            -uri "$baseUri/login?from=%2F" `
                            -SessionVariable session `
                            -UserAgent $userAgent

    $loginForm = $homepageResponse.Forms['login']

    $loginForm.Fields.j_username = 'bill'
    $loginForm.Fields.j_password = 'nothing1'

    $loginUri = "$baseUri/$($loginForm.Action)"

    $loginResponse = Invoke-WebRequest `
                        -Uri $loginUri `
                        -Method Post `
                        -Body $loginForm.Fields `
                        -WebSession $session `
                        -userAgent $userAgent

    $jobUri = "$baseUri/$($loginResponse.Links.Where({$_.innerText -eq $jobToInvoke}).href)"


    $jobPage = Invoke-WebRequest `
                        -Uri $jobUri `
                        -WebSession $session `
                        -userAgent $userAgent

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

    $output = $lastConsole.ParsedHtml.body.getElementsByClassName("console-output")

    $props = ($output.item().outerText).Split() | Select-String "=" | ConvertFrom-CSV -Delimiter "=" -Header "key","value"

    $hashtable = @{}
    foreach($prop in $props)
    {
        $hashtable[$prop.key] = $prop.value
    }

    Write-OutPut $hashtable
}
