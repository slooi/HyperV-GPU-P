$VMName = "Test"
[float]$proportionMin = 0.5
[float]$proportionMax = 0.5
[float]$proportionOptimal = 0.5

try {
	Set-VM -VMName $VMName `
		-GuestControlledCacheTypes $true `
		-LowMemoryMappedIoSpace 3gb `
		-HighMemoryMappedIoSpace 32gb `
		-AutomaticStopAction ShutDown `
		-CheckpointType Disabled
    
	$CPUManufacturer = Get-CimInstance -ClassName Win32_Processor | Foreach-Object Manufacturer
	$BuildVer = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
	if (($BuildVer.CurrentBuild -lt 22000) -and ($CPUManufacturer -eq "AuthenticAMD")) {}
	Else {
		Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
	}
	Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false 
	Set-VMVideo -VMName $VMName -HorizontalResolution 1920 -VerticalResolution 1080

	Set-VMHost -ComputerName $ENV:Computername -EnableEnhancedSessionMode $false

	if (Get-VMGpuPartitionAdapter -VMName $VMName -ErrorAction SilentlyContinue) {
		Remove-VMGpuPartitionAdapter -VMName $VMName
	}
	Add-VMGpuPartitionAdapter -VMName $VMName

	$base = 1000000000
	$encodedBase = [System.UInt64]::MaxValue

	Set-VMGpuPartitionAdapter -VMName $VMName `
		-MinPartitionVRAM ([math]::Floor($base * $proportionMin)) `
		-MaxPartitionVRAM ([math]::Floor($base * $proportionMax)) `
		-OptimalPartitionVRAM ([math]::Floor($base * $proportionOptimal)) `
		-MinPartitionEncode ([math]::Floor($encodedBase * $proportionMin)) `
		-MaxPartitionEncode ([math]::Floor($encodedBase * $proportionMax)) `
		-OptimalPartitionEncode ([math]::Floor($encodedBase * $proportionOptimal)) `
		-MinPartitionDecode ([math]::Floor($base * $proportionMin)) `
		-MaxPartitionDecode ([math]::Floor($base * $proportionMax)) `
		-OptimalPartitionDecode ([math]::Floor($base * $proportionOptimal)) `
		-MinPartitionCompute ([math]::Floor($base * $proportionMin)) `
		-MaxPartitionCompute ([math]::Floor($base * $proportionMax)) `
		-OptimalPartitionCompute ([math]::Floor($base * $proportionOptimal))

	Write-Host "GPU partition setup completed successfully for VM: $VMName"
}
catch {
	Write-Error "An error occurred: $_"
}












# Remove-VMGpuPartitionAdapter -VMName $VMName


# script above uses 18446744073709551615 which exceeds int64, but not uint64. This might cause problems

<# 
	
	    $VHDPath = ConcatenateVHDPath -VHDPath $VHDPath -VMName $VMName
    $DriveLetter = Mount-ISOReliable -SourcePath $SourcePath

    if ($(Get-VM -Name $VMName -ErrorAction SilentlyContinue) -ne $NULL) {
        SmartExit -ExitReason "Virtual Machine already exists with name $VMName, please delete existing VM or change VMName"
        }
    if (Test-Path $vhdPath) {
        SmartExit -ExitReason "Virtual Machine Disk already exists at $vhdPath, please delete existing VHDX or change VMName"
        }
    Modify-AutoUnattend -username "$username" -password "$password" -autologon $autologon -hostname $VMName -UnattendPath $UnattendPath
    $MaxAvailableVersion = (Get-VMHostSupportedVersion).Version | Where-Object {$_.Major -lt 254}| Select-Object -Last 1 
    Convert-WindowsImage -SourcePath $SourcePath -ISODriveLetter $DriveLetter -Edition $Edition -VHDFormat $Vhdformat -VHDPath $VhdPath -DiskLayout $DiskLayout -UnattendPath $UnattendPath -GPUName $GPUName -Team_ID $Team_ID -Key $Key -SizeBytes $SizeBytes| Out-Null
    if (Test-Path $vhdPath) {
        New-VM -Name $VMName -MemoryStartupBytes $MemoryAmount -VHDPath $VhdPath -Generation 2 -SwitchName $NetworkSwitch -Version $MaxAvailableVersion | Out-Null
        Set-VM -Name $VMName -ProcessorCount $CPUCores -CheckpointType Disabled -LowMemoryMappedIoSpace 3GB -HighMemoryMappedIoSpace 32GB -GuestControlledCacheTypes $true -AutomaticStopAction ShutDown
        Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false 
        $CPUManufacturer = Get-CimInstance -ClassName Win32_Processor | Foreach-Object Manufacturer
        $BuildVer = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        if (($BuildVer.CurrentBuild -lt 22000) -and ($CPUManufacturer -eq "AuthenticAMD")) {
            }
        Else {
            Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
            }
        Set-VMHost -ComputerName $ENV:Computername -EnableEnhancedSessionMode $false
        Set-VMVideo -VMName $VMName -HorizontalResolution 1920 -VerticalResolution 1080
        Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector
        Enable-VMTPM -VMName $VMName 
        Add-VMDvdDrive -VMName $VMName -Path $SourcePath
        Assign-VMGPUPartitionAdapter -GPUName $GPUName -VMName $VMName -GPUResourceAllocationPercentage $GPUResourceAllocationPercentage
        Write-Host "INFO   : Starting and connecting to VM"
	#>