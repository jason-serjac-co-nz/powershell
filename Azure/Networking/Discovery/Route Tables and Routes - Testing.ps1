



# Get-AzVirtualNetworkPeering -VirtualNetworkName "pd-aue-net-vnet" -ResourceGroupName "networking-pd-aue-rg"



# Get-AzRouteTable -ResourceGroupName "networking-pd-aue-rg" -Name "orcafdut-aue-net-rtb01" | Get-AzRouteConfig




# Show Routes in Route Tables

# Get-AzRouteTable -ResourceGroupName "networking-pd-aue-rg" -Name "orcafdut-aue-net-rtb01" | Get-AzRouteConfig | Select AddressPrefix,Name,NextHopType,NextHopIpAddress




function Get-RoutingInfo
{
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]

        [string]$subscriptionID
    )

    try {

        Write-Host "-------------------------------------------------------------------------------"

        Write-Host "Collecting Routing Information..."

        Write-Host "-------------------------------------------------------------------------------"

        $routeTables = Get-AzRouteTable | Select ResourceGroupName,Name,Location

        Write-Host "Route tables found in subscription ID:" + $subscriptionID

        Write-Host "-------------------------------------------------------------------------------"

        $routeTables

        Write-Host "-------------------------------------------------------------------------------"

        Write-Host "Routes table breakdown"

        Write-Host "-------------------------------------------------------------------------------"

        ForEach($routeTable in $routeTables) {

            Write-Host "Routes in route table: " $routeTable.Name    
            
            Get-AzRouteTable -ResourceGroupName $routeTable.ResourceGroupName -Name $routeTable.Name | Get-AzRouteConfig | Select AddressPrefix,Name,NextHopType,NextHopIpAddress

            Write-Host "-------------------------------------------------------------------------------"

        }

        # Success return true

        return $true

    }
    catch {

        # Failed return false

        return $false

    }


}




Get-RoutingInfo("00000000-0000-0000-0000-000000000000")                