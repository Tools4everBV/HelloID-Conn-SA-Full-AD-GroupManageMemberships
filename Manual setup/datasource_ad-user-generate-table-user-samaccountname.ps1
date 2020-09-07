try {
    $ous = $searchOUs | ConvertFrom-Json
 
    $users = foreach($item in $ous) {
        Get-ADUser -Filter {Name -like "*"} -SearchBase $item.ou -properties *
    }
     
    $users = $users | Sort-Object -Property DisplayName
    $resultCount = @($users).Count
    Hid-Write-Status -Message "Result count: $resultCount" -Event Information
    HID-Write-Summary -Message "Result count: $resultCount" -Event Information
     
if($resultCount -gt 0){
        foreach($user in $users){
            $displayValue = $user.displayName + " [" + $user.sAMAccountName + "]"
            $returnObject = @{sAMAccountName=$user.sAMAccountName; name=$displayValue}
     
            Hid-Add-TaskResult -ResultValue $returnObject
        }
    } else {
        Hid-Add-TaskResult -ResultValue []
    }
} catch {
    HID-Write-Status -Message "Error searching AD users. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Error searching AD users" -Event Failed
     
    Hid-Add-TaskResult -ResultValue []
}