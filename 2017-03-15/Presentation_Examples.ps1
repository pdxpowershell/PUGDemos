<# References 
    FoxDeploy (learning XAML gui ninja skills)
    https://foxdeploy.com/2015/04/10/part-i-creating-powershell-guis-in-minutes-using-visual-studio-a-new-hope/
#>
#Example 1 - Converting data from custom objects to JSON/XML
$dummyData = [PSCustomObject]@{

    Servers = ('pdxdc1','pdxdc2','pdxsql1')
    Domain  = 'gngr.ninja'

}

#Take a peek at the object
$dummyData

#JSON conversions
$dummyData | Get-Member

$dummyData | ConvertTo-Json | Out-File .\dummyConfig.json

$configData = $null

$configData = Get-Content .\dummyConfig.json | ConvertFrom-Json

$configData | Get-Member

$configData

#XML conversions
$dummyData | Export-Clixml .\dummyConfig.xml

$configData = $null

$configData = Import-Clixml .\dummyConfig.xml

$configData | Get-Member

$configData

#End Example 1

#Begin code for each step 

#Step 1
#Define our object
$objectDesign = [PSCustomObject]@{

    WarnDays    = 'int, any amount after this and users will get a warning'
    DisableDays = 'int, any amount after this and users will be disabled'
    OUList      = 'array of strings containings OUs'

}
#End step 1

#Step 2 
#Import/Export and Generation Functions
function Invoke-ConfigurationGeneration { #Begin function Invoke-ConfigurationGeneration
    [cmdletbinding()]
    param(
        [Parameter(
                Mandatory = $false
        )]
        [ValidateSet('XML','JSON')]
        [String]
        $ExportAs = $ImportAs,
        [Parameter(
            Mandatory = $false
        )]
        $ConfigurationOptions
    )

    if (!$configurationOptions) { #Actions if we don't pass in any options to the function
        
        #The OU list will be an array
        [System.Collections.ArrayList]$ouList = @()

        #These variables will be used to evaluate last logon dates of users
        [int]$warnDays    = 23
        [int]$disableDays = 30

        #Add some fake OUs for testing purposes
        $ouList.Add('OU=Marketing,DC=FakeDomain,DC=COM') | Out-Null
        $ouList.Add('OU=Sales,DC=FakeDomain,DC=COM')     | Out-Null

        #Create a custom object to store things in
        $configurationOptions = [PSCustomObject]@{

            WarnDays    = $warnDays
            DisableDays = $disableDays
            OUList      = $ouList

        }

        #Handle different types 
        #Export the object we created as the current configuration
        Export-Config -configurationOptions $ConfigurationOptions -ExportAs $ExportAs

        Write-Verbose "Exporting generated configuration file to [$configFile]!"

    } else { #End actions for no options passed in, begin actions for if they are
        
        Export-Config -configurationOptions $ConfigurationOptions -ExportAs $ExportAs

        Write-Verbose "Exporting passed in options as configuration file to [$configFile]!"

    } #End if for options passed into function

} #End function Invoke-ConfigurationGeneration

function Export-Config { #Begin function Export-Config
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateSet('JSON','XML')]
        $ExportAs,
        [Parameter(
            Mandatory
        )]
        $ConfigurationOptions
    )

    #If there's a file, we're gonna back it up!
    if (Test-Path -Path $configFile) {

        $backup = $true       

    }

    Switch ($ExportAs) { #Begin config type switch

        'JSON' {

            if ($backup) {
                
                Get-Content $configFile | Out-File -FilePath $configFile.Replace('.json','.json.bak')

                Write-Verbose "Backed up existing configuration to $($configFile.Replace('.json','.json.bak'))!"
                Write-Verbose ""

            }
            
            $ConfigurationOptions | ConvertTo-Json | Out-File -FilePath $configFile            

        }   

        'XML' {

            if ($backup) {

                Get-Content $configFile | Out-File -FilePath $configFile.Replace('.xml','.xml.bak')

                Write-Verbose "Backed up existing configuration to $($configFile.Replace('.xml','.xml.bak'))!"
                Write-Verbose ""

            }            

            $ConfigurationOptions | Export-Clixml -Path $configFile

        }

    } #End config type switch

} #End function Export-Config

function Import-Config { #Begin function Import-Config
    [cmdletbinding()]
    param()

    Switch ($ImportAs) {

        'JSON' {

            $script:configData = Get-Content -Path $configFile | ConvertFrom-Json

        }

        'XML' {

            $script:configData  = Import-Clixml -Path $configFile

        }

    }   

} #End function Import-Config

#Null out this variable as we might have set it earlier in the script for the first example
$configData = $null

#Set our import type as JSON
$importAs = 'JSON'

#Give our wonderful file a path and name
$configFile = ".\dummyConfig.json"

Invoke-ConfigurationGeneration

Import-Config

#End step 2

#Step 3
#Create and Implement GUI
function Invoke-GUI { #Begin function Invoke-GUI
    [cmdletbinding()]
    Param()

    #We technically don't need these, but they may come in handy later if you want to pop up message boxes, etc
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

    #Input XAML here
    $inputXML = @"
<Window x:Class="psguiconfig.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:psguiconfig"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="Script Configuration" Height="281.26" Width="509.864"        
        >
    <Grid>
        <Label x:Name="lblWarningMin" Content="Warning Days" HorizontalAlignment="Left" Height="29" Margin="10,6,0,0" VerticalAlignment="Top" Width="86"/>
        <TextBox x:Name="txtBoxWarnLow" HorizontalAlignment="Left" Height="20" Margin="96,6,0,0" TextWrapping="Wrap" Text="0" VerticalAlignment="Top" Width="27"/>
        <Label x:Name="lblDisableMin" Content="Disable Days" HorizontalAlignment="Left" Height="29" Margin="134,6,0,0" VerticalAlignment="Top" Width="86"/>
        <TextBox x:Name="txtBoxDisableLow" HorizontalAlignment="Left" Height="20" Margin="220,6,0,0" TextWrapping="Wrap" Text="0" VerticalAlignment="Top" Width="27"/>
        <TextBox x:Name="txtBoxOUList" HorizontalAlignment="Left" Height="153" Margin="10,54,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="479" AcceptsReturn="True" ScrollViewer.VerticalScrollBarVisibility="Auto"/>
        <Label x:Name="lblOUs" Content="OUs To Scan" HorizontalAlignment="Left" Height="26" Margin="10,28,0,0" VerticalAlignment="Top" Width="80"/>
        <Button x:Name="btnExceptions" Content="Exceptions" HorizontalAlignment="Left" Height="43" Margin="252,6,0,0" VerticalAlignment="Top" Width="237"/>
        <Button x:Name="btnEdit" Content="Edit" HorizontalAlignment="Left" Height="29" Margin="10,212,0,0" VerticalAlignment="Top" Width="66"/>
        <Button x:Name="btnSave" Content="Save" HorizontalAlignment="Left" Height="29" Margin="423,212,0,0" VerticalAlignment="Top" Width="66"/>
    </Grid>
</Window>
"@  

    [xml]$XAML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window' 
    
    #Read XAML 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
    try {
    
        $Form=[Windows.Markup.XamlReader]::Load( $reader )
        
    }

    catch {
    
        Write-Error "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        
    }
 
    #Create variables to control form elements as objects in PowerShell
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    
        Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -Scope Global
        
    } 
    

    #Show the form
    $form.showDialog() | Out-Null

} #End function Invoke-GUI

Invoke-GUI
#End step 3

#Step 4
#Wiring up the GUI
function Invoke-GUI { #Begin function Invoke-GUI
    [cmdletbinding()]
    Param()

    #We technically don't need these, but they may come in handy later if you want to pop up message boxes, etc
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

    #Input XAML here
    $inputXML = @"
<Window x:Class="psguiconfig.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:psguiconfig"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="Script Configuration" Height="281.26" Width="509.864"        
        >
    <Grid>
        <Label x:Name="lblWarningMin" Content="Warning Days" HorizontalAlignment="Left" Height="29" Margin="10,6,0,0" VerticalAlignment="Top" Width="86"/>
        <TextBox x:Name="txtBoxWarnLow" HorizontalAlignment="Left" Height="20" Margin="96,6,0,0" TextWrapping="Wrap" Text="0" VerticalAlignment="Top" Width="27"/>
        <Label x:Name="lblDisableMin" Content="Disable Days" HorizontalAlignment="Left" Height="29" Margin="134,6,0,0" VerticalAlignment="Top" Width="86"/>
        <TextBox x:Name="txtBoxDisableLow" HorizontalAlignment="Left" Height="20" Margin="220,6,0,0" TextWrapping="Wrap" Text="0" VerticalAlignment="Top" Width="27"/>
        <TextBox x:Name="txtBoxOUList" HorizontalAlignment="Left" Height="153" Margin="10,54,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="479" AcceptsReturn="True" ScrollViewer.VerticalScrollBarVisibility="Auto"/>
        <Label x:Name="lblOUs" Content="OUs To Scan" HorizontalAlignment="Left" Height="26" Margin="10,28,0,0" VerticalAlignment="Top" Width="80"/>
        <Button x:Name="btnExceptions" Content="Exceptions" HorizontalAlignment="Left" Height="43" Margin="252,6,0,0" VerticalAlignment="Top" Width="237"/>
        <Button x:Name="btnEdit" Content="Edit" HorizontalAlignment="Left" Height="29" Margin="10,212,0,0" VerticalAlignment="Top" Width="66"/>
        <Button x:Name="btnSave" Content="Save" HorizontalAlignment="Left" Height="29" Margin="423,212,0,0" VerticalAlignment="Top" Width="66"/>
    </Grid>
</Window>
"@  

    [xml]$XAML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window' 
    
    #Read XAML 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
    try {
    
        $Form=[Windows.Markup.XamlReader]::Load( $reader )
        
    }

    catch {
    
        Write-Error "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        
    }
 
    #Create variables to control form elements as objects in PowerShell
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    
        Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -Scope Global
        
    } 
    
    #Setup the form    
    function Invoke-FormSetup { #Begin function Invoke-FormSetup

        #Here we set the default states of the objects that represent the buttons/fields
        $WPFbtnEdit.IsEnabled          = $true
        $WPFbtnSave.IsEnabled          = $false
        $WPFtxtBoxWarnLow.IsEnabled    = $false
        $WPFtxtBoxDisableLow.IsEnabled = $false
        $WPFtxtBoxOUList.IsEnabled     = $false
        $WPFbtnExceptions.IsEnabled    = $false

        #We will use the current values we imported from the script scoped variable configData
        $WPFtxtBoxWarnLow.Text    = $script:configData.WarnDays
        $WPFtxtBoxDisableLow.Text = $script:configData.DisableDays
        $WPFtxtBoxOUList.Text     = $script:configData.OUList | Out-String

    } #End function Invoke-FormSetup

    function Invoke-FormSaveData { #Begin function Invoke-FormSaveData

        #This function will perform the action to save the form data
        
        #We setup the variables based on the current values of the form
        $warnDays     = [int]$WPFtxtBoxWarnLow.Text 
        $disableDays  = [int]$WPFtxtBoxDisableLow.Text
        $ouList       = ($WPFtxtBoxOUList.Text | Out-String).Trim() -split '[\r\n]' | Where-Object {$_ -ne ''}

        #This object will contain the current configuration we would like to export
        $configurationOptions = [PSCustomObject]@{

            WarnDays    = $warnDays
            DisableDays = $disableDays
            OUList      = $ouList

        }
        
        #We then pass the configuration to the function we created earlier that will export the options we pass in
        Invoke-ConfigurationGeneration -configurationOptions $configurationOptions

        #Then we re-import the config file after it is exported via the function above        
        Import-Config 

        #Finally we revert the GUI to the original state, which will also reflect the lastest configuration that we just exported
        Invoke-FormSetup

    } #End function Invoke-FormSaveData

    #Now we perform actions using the functions we created, as well as code that runs when buttons are clicked

    #Run form setup on launch
    Invoke-FormSetup

    #Button actions
    $WPFbtnEdit.Add_Click{ #Begin edit button actions

        #This will 'open up' the form and allow fields to be edited
        $WPFbtnExceptions.IsEnabled    = $true
        $WPFbtnSave.IsEnabled          = $true
        $WPFtxtBoxWarnLow.IsEnabled    = $true
        $WPFtxtBoxDisableLow.IsEnabled = $true
        $WPFtxtBoxOUList.IsEnabled     = $true
        $WPFbtnExceptions.IsEnabled    = $true

    } #End edit button actions

    $WPFbtnSave.Add_Click{ #Begin save button actions

        #The save button calls the Invoke-FormSaveData function
        Invoke-FormSaveData

    } #End save button actions

    #Show the form
    $form.showDialog() | Out-Null

} #End function Invoke-GUI

#Import/Export and Generation Functions
function Invoke-ConfigurationGeneration { #Begin function Invoke-ConfigurationGeneration
    [cmdletbinding()]
    param(
        [Parameter(
                Mandatory = $false
        )]
        [ValidateSet('XML','JSON')]
        [String]
        $ExportAs = $ImportAs,
        [Parameter(
            Mandatory = $false
        )]
        $ConfigurationOptions
    )

    if (!$configurationOptions) { #Actions if we don't pass in any options to the function
        
        #The OU list will be an array
        [System.Collections.ArrayList]$ouList = @()

        #These variables will be used to evaluate last logon dates of users
        [int]$warnDays    = 23
        [int]$disableDays = 30

        #Add some fake OUs for testing purposes
        $ouList.Add('OU=Marketing,DC=FakeDomain,DC=COM') | Out-Null
        $ouList.Add('OU=Sales,DC=FakeDomain,DC=COM')     | Out-Null

        #Create a custom object to store things in
        $configurationOptions = [PSCustomObject]@{

            WarnDays    = $warnDays
            DisableDays = $disableDays
            OUList      = $ouList

        }

        #Handle different types 
        #Export the object we created as the current configuration
        Export-Config -configurationOptions $ConfigurationOptions -ExportAs $ExportAs

        Write-Verbose "Exporting generated configuration file to [$configFile]!"

    } else { #End actions for no options passed in, begin actions for if they are
        
        Export-Config -configurationOptions $ConfigurationOptions -ExportAs $ExportAs

        Write-Verbose "Exporting passed in options as configuration file to [$configFile]!"

    } #End if for options passed into function

} #End function Invoke-ConfigurationGeneration

function Export-Config { #Begin function Export-Config
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateSet('JSON','XML')]
        $ExportAs,
        [Parameter(
            Mandatory
        )]
        $ConfigurationOptions
    )

    #If there's a file, we're gonna back it up!
    if (Test-Path -Path $configFile) {

        $backup = $true       

    }

    Switch ($ExportAs) { #Begin config type switch

        'JSON' {

            if ($backup) {
                
                Get-Content $configFile | Out-File -FilePath $configFile.Replace('.json','.json.bak')

                Write-Verbose "Backed up existing configuration to $($configFile.Replace('.json','.json.bak'))!"
                Write-Verbose ""

            }
            
            $ConfigurationOptions | ConvertTo-Json | Out-File -FilePath $configFile            

        }   

        'XML' {

            if ($backup) {

                Get-Content $configFile | Out-File -FilePath $configFile.Replace('.xml','.xml.bak')

                Write-Verbose "Backed up existing configuration to $($configFile.Replace('.xml','.xml.bak'))!"
                Write-Verbose ""

            }            

            $ConfigurationOptions | Export-Clixml -Path $configFile

        }

    } #End config type switch

} #End function Export-Config

function Import-Config { #Begin function Import-Config
    [cmdletbinding()]
    param()

    Switch ($ImportAs) {

        'JSON' {

            $script:configData = Get-Content -Path $configFile | ConvertFrom-Json

        }

        'XML' {

            $script:configData  = Import-Clixml -Path $configFile

        }

    }   

} #End function Import-Config

#Null out this variable as we might have set it earlier in the script for the first example
$configData = $null

#Set our import type as JSON
$importAs = 'JSON'

#Give our wonderful file a path and name
$configFile = ".\dummyConfig.json"

#Check for config, generate if it doesn't exist
if (!(Test-Path -Path $configFile)) { 

    Write-Verbose "Configuration file does not exist, creating!" 
    
    #Call our function to generate the file
    Invoke-ConfigurationGeneration
    
    Import-Config     

} else {

    #Import file since it exists
    Import-Config 

}

Invoke-GUI
#end step 4