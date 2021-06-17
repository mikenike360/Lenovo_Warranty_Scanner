#####################################
#    Lenovo Warranty Checker        #
#   Written By: Michael Venema      #
#    Edited By: George Stedman      #
#       Version 1.1                 #
#     Last Edit 6/17/21             #
#####################################

##Grabs the serial number from the local computer
$serial = Get-WmiObject win32_bios | Select-Object -ExpandProperty SerialNumber

##Grabs the computer model from the local computer
$model =  Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty SystemFamily

##Sets the header to be used in the API request. The client ID is the unique lenovo api token
$Headers = @{
    "ClientID" = "<INSERT LENOVO API KEY HERE AND REMOVE CARROTS LEAVE QUOTES>"
    "Content-Type" = "application/x-www-form-urlencoded"
}

##Invokes a get request to grab the warranty information using the serial gathered from the local machine
$response = Invoke-RestMethod "https://supportapi.lenovo.com/v2.5/warranty?Serial=$serial" -Method 'GET' -Headers $Headers

##Loops through the response and grabs the data we want
$response | ForEach-Object {
    $_.Warranty | ForEach-Object {
        $LastWarranty = $_
    }
}

##Grabs todays date and compares it to the warranty date to see
##if the computer is in warranty
$date = Get-Date
$WEnd = [datetime]::parseexact($lastWarranty.End.split("T")[0], 'yyyy-MM-dd', $null)
if ($WEnd -gt $date){
    $In = "True"
}else{
    $In = "False"
}

##Create a custom PS object with the information g
$finalResponse = [PSCustomObject]@{
"Serial Number"     = $response.Serial
Name                = $env:COMPUTERNAME
Model               = $model
Manufacturer        = "Lenovo"
"Warranty Name"     = $LastWarranty.Name
"Warranty Start"    = $LastWarranty.Start.split("T")[0]
"Warranty End"      = $LastWarranty.End.split("T")[0]
"In Warranty"       = $In
}

##displays results to console
$finalResponse
