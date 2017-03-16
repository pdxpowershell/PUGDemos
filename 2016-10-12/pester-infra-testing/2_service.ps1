
describe 'Services' {
    context 'Automatic Services' {
        $svcs = Get-Service | where StartType -eq 'Automatic'        
        $svcs | % {
            it "$($_.Name) is running" {
                $_.Status | should be 'running'
            }
        }
    }
}
