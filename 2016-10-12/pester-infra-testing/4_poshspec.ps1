#requires -modules poshspec
Import-Module -Name poshspec

describe 'Stuff' {

    context 'Folders and files' {
        folder 'c:\src' { should exist }
        folder 'c:\temp' { should exist }
        file 'C:\HashiCorp\Vagrant\bin\vagrant.exe' { should exist }       
    }   

    context 'Services' {
        service 'dhcp' 'status' { should be 'running' }
        service 'dnscache' 'status' { should be 'running' }
    }

    context 'Registry' {
        registry 'HKLM:\SOFTWARE\Bad key\' { should not exist }
    }

    context 'DNS Resolution' {
        dnshost 'www.google.com' { should not be $null }
    }

    context 'WSMan' {
        firewall 'Windows Remote Management (HTTP-In)' 'enabled' { should be $true }
        service 'winrm' 'status' { should be 'running' }
        service 'winrm' 'starttype' { should be 'automatic' }
        tcpport 'localhost' 5985 'TcpTestSucceeded' { should Be $true }
    }

    context 'Applications' {
        package 'Microsoft Visual Studio Code' { should not benullorempty }
        package 'Bad Application' { should benullorempty}
    }
}