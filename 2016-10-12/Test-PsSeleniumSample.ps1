$PSSeleniumPath = Join-Path (Get-Item $PSScriptRoot).Parent.Parent.Parent.Parent.Parent.FullName -ChildPath Build\PSSelenium
Import-Module $PSSeleniumPath\selenium.psm1
    
    
$AcceptanceTests = {
    Test-Case "ShouldFindCheesecakeFactoryByNameInBingSearch" {
    #redirect browser to target page
    Open-WebPage  "www.bing.com"

    #Wait 30 seconds--by default--to find element by Css selector
    #Also validates element existences within the DOM
    Wait-UntilElementVisible -Selector Css -Value "#sb_form_q"
    Validate-ElementExists -Selector Css -Value "#sb_form_q"

    #Insert text into a control on the page using xpath
    Insert-Text -Selector XPath -Value ".//*[@id='sb_form_q']" -string "Cheesecake Factory"

    #Click a control using css selector
    Click-Item -Selector Css -Value "#sb_form_go"

    #Wait for 30sec to find element by Css selector
    Wait-UntilElementVisible -Selector Css -Value ".b_entityTitle"

    #Validate Element css element contains text (supports regex)
    Validate-TextExists -Selector Css -Value ".b_entityTitle" -ExpectedText "The Cheesecake Factory"
    } 
    
    Test-Case{

        #Open-WebPage
        
    }
}

#Invoke the test-case(s) defined in the AcceptanceTest script block 
$results = Invoke-TestCase -testsAsWarnings $true -baseUrl "https://" -TestCases $AcceptanceTests

#Create a summary 
New-SummaryReport -TestResults $results