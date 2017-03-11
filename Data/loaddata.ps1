$iterations = 5
$customerdata = "C:\Shared\customer.log"

$x = 1
$customerreader = [System.IO.File]::OpenText($customerdata)
while($null -ne ($line = $customerreader.ReadLine())) {
    $customer = $line | ConvertFrom-Json
    #write-host "INSERT INTO [dbo].[Customer]([CustomerName],[City],[StateProvince],[PostalCode]) VALUES ('$($customer.CustomerName)', '$($customer.City)', '$($customer.StateProvince)', '$($customer.PostalCode)');"
    
    $customerchance = Get-Random -Maximum 10 -Minimum 1

    if ($x -le 10) {$customerchance = 10}
    switch($customerchance) {
        5 {
            Invoke-SqlCmd "EXEC [Demo].dbo.NewSale @makeCustomer = 0"
        }
        8 {
            Invoke-SqlCmd "EXEC [Demo].dbo.UpdateCustomer @CustomerName = '$($customer.CustomerName)', @City = '$($customer.City)', @StateProvince = '$($customer.StateProvince)', @PostalCode = '$($customer.PostalCode)';"
        }
        default {
            Invoke-Sqlcmd "INSERT INTO [Demo].[dbo].[Customer]([CustomerName],[City],[StateProvince],[PostalCode]) VALUES ('$($customer.CustomerName)', '$($customer.City)', '$($customer.StateProvince)', '$($customer.PostalCode)');"
            Invoke-SqlCmd "EXEC [Demo].dbo.NewSale @makeCustomer = 1"
        }
    }

    $x = $x + 1

    $wait = Get-Random -Maximum 5 -Minimum 1
    Start-Sleep -s $wait


    if ($x -ge $iterations) {exit}

}
$customerreader.Close()