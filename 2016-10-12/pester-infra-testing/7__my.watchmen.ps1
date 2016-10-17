
# This test should PASS
WatchmenTest 'OVF.Example1' {
    notifies {
        logfile 'c:\temp\watchmen_demo_7.log' -when 'always'
    }
}
