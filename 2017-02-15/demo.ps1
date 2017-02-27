# This protects you in case you accidently hit F5
throw "Not the whole damn script!"
<#
Install the SQLPS Module on a workstation machine or a jump Box

Download and install the feature pack (this is for 2014)
http://www.microsoft.com/en-us/download/details.aspx?id=42295
Choose:
	SQL CLR Types
    Shared Management Objects
    Powershell Tools

We have done this so that we can have the SQL PS Module, the SQL Provider and other tools available 
on a machine that does not actually have SQL Server installed on it. This allows us to carry out our
administration tasks from an administration machine or a jump box without having to rdp into or even
remote session into the SQL Server VM and consume resources that should be dedicated to the SQL engine.
#>

Install-Module dbatools
Install-Module Carbon

# Heres the backup file.
# This was a folder that existed on my demo machine and I had shared out as a shared folder
Get-ChildItem \\bhurt-demo-sql1\Downloads\*.bak

# Try to restore it so we can demo
# This failed in the demo deliberately for insufficient rights. 
Get-ChildItem \\bhurt-demo-sql1\Downloads\*.bak | Restore-DbaDatabase -UseDestinationDefaultDirectories -SqlServer bhurt-demo-sql1 -WithReplace

# What is the account name running the sql instance?
Get-WmiObject win32_service -Filter 'name="mssqlserver"' -ComputerName bhurt-demo-sql1 | Format-Table Name,StartName

# Once the service account is found I would open a remote session to the server with the share on it
# and run the following command using the Carbon module to grant access. This demonstrates how useful
# it is for DBA's to be able to gather this kind of information quickly and administer the relevant 
# machine remotely without having to rdp into all of the servers she has to administer.
Grant-Permission -Path C:\Users\joedba\Downloads -Permission 'FullControl' -Identity 'NT Service\MSSQLSERVER'

# The command below restores the same database backup to two different servers. This demonstrates how 
# easy it is to do tasks on multiple machines at once.
"bhurt-demo-sql1","bhurt-demo-sql2" | %{Get-ChildItem \\bhurt-demo-sql1\Downloads\*.bak | Restore-DbaDatabase -UseDestinationDefaultDirectories -SqlServer $_ -WithReplace}

# Lets look at the PowerShell SQL provider
Import-Module SQLPS

# We are setting this location to point at the sql server even though we are logged into a jump box. 
# The sql provider handles the connections to the remote machine for you.
Set-Location SQLServer:\SQL\bhurt-demo-sql1\DEFAULT\Databases\AdventureWorks2014

Get-ChildItem .\Tables


Get-ChildItem .\Tables\Person.Person\Columns

Get-ChildItem .\Tables\Person.Person\Columns | Get-Member

Get-ChildItem .\Tables | Sort-Object DataSpaceUsed -Descending | FT Name, DataSpaceUsed

$table = Get-Item .\Tables\Person.Person

$table.RowCount

$table.Script()

$table.GetType()

# Documentation https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.table.aspx

Set-Location ..

$database = Get-Item .\AdventureWorks2014

$database

$database.DatabaseOptions

$database | Format-Table Parent, RecoveryModel, Owner

$database.SetOwner('sa')

$database | Format-Table Parent, RecoveryModel, Owner

# The command above returned our user as the owner of the database even after we fixed it. 
# To update the output we need to call the refresh method on the database object.
$database.Refresh()

$database | Format-Table Parent, RecoveryModel, Owner

Set-Location ..\..

$instance = Get-Item .\Default

$instance.BackupDirectory

$instance.Edition

$instance.Logins

# By populating a variable with a list of servers we can easily gather information about a large number
# of servers using the provider, again without worrying about the details of how to connect to them.
$servers = 'bhurt-demo-sql1','bhurt-demo-sql2'

foreach($server in $servers){
    Get-ChildItem "SQLSERVER:\SQL\$server\Default\Databases" | Format-Table Parent, DisplayName, RecoveryModel, Owner
}

# We can scan the remote database and find only the ones that have a problem we want to fix, and automatically
# fix the issue. 
foreach($server in $servers){
    foreach($db in (Get-ChildItem "SQLSERVER:\SQL\$server\Default\Databases" | Where-Object {$_.Owner -ne 'sa'})){
        $db.SetOwner('sa')
        $db.refresh()
        $db
    }
}

foreach($server in $servers){
    Get-ChildItem "SQLSERVER:\SQL\$server\Default\Databases" | Format-Table Parent, DisplayName, RecoveryModel, Owner
}


# It is also very easy to do things like simply run queries against remote sql servers. The dbaTools module
# has the Invoke-Sqlcmd2 Cmdlet which is an large improvement over the standard Cmdlet.

Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql1 -Query 'Select name, create_date, compatibility_level From sys.databases'

# Runing Get-Member on the output shows that we are receiving DataTable objects. 
Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql1 -Query 'Select name, create_date, compatibility_level From sys.databases' | GM

# To keep my scripts cleaner I like to seperate the queries out into another file. Dot sourcing the file
# yields a new variable in my session that contains the queries that I want to use later in the script.
. "$env:USERPROFILE\documents\queries.ps1"

Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql1 -Query $queries.databases

# Query parameterization is critical when querying sql server. Invoke-Sqlcmd2 does it easily.
# The -as parameter also ensures that we get real PSObjects back instead of data tables.
$lastNames = "Miller","Jones","Smith"

foreach($name in $lastNames){
    Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql1 -Database AdventureWorks2014 -Query $queries.people -SqlParameters @{lastName=$name} -As PSObject
}

# Another task DBA's have to do a lot is look at query plans. The problem is that automating query plan 
# analysis usually requires shredding xml in a SQL Query, and most of really hate dealing with XML in 
# T-Sql. With PowerShell gathering and then analyzing large numbers of query plans is very very easy. 

$plans = Invoke-Sqlcmd2 -ServerInstance bhurt-demo-sql1 -Database AdventureWorks2014 -Query $queries.queryPlans -As PSObject

$plans.where({$_.text -like "$($queries.people.Substring(0,10))*"})

[xml]$plan = ($plans.where({$_.text -like "$($queries.people.Substring(0,10))*"}) | Select-Object -first 1).query_plan

$plan.ShowPlanXML.BatchSequence.Batch.Statements.StmtSimple

#Set namespace manager
$nsMgr = new-object 'System.Xml.XmlNamespaceManager' $plan.NameTable;
$nsMgr.AddNamespace("sm", 'http://schemas.microsoft.com/sqlserver/2004/07/showplan');

$plan.SelectNodes("//sm:IndexScan",$nsMgr).DefinedValues.DefinedValue.ColumnReference

($plan.SelectNodes("//sm:RelOp",$nsMgr) | Measure-Object -Property EstimateIO -Sum).Sum