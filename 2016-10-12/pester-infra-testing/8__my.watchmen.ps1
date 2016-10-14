WatchmenOptions {
    notifies {
        when 'onfailure'
        eventlog @{
            eventid = '1'
            eventtype = 'error'
        }
        eventlog @{
            eventid = '100'
            eventtype = 'information'
        } -when 'always'
        slack @{
            Token = $env:WATCHMEN_SLACK_WEBHOOK
            Channel = '#Watchmen_Alerts'
            TitleLink = 'www.google.com'
            AuthorName = $env:COMPUTERNAME
            PreText = 'Everything is on :fire:'
            IconEmoji = ':fire:'
        } -when 'onfailure'
    }
}

# This test should FAIL
WatchmenTest 'OVF.Example1' {
    parameters @{
        FreeSystemDriveThreshold = 1099511627776 # 1TB
    }
}