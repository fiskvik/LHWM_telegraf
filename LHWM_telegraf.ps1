cls
$dll = "LibreHardwareMonitorLib.dll"

Unblock-File -LiteralPath $dll
Add-Type -LiteralPath $dll

try {
    $scriptPath = $PSScriptRoot
    if (!$scriptPath)
    {
        if ($psISE)
        {
            $scriptPath = Split-Path -Parent -Path $psISE.CurrentFile.FullPath
        }
        else {
            Write-Host -ForegroundColor Red "Cannot resolve script file's path"
            exit 1
        }
    }
}
catch {
    Write-Host -ForegroundColor Red "Caught Exception: $($Error[0].Exception.Message)"
    exit 2
}

#Write-Host "Path: $scriptPath"
. $scriptPath\UpdateVisitor.ps1



$monitor = [LibreHardwareMonitor.Hardware.Computer]::new()

#(New-Object LibreHardwareMonitor.Hardware.Computer) | Get-Member

$monitor.IsBatteryEnabled = $true
$monitor.IsControllerEnabled = $true
$monitor.IsCPUEnabled = $true
$monitor.IsGpuEnabled = $true
$monitor.IsMemoryEnabled = $true
$monitor.IsMotherboardEnabled = $true
$monitor.IsNetworkEnabled = $true
$monitor.IsPsuEnabled = $true
$monitor.IsStorageEnabled = $true

$monitor.Open()

$monitor.Accept([UpdateVisitor]::new());
$strings = "Name", "Index", "HardwareType", "SensorType", "Value"


foreach ($hardware in $monitor.Hardware) {
        #write-host $hardware.GetReport();
        #write-host $hardware.Identifier
	foreach ($sensor in $hardware.Sensors) {
                $out = [System.Text.StringBuilder]""
                $null = $out.AppendLine("LibreHardwareMonitor")
                foreach ($string in $strings) {
                        if (!([string]::IsNullOrWhitespace($hardware.$string))) {
	                        $null = $out.AppendLine((",hw_$string=$hardware.$string").Replace(" ","_"))
			}
                }
                foreach ($string in $strings) {
                        if (!([string]::IsNullOrWhitespace($sensor.$string))) {
			        if $string.equals("Value") {
	                                $null = $out.AppendLine((" $string=$hardware.$string").Replace(" ","_"))
	                        } else {
			                $null = $out.AppendLine((",$string=$hardware.$string").Replace(" ","_"))
	                        }
			}
                }
        }
        foreach ($subHardware in $hardware.SubHardware) {
                #write-host $hardware.GetReport()
                #write-host "Subhardware:" $subHardware.Name;
	        foreach ($sensor in $subHardware.Sensors) {
                        $out = [System.Text.StringBuilder]""
                        $null = $out.AppendLine("LibreHardwareMonitor")
                        foreach ($string in $strings) {
                                if (!([string]::IsNullOrWhitespace($hardware.$string))) {
	                                $null = $out.AppendLine((",hw_$string=$hardware.$string").Replace(" ","_"))
		        	}
                        }
                        foreach ($string in $strings) {
                                if (!([string]::IsNullOrWhitespace($hardware.$string))) {
	                                $null = $out.AppendLine((",subhw_$string=$hardware.$string").Replace(" ","_"))
		        	}
                        }
                        foreach ($string in $strings) {
                                if (!([string]::IsNullOrWhitespace($sensor.$string))) {
	        		        if $string.equals("Value") {
	                                        $null = $out.AppendLine((" $string=$hardware.$string").Replace(" ","_"))
	                                } else {
		        	                $null = $out.AppendLine((",$string=$hardware.$string").Replace(" ","_"))
	                                }
	        		}
                        }
	        }
	}
}
$monitor.Close()
