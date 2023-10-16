# Azure Networking Discovery v1.0.0
# Simple script to pull base subscription and network configuration from an Azure Tenancy
#
#  TO DO:
#
#      - Add Firewall Discovery peices
#      - Add Azure Front Door Discovery
#      - Add Azure App Gateway/Load Balancer Discovery
#      - Log to Data Source

#  Jason Chapman
#  jason@serjac.co.nz


# ------------------------------------------------------------------------

# Functions

# Validate GUID

function Validate-Guid
{
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]

        [string]$StringGuid
    )
 
   $ObjectGuid = [System.Guid]::empty

   # Returns True if successfully parsed

   return [System.Guid]::TryParse($StringGuid,[System.Management.Automation.PSReference]$ObjectGuid) 
}


# Write outputs




# ------------------------------------------------------------------------

# Start


# Collect Tenant-ID then connect to Azure


try {

    $CustomerTenantID = Read-Host -Prompt 'Input your customer Tenant-ID'


    # Check if GUID

        if((Validate-Guid($CustomerTenantID)) -eq $true){

            # Valid GUID, try connecting

            Connect-AzAccount


        }
        else{

            Write-Host "Not a valid Tenant ID - must be in 00000000-0000-0000-0000-000000000000 format, exiting"

            Exit

        }
}
catch {

    Write-Host "Can't login or connect to Azure Login service, exiting"

    Exit

}


# Main Routine


try {

    $subScriptions = Get-AzSubscription


    # Main routine loop to get discovery information


    ForEach($subScription in $subScriptions) {

            # Break subscriptions array into single entries

            $subscriptionNameArray = $subScription.Name.Split("`n")

            # Loop for each subscription found

            for ($k=0; $k -lt $subscriptionNameArray.Count; $k++) {

               $subscriptionName = $subscriptionNameArray[$k]

               Write-Host "-------------------------------------------------------------------------------"

               Write-Host $subscriptionName

               Write-Host "-------------------------------------------------------------------------------"

               $contextName = $subscriptionName + ".context"

               # Create a context to query details for each subscriptio
           
               Set-AzContext -Name $contextName -Subscription $subscriptionName -Tenant $CustomerTenantID

               # Begin network queries

               Write-Host "-------------------------------------------------------------------------------"
               Write-Host " Basic Networking Information"
               Write-Host "-------------------------------------------------------------------------------"
                
                    $vNets = Get-AzVirtualNetwork 

                    ForEach($vNet in $vNets) {

                        # Get Network Basics

                        Write-host "vNet Name: " $vNet.Name

                        Write-host "vNet Resource Group: " $vNet.ResourceGroupName 
                        Write-host "vNet Location: " $vNet.Location
                        Write-host "vNet Resources GUID: " $vNet.ResourceGuid


                        $jsonAddressSpace = $vnet.AddressSpaceText | ConvertFrom-Json

                        # Get Prefix

                        Write-host "vNet Address Prefix: " $jsonAddressSpace.AddressPrefixes

                        # Get BGP Communities

                        if ($vNet.BgpCommunities -eq $null) {

                            Write-Host "vNet BGP Communities: NULL"
                        }
                        else {

                            Write-Host "vNet BGP Communities: " $vNet.BgpCommunities
                        }

                        # Work out Subnets within vNet
  

                        $jsonSubnets = $vnet.SubnetsText | ConvertFrom-Json


                        # Nested subnets, match subnet name with IP prefix

                        # Create arrays

                        $subNetsNameArray = $jsonSubnets.Name.Split(" ") 

                        $subNetPrefixArray = $jsonSubnets.AddressPrefix.Split(" ")
                        
                        Write-Host "Nested Subnets Found: " $subNetsNameArray.Count

                                # Join subnet name and prefix

                                for ($i=0; $i -lt $subNetPrefixArray.Count; $i++) {
  
                                    Write-host "Subnet:("$subNetPrefixArray[$i]","$subNetsNameArray[$i]")"
                                }

                        # Empty arrays for the loop through

                        $subNetsArray = ""

                        $subNetPrefixArray = ""

                        # Derive NSG Name
    
                        $vNetNsg = ($jsonSubnets.NetworkSecurityGroup.Id -split '\/')[-1]

                        Write-Host "NSG : " $vNetNsg

                        # Derive Route Table Name
    
                        $RouteTable = ($jsonSubnets.RouteTable.Id -split '\/')[-1]

                        Write-Host "Route Table Name:"  $RouteTable

                        # If vNet peerings found List them out
                    
                        if ($vNet.VirtualNetworkPeerings -eq $null) {

                            Write-Host "vNet Peerings Found: NULL"
                        }
                        else {

                            Write-Host "vNet Peerings Found: " $vNet.VirtualNetworkPeerings.Name

                        }

                        # Get DNS Setting from vNet
   

                        $jsonDhcpOptions = $vNet.DhcpOptionsText | ConvertFrom-Json

                         Write-Host "-------------------------------------------------------------------------------"
                         Write-Host "vNet DNS Settings"                         Write-Host "-------------------------------------------------------------------------------"

                        if ($jsonDhcpOptions.DnsServers -eq $null) {

                            Write-Host "DNS Servers on vNet Found: NULL"
                        }
                        else {

                            # Create array and split out entries

                            $dnsServerArray = $jsonDhcpOptions.DnsServers.Split(" ") 

                            Write-Host "DNS Servers Found: " $dnsServerArray.Count

                             for ($j=0; $j -lt $dnsServerArray.Count; $j++) {
  
                                    Write-host "DNS Server: " $dnsServerArray[$j] 
                                }


                        }

                        Write-Host "-------------------------------------------------------------------------------"
                    }   
                     
                    # Dispose context after use             

                    Remove-AzContext -Name $contextName -Force -WarningAction SilentlyContinue

         }

    }

}
catch {

    # Write some error handling here (version 2)

    Write-Host "Ërror in main routine, I found something I couldn't handle"


}

# End


# ------------------------------------------------------------------------


