
# Name: call_api.<domain-name>_RO.ps1
# Description:
#
#   Simple script sends HTTP gets to api.<domain-name>, useful when secrurity testing API's or traffic flows
#
#   Jason Chapman
#   jason@serjac.co.nz
#   Version 1.1
#   28/08/2023

# Start Transcript


Start-Transcript -Path C:\temp\api_calls.<domain-name>.txt

# Create Headers Dictionary

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

# Set Headers

$headers.Add('X-Brand-ID','<string>')

$headers.Add('X-Application-ID','CURL')

$headers.Add('X-Channel-ID','CURL')

$headers.Add('x-version','11')

# Auth headers

$headers.Add('client_id','<client-id>')

$headers.Add('client_secret','<client-secret>')


# Call API Loop


  for($i = 0; $i -lt 3; $i++)
    {

        try {

        # Call API

         $response = Invoke-WebRequest -Uri 'https://api.<domain-name>/<uri>' -Headers $headers

        # Write to Host and Transcript
       
        Write-Host (Get-Date)'   Çall Number: '$i
        Write-Host (Get-Date)'   Response Payload: '$response
        Write-Host (Get-Date)'   Headers Retured: ' + $response.Headers
        Write-Host (Get-Date)'   Response Code Returned: '$response.StatusCode

        Start-Sleep 1


        }
        catch {

        # Write Errors to Host and Transcript

            Write-Host  (Get-Date)'   $i - Unable to reach - api.<domain-name>' -ForegroundColor Red
        }
        
    }


# Stop transcript

 Stop-Transcript