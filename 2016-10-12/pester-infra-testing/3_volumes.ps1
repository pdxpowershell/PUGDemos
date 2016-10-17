
(Get-ChildItem -Path c:\temp -Filter *.vhd -File).FullName | 
    Mount-DiskImage -ErrorAction SilentlyContinue
$vols = Get-Volume | where DriveType -eq 'Fixed'

describe 'Volumes' {

    $sysDriveLetter = $env:SystemDrive.Substring(0, 1)

    context "System volume [$sysDriveLetter]" {
        
        $sysVol = $vols | Where DriveLetter -eq $sysDriveLetter
        
        it 'Is operational' {
            $sysVol.OperationalStatus | should be 'ok'
        }

        it 'Has > [500MB] free' {
            $sysVol.SizeRemaining / 1MB | should begreaterthan 500
        }

        it 'Allocation unit size is [4096]' {
            $sysVol.AllocationUnitSize | should be 4096
        }
    }

    $nonSysVols = $vols | Where DriveLetter -ne $sysDriveLetter | 
        where DriveLetter -ne $null | sort FileSystemLabel
    $nonSysVols | foreach {

        context "Non-system volume [$($_.FileSystemLabel)]" {

            if ($_.FileSystemLabel -eq 'BigAlu') {
                it 'Has [64KB] allocation unit size' { 
                    $_.AllocationUnitSize | should be (64*1KB)
                }
            }

            it 'Is operational' {
                $_.OperationalStatus | should be 'ok'
            }

            it 'Is formated NTFS' {
                $_.FileSystem | should be 'NTFS'
            }
        }
    }
}
