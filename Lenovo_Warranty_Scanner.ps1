#####################################
#    Lenovo Warranty Checker        #
#   Written By: Michael Venema      #
#                                   #
#       Version 1.2                 #
#     Last Edit 7/23/21             #
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

##Create a custom PS object with the information g
$finalResponse = [PSCustomObject]@{
"Serial Number"     = $response.Serial
Name                = $env:COMPUTERNAME
Model               = $model
Manufacturer        = "Lenovo"
"Warranty Name"     = $LastWarranty.Name
"Warranty Start"    = $LastWarranty.Start.split("T")[0]
"Warranty End"      = $LastWarranty.End.split("T")[0]
"In Warranty"       = $response.InWarranty
}

##displays results to console
$finalResponse
