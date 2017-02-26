<#
For this demo I have set up a job that demonstrates the easy way to develop PowerShell sql jobs. 
The workflow is you have a job, not of PowerShell type, but a cmd job that calls powershell.exe and 
executes the script that you have open for editing in PowerShell ISE or your favorite editor.

Edit the script and save it on disk, then execute the job using the PowerShell provider. The Script
below will wait for the job to complete and then show you the results in the console. If you need to make 
another change, just change it on disk again and execute the job. No need to click around in ssms copying
and pasting your code into the agent job properties dialog anymore.
#>
$agent = Get-Item SQLServer:\sql\bhurt-demo-sql1\default\jobserver

$jobName = 'Test Powershell CMD'

$job = $agent.jobs | Where Name -eq $jobName

$job.Start()

While($job.CurrentRunStatus -eq 'Running'){
    $job.Refresh()
}

Start-Sleep -Seconds 3

$job.EnumHistory() | Sort-Object InstanceID -Descending | Select-Object -First 1 -Skip 1 | Format-List JobName, RunDate, Message

$job.JobSteps | Format-Table SubSystem, Command

# Now when you need to migrate the job from one server to another you can easily grab the job object,
# connect to the remote server, and ask the job object to script itself out into the new server.

Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql2 -Query ($job.Script())