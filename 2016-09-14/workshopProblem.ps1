<# 
1. Start the three jobs listed below

2. Collect information from them as they execute
    -Command run
    -Job name
    -Errors (if applicable)
    -Time the job completed
    -Anything else you can think of
#>

Start-Job -Name SleepProcess -ScriptBlock {Start-Sleep -Seconds 60; Get-Process}
Start-Job -Name FailJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory -ErrorAction Stop} 
Start-Job -Name FailCompletedJob -ScriptBlock {New-Item -Path 'Z:\' -Name 'test' -ItemType Directory} 