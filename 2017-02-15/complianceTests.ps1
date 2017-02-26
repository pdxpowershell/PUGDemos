<#
With the script below you can easily run compliance tests against your sql server.

The auditSettings.json is the policy file that specifys the policy settings you expect the server to 
adhere to. You then execute pester tests against the query results in comparison with the policy file. 

You can visualize the tests and their failures or the passes with Jenkins. An example of how to do that
is at my blog: https://scripting.tech/2016/06/25/visualizing-operational-tests-with-jenkins-and-pester/
#>
$settings = Get-Content "$env:userprofile\Documents\auditSettings.json" | Out-String | ConvertFrom-json

foreach($server in $settings) {
    $instance = Get-Item "SQLSERVER:\SQL\$($server.servername)\Default"

    Describe "Audi Users for $($server.servername)" {
        
        foreach($user in $server.users){
            
            it "$user should exist in returned user names" {
                $instance.logins.name -eq $user | Should Be $user
            }
        }

        foreach($login in $instance.Logins.name){
            
            it "$login should exist in the settings file" {
                $settings.where({$_.servername -eq $instance.Name}).users -eq $login | Should be $login
            }
        }
    }
}