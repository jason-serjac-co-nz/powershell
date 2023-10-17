
# Azure Route Table and NSG Testing v1.0.0
# Simple script to pull base subscription and network configuration from an Azure Tenancy
#
#  TO DO:
#
#      - Add Firewall Discovery peices
#     

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


# Main Rotine

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


               Get-AzRouteTable -Name 

               Get-AzRouteTable -ResourceGroupName "networking-pd-aue-rg " -Name "orcafdut-aue-net-rtb01" | Get-AzRouteConfig 



            }
    }
}
catch {


    Write-Host "Bad Stuff Happened"


}

 