
$tests = Get-OperationValidation -ModuleName OVF.Example1
$results = $tests | Invoke-OperationValidation -IncludePesterOutput
$results