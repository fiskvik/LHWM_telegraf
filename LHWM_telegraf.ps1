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

foreach ($hardware in $monitor.Hardware) {
        #write-host $hardware.GetReport();
        #write-host $hardware.Identifier
	foreach ($sensor in $hardware.Sensors) {
                $out = "LibreHardwareMonitor"
                $out += ","
                $out += "hardware="
                $out += $hardware.Name
                $out += ","
                #$out += "hardwareid="
                #$out += $hardware.Identifier

                if (!([string]::IsNullOrWhitespace($hardware.Index))) {
                        $out += "hardwareidx="
                        $out += $hardware.Index
                        $out += ","
                } else {

                }

                $out += "name="
		$out += $sensor.Name
                $out += ","
                #$out += "sensorid="
                #$out += $sensor.Identifier
                $out += "sensoridx="
                $out += $sensor.Index
                $out += ","
                $out += "type="
		$out += $sensor.SensorType
                $out = $out.Replace(" ","_")
                $out += " "
		$out += $sensor.Value
                write-host $out
                #write-host $sensor.Index
                #write-host $hardware.Index
        }
        foreach ($subHardware in $hardware.SubHardware) {
                #write-host $hardware.GetReport()
                #write-host "Subhardware:" $subHardware.Name;
	        foreach ($sensor in $subHardware.Sensors) {
                        $out = "LibreHardwareMonitor"
                        $out += ","
                        $out += "hardware="
                        $out += $hardware.Name
                        $out += ","
                        $out += "hardwareid="
                        $out += $hardware.Identifier
                        $out += ","
                        $out += "subhardware="
                        $out += $subHardware.Name
                        $out += ","
                        $out += "subhardwareid="
                        $out += $subhardware.Identifier
                        $out += ","
                        $out += "name="
        		$out += $sensor.Name
                        $out += ","
                        $out += "sensorid="
                        $out += $sensor.Identifier
                        $out += ","
                        $out += "type="
        		$out += $sensor.SensorType
                        $out = $out.Replace(" ","_")
                        $out += " "
        		$out += $sensor.Value
                        write-host $out
	        }
	}
}
$monitor.Close()