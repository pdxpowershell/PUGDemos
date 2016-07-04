$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Verify-JenkinsJobResult" {
    $result = Verify-JenkinsJobResult
    
    It "returns results" {
        $result | Should Not BeNullOrEmpty
    }

    it "has correct username" {
        $result.USERNAME | Should Be "JENKINSDEMO$"
    }

    it "has no workspace" {
        Test-Path ($result.WORKSPACE) | Should Be $false
    }
}