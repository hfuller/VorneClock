function Send-VorneSerialClock {
	#param ( [parameter(Mandatory=$true, ValueFromPipeline=$true)] [int[]] $byte )
	param ( [parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $string )
	#$PortName = (Get-WmiObject Win32_SerialPort | Where-Object { $_.Name -match "erial"}).DeviceID
	#if ( $PortName -eq $null ) { throw "Serial Not Found"}
	#throw $PortName
	$PortName = "COM3"
	#Create SerialPort and Configure
	$port = New-Object System.IO.Ports.SerialPort
	$port.PortName = $PortName
	$port.BaudRate = "9600"
	$port.Parity = "None"
	$port.DataBits = 8
	$port.StopBits = 1
	$port.ReadTimeout = 2000 #Milliseconds
	$port.open() #open serial connection
	Start-Sleep -Milliseconds 100 #wait 0.1 seconds
	$header = 0x01,0x73,0x3A,0x44
	$port.Write($header,0,$header.Count)
	#$port.Write($byte,0,$byte.Count) #write $byte parameter content to the serial connection
	$port.Write($string) #simpler
	$footer = 0x0D
	$port.Write($footer,0,$footer.Count)
	#tryÂ Â  Â {
	##Check for response
	#if (($response = $port.ReadLine()) -gt 0)
	#{ $response }
	#}
	#catch [TimeoutException] {
	#"Time Out"
	#}
	#finallyÂ Â  Â {
	#$port.Close() #close serial connection
	#}
	$port.Close() #close serial connection

}


#Send-VorneSerialClock(0x38,0x38,0x38,0x38,0x38,0x36)
#Send-VorneSerialClock("80085")

function Update-Date {
	$x = Get-Date
	$str = ("" + $x.Hour).PadLeft(2,'0') + ("" + $x.Minute).PadLeft(2,'0') + ("" + $x.Second).PadLeft(2,'0')
	Send-VorneSerialClock($str)
	#Send-VorneSerialClock("31337")
	$str
	#Start-Sleep -m 333
}

#$period = [timespan]::FromSeconds(1)
$lastRunTime = [DateTime]::MinValue 
while ($true) {
	# If the next period isn't here yet, sleep so we don't consume CPU
    while ((Get-Date) - $lastRunTime -lt $period) { 
        Start-Sleep -Milliseconds 200
    }
    $lastRunTime = Get-Date
    Update-Date
}
