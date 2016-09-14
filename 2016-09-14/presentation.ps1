##############################
#                            #
#Starting Jobs With Start-Job#
#                            #
##############################                          

#This will start a job with the name of SleepProcess (Sleeps 1 minute, then runs Get-Process)
Start-Job -Name SleepProcess -ScriptBlock {Start-Sleep -Seconds 60; Get-Process}

################################
#                              # 
#Waiting for jobs with Wait-Job#
#                              #
################################ 

Start-Job -Name Wait -ScriptBlock {Start-Sleep -Seconds 60} | Wait-Job

###############################
#                             # 
#Getting Job Info With Get-Job#
#                             #
###############################

#Get all current jobs that haven't been removed with Remove-Job
Get-Job

#Get just the job(s) named SleepProcess
#Job names are not unique, so be sure to make them unique when you name them!
Get-Job -Name SleepProcess

#############################################
#                                           # 
#Receive Job Command Output with Receive-Job#
#                                           #
#############################################

#Receive the job named SleepProcess, and keep its contents
Receive-Job -Name SleepProcess -Keep  

#It is good to store job information in variables, though!
$jobReceived = Receive-Job -Name SleepProcess -Keep 

#Now $jobReceived has the job output

###############################
#                             # 
#  Stop a Job with Stop-Job   #
#                             #
###############################

#Start a job for 10000 seconds
Start-Job -Name SleepTooLong -ScriptBlock {Start-Sleep -Seconds 10000;Get-Process}

#Sheesh... how long is that in minutes -xor hours?!
Write-Host "That's $("{0:n2}" -f (10000 / 60)) minutes, or about $("{0:n2}" -f ((10000 / 60) / 60)) hours, $((Get-ChildItem Env:\USERNAME).Value)"

#Let's see what's up with this job
Get-Job -Name SleepTooLong

#Now let's stop that job!
Stop-Job -Name SleepTooLong

#Annnd finally, verify it has stopped
Get-Job -Name SleepTooLong

#################################
#                               # 
#  Remove a Job With Remove-Job #
#                               #
#################################

#Let's see all the running jobs
Get-Job

#How about we remove the job named 'Wait'?
Remove-Job -Name Wait

#Use Get-Job to verify its removal
Get-Job

#################################
#                               # 
#  What's a Job Look Like?      #
#                               #
#################################

#Start the job and store the object in $jobGetProcess
$jobGetProcess = Start-Job -Name GetOutput -ScriptBlock {Start-Sleep 10;Get-Process}

#Take a look at the properties and methods of the $jobGetProcess object
$jobGetProcess | Get-Member

#Use PSBeginTime and PSEndTime to calculate execution time
$jobGetProcess | Select-Object PSBeginTime,PSEndTime,@{Name='ExecutionTime';Expression={$_.PSEndTime - $_.PSBeginTime}}

#Get the properties and methods of the childjob
$jobGetProcess.ChildJobs[0] | Get-Member

#Look at the job output another way, through the eyes of a child (job)
$jobGetProcess.ChildJobs[0].Output

#Curious that the parent job does not actually contain any output (the child job is where it is all at)
$jobGetProcess.Output

#Lions, tigers, and errors, oh my!

#Let's fail a job
$failJob = Start-Job -Name FailJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory -ErrorAction Stop}

#Let's look at all the fail
$failJob

#But WHY did it fail? :(
$failJob.ChildJobs[0].JobStateInfo

#To be more precise...
$failJob.ChildJobs[0].JobStateInfo.Reason

#Just to show you there is no error on the parent object (or child for that matter)
$failJob.Error
$failJob.ChildJobs[0].Error
#Hmph... weird, but we'll see when this comes in handy, too

#Let's get the taste of failure out of our mouths for now...
$failJob = $null

#Time to fail again, but secretly
$failJob = Start-Job -Name FailJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory}

#Look at the fail!
$failJob

#The parent object wont have the error info
$failJob.Error

#But the child job object will
$failJob.ChildJobs[0].Error

#If you want use the string, it is in the exception property
$failJob.ChildJobs[0].Error.Exception