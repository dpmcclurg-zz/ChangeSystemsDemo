$productdata = "C:\Shared\product.log"
$customerdata = "C:\Shared\customerinitial.log"

$productreader = [System.IO.File]::OpenText($productdata)
while($null -ne ($line = $productreader.ReadLine())) {
    $product = $line | ConvertFrom-Json

    Invoke-Sqlcmd "INSERT INTO [Demo].[dbo].[Product]([ProductName],[Price]) VALUES ('$($product.ProductName)', $($product.Price));"
}
$productreader.Close()

$customerreader = [System.IO.File]::OpenText($customerdata)
while($null -ne ($line = $customerreader.ReadLine())) {
    $customer = $line | ConvertFrom-Json

    Invoke-Sqlcmd "INSERT INTO [Demo].[dbo].[Customer]([CustomerName],[City],[StateProvince],[PostalCode]) VALUES ('$($customer.CustomerName)', '$($customer.City)', '$($customer.StateProvince)', '$($customer.PostalCode)');"
    Invoke-SqlCmd "EXEC [Demo].dbo.NewSale @makeCustomer = 1"

    Start-Sleep -s 1

}
$customerreader.Close()