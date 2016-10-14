
Import-Module -Name Watchmen

$tests = Get-WatchmenTest -Path .\9__my.watchmen.ps1 -Verbose

return ($tests | Invoke-WatchmenTest -IncludePesterOutput -Verbose -PassThru)
