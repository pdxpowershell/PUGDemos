#Set the jobs variable to $true so the while loop processes at least once
$jobs         = $true

#Get path
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#Set the output folder path
$outputFolder = "$scriptPath\Output"

#Create some jobs to monitor. One for each error handling example, and then one success that takes a minute to complete.
Start-Job -Name SleepProcess -ScriptBlock {Start-Sleep -Seconds 60; Get-Process}
Start-Job -Name FailJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory -ErrorAction Stop} 
Start-Job -Name FailCompletedJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory} 

#If the folder doesn't exist, create it
If (!(Test-Path $outputFolder)) {

    New-Item -Path $outputFolder -ItemType Directory

}

#While $jobs = $true...
While ($jobs) { #Begin $jobs While Loop

    #Store the jobs in $ourJobs
    $ourJobs = Get-Job

    Write-Host "Checking for jobs..."

    #Use a ForEach loop to iterate through the jobs
    foreach ($jobObject in $ourJobs) { #Begin $ourJobs ForEach loop
        
        #Null out variables used in this loop cycle
        $jobResults   = $null
        $errorMessage = $null
        $jobFile      = $null
        $fileContents = $null
        $jobCommand   = $null

        #Store the command used in the job to display later
        $jobCommand   = $jobObject.Command

        #Use the Switch statement to take different actions based on the job's state value
        Switch ($jobObject.State) { #Begin Job State Switch

            #If the job state is running, display the job info
            {$_ -eq 'Running'} {

                Write-Host "Job: [$($jobObject.Name)] is still running..."`n
                Write-Host "Command: $jobCommand"`n

            }

            #If the job is completed, create the job file, say it's been completed, and then perform an error check
            #Then display different information if an error is found, versus successful completion
            #Use a here-string to create the file contents, then add the contents to the file
            #Finally use Remove-Job to remove the job
            {$_ -eq 'Completed'} {
                
                #Create file
                $jobFile = New-Item -Path $outputFolder -Name ("$($jobObject.Name)_{0:MMddyy_HHmm}.txt" -f (Get-Date)) -ItemType File

                Write-Host "Job [$($jobObject.Name)] has completed!"

                #Begin completed but with error checking...
                if ($jobObject.ChildJobs[0].Error) {

                    #Store error message in $errorMessage
                    $errorMessage = $jobObject.ChildJobs[0].Error | Out-String

                    Write-Host "Job completed with an error!"`n
                    Write-Host "$errorMessage"`n -ForegroundColor Red -BackgroundColor DarkBlue

                    #Here-string that contains file contents
                    $fileContents = @"
Job Name: $($jobObject.Name)

Job State: $($jobObject.State)

Command:

$jobCommand

Error:

$errorMessage
"@

                    #Add the content to the file
                    Add-Content -Path $jobFile -Value $fileContents

                } else {
                    
                    #Get job result and store in $jobResults
                    $jobResults = Receive-Job $jobObject.Name

                    Write-Host "Job completed without errors!"`n
                    Write-Host ($jobResults | Out-String)`n

                    #Here-string that contains file contents
                    $fileContents = @"
Job Name: $($jobObject.Name)

Job State: $($jobObject.State)

Command: 

$jobCommand

Output:

$($jobResults | Out-String)
"@

                    #Add content to file
                    Add-Content -Path $jobFile -Value $fileContents

                }

                #Remove the job
                Remove-Job $jobObject.Name
             
            }

            #If the job state is failed, state that it is failed and then create the file
            #Add the error message to the file contents via a here-string
            #Then use Remove-Job to remove the job
            {$_ -eq 'Failed'} {

                #Create the file
                $jobFile    = New-Item -Path $outputFolder -Name ("$($jobObject.Name)_{0:MMddyy_HHmm}.txt" -f (Get-Date)) -ItemType File
                #Store the failure reason in $failReason
                $failReason = $jobObject.ChildJobs[0].JobStateInfo.Reason.Message 

                Write-Host "Job: [$($jobObject.Name)] has failed!"`n
                Write-Host "$failReason"`n -ForegroundColor Red -BackgroundColor DarkBlue
                
                #Here-string that contains file contents
                $fileContents = @"
Job Name: $($jobObject.Name)

Job State: $($jobObject.State)

Command: 

$jobCommand

Error:

$failReason
"@
                #Add content to file
                Add-Content -Path $jobFile -Value $fileContents

                #Remove the job
                Remove-Job $jobObject.Name
            }


        } #End Job State Switch
     
    } #End $ourJobs ForEach loop

    #Clear the $ourJobs variable
    $ourJobs = $null

    #Get the new list of jobs as it may have changed since we did some cleanup for failed/completed jobs
    $ourJobs = Get-Job 

    #If jobs exists, keep the loop running by setting $jobs to $true, else set it to $false
    if ($ourJobs) {$jobs = $true} else {$jobs = $false}

    #Wait 10 seconds to check for jobs again
    Start-Sleep -Seconds 10

} #End $jobs While Loop