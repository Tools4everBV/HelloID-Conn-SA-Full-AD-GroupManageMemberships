try {
    $groupName = $formInput.selectedGroup.name
      
    HID-Write-Status -Message "Searching AD group [$groupName]" -Event Information
      
    if([String]::IsNullOrEmpty($groupName) -eq $true){
        Hid-Add-TaskResult -ResultValue []
    } else {
        $adGroup = Get-ADgroup -Filter {Name -eq $groupName}
        HID-Write-Status -Message "Finished searching AD group [$groupName]" -Event Information
          
        $users = Get-ADGroupMember $adGroup | Where-Object objectClass -eq "user"
        $resultCount = @($users).Count
               
        Hid-Write-Status -Message "User memberships: $resultCount" -Event Information
        HID-Write-Summary -Message "User memberships: $resultCount" -Event Information
         
        if($resultCount -gt 0){
            foreach($user in $users)
            {
                $adUser = Get-ADUser $user -properties *
                $displayValue = $adUser.displayName + " [" + $adUser.sAMAccountName + "]"
                  
                $returnObject = @{sAMAccountName="$($adUser.sAMAccountName)"; name=$displayValue}
                Hid-Add-TaskResult -ResultValue $returnObject
            }
        }else{
            Hid-Add-TaskResult -ResultValue []
        }
    }
} catch {
    HID-Write-Status -Message "Error getting members for AD group [$groupName]. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Error getting members for AD group [$groupName]." -Event Failed
     
    Hid-Add-TaskResult -ResultValue []
}