#cls
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

$strings = "Name", "Index", "HardwareType", "SensorType", "Value"

$monitor = [LibreHardwareMonitor.Hardware.Computer]::new()


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

Function Read-Sensors {
        foreach ($hardware in $monitor.Hardware) {
                #write-host $hardware.GetReport();
                #write-host $hardware.Identifier
                foreach ($sensor in $hardware.Sensors) {
                        $out = [System.Text.StringBuilder]""
                        $null = $out.Append("LibreHardwareMonitor")
                        foreach ($string in $strings) {
                                if ($string.equals("Value")) {
                                        if (!([string]::IsNullOrWhitespace($sensor.$string))) {
                                                $null = $out.Append(" " + $string + "=" + $sensor.$string)
                                        } else {
                                                $null = $out.Append(" " + $string + "=0")
					}
                                } else {
                                        if (!([string]::IsNullOrWhitespace($hardware.$string))) {
                                                 if ($string.equals("HardwareType")) {
                                                         $null = $out.Append((","+$string+"="+$hardware.$string).Replace(" ","_"))
                                                 } else {
                                                         $null = $out.Append((",Hardware"+$string+"="+$hardware.$string).Replace(" ","_"))
                                                 }
                                        }
                                        if (!([string]::IsNullOrWhitespace($sensor.$string))) {
                                                if ($string.equals("SensorType")) {
                                                         $null = $out.Append(("," + $string + "=" + $sensor.$string).Replace(" ","_"))
                                                } else {
                                                        $null = $out.Append((",Sensor" + $string + "=" + $sensor.$string).Replace(" ","_"))
						}
                                        }
                                }
                        }
                        write-host $out.ToString()
                }
                foreach ($subHardware in $hardware.SubHardware) {
                        #write-host $hardware.GetReport()
                        #write-host "Subhardware:" $subHardware.Name;
                        foreach ($sensor in $subHardware.Sensors) {
                                $out = [System.Text.StringBuilder]""
                                $null = $out.Append("LibreHardwareMonitor")
                                write-host $out.ToString()
                                foreach ($string in $strings) {
                                        if ($string.equals("Value")) {
                                                if (!([string]::IsNullOrWhitespace($sensor.$string))) {
                                                        $null = $out.Append(" " + $string + "=" + $sensor.$string)
                                                } else {
                                                        $null = $out.Append(" " + $string + "=0")
						}
                                        } else {
                                                if (!([string]::IsNullOrWhitespace($hardware.$string))) {
                                                         if ($string.equals("HardwareType")) {
                                                                 $null = $out.Append((","+$string+"="+$hardware.$string).Replace(" ","_"))
                                                         } else {
                                                                 $null = $out.Append((",Hardware"+$string+"="+$hardware.$string).Replace(" ","_"))
                                                         }
                                                }
                                                if (!([string]::IsNullOrWhitespace($subhardware.$string))) {
                                                         if ($string.equals("HardwareType")) {
                                                                 $null = $out.Append((",Sub" + $string + "=" + $subhardware.$string).Replace(" ","_"))
                                                         } else {
                                                                 $null = $out.Append((",SubHardware" + $string + "=" + $subhardware.$string).Replace(" ","_"))
                                                         }
                                                }
                                                if (!([string]::IsNullOrWhitespace($sensor.$string))) {
                                                         if ($string.equals("SensorType")) {
                                                                 $null = $out.Append(("," + $string + "=" + $sensor.$string).Replace(" ","_"))
                                                        } else {
                                                                $null = $out.Append((",Sensor" + $string + "=" + $sensor.$string).Replace(" ","_"))
							}
                                                }
                                        }
                                }
                        }
                }
        }
}

Function Start-Monitoring {
    While ($true) {
        # Do things lots
        #Write-Host -NoNewLine 'Press any key to continue...';
        #$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        $null = [System.Console]::ReadLine()
        $monitor.Accept([UpdateVisitor]::new());
        Read-Sensors
    }
}

Start-Monitoring

$monitor.Close()
