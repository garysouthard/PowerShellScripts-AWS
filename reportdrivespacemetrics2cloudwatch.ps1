# October 30 2015  G Southard with expertise from C Potts

#Set Items based upon server this script is running on
# Set Instance ID
$instanceId=invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
# ECHO $instanceId
# Set Instance Name (based upon the tag)
$instanceTagName =   Get-EC2Instance -Filter @( @{name='instance-id'; values="i-4dfb50ee"}; ) | %{ $_.Instances.Tags }| ? { $_.Key -eq "Name" }| %{$_.Value}
# ECHO $instanceTagName

#Create request

#Get Free Space
$freeSpace=Get-WmiObject -Class Win32_LogicalDisk | Select-Object -Property DeviceID, @{Name='FreeSpaceGB';Expression={$_.FreeSpace/1GB}} | Where-Object {$_.DeviceID -eq "C:" -or $_.DeviceID -eq "E:" }
# Set NameSpace
$NameSpace = "CUSTOM-DiskFree"
#Create dimensions
$dimension1 = New-Object -TypeName Amazon.CloudWatch.Model.Dimension
$dimension2 = New-Object -TypeName Amazon.CloudWatch.Model.Dimension
 
$dimension1.Name = "ServerName"
$dimension1.Value = $instanceTagName
$dimension2.Name = "InstanceId"
$dimension2.Value = $instanceId
#ECHO $instanceId
 
Foreach ($item in $freeSpace) 
{

$dat = New-Object Amazon.CloudWatch.Model.MetricDatum
$dat.Dimensions = New-Object 'System.Collections.Generic.List[Amazon.CloudWatch.Model.Dimension]'
$dat.Dimensions.Add($dimension1)
$dat.Dimensions.Add($dimension2)
$dat.Timestamp = (Get-Date).ToUniversalTime() 
$dat.MetricName = $item.DeviceID + "_free space"
$dat.Unit = "Gigabytes"
$dat.Value = $item.FreeSpaceGB
Write-CWMetricData -Namespace $NameSpace -MetricData $dat

}
