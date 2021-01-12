HID-Write-Status -Message "Users to add: $usersToAdd" -Event Information
HID-Write-Status -Message "Users to remove: $usersToRemove" -Event Information

try{
    $adGroup = Get-ADgroup -Filter { Name -eq $groupName }
    HID-Write-Status -Message "Found AD group [$groupName]" -Event Information
    HID-Write-Summary -Message "Found AD group [$groupName]" -Event Information
}catch{
    HID-Write-Status -Message "Could not find AD group [$groupName]. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Failed to find AD group [$groupName]" -Event Failed
}

if($usersToAdd -ne "[]"){
    try{
        HID-Write-Status -Message "Starting to add AD group [$groupName] to AD users $usersToAdd" -Event Information
        $usersToAddJson =  $usersToAdd | ConvertFrom-Json
        
        Add-ADGroupMember -Identity $adGroup -Members $usersToAddJson.sAMAccountName -Confirm:$false
        HID-Write-Status -Message "Finished adding AD group [$groupName] to AD users $usersToAdd" -Event Success
        HID-Write-Summary -Message "Successfully added AD group [$groupName] to AD users $usersToAdd" -Event Success
    }catch{
        HID-Write-Status -Message "Could not add AD group [$groupName] to AD users $usersToAdd. Error: $($_.Exception.Message)" -Event Error
        HID-Write-Summary -Message "Failed to add AD group [$groupName] to AD users $usersToAdd" -Event Failed
    }
}


if($usersToRemove -ne "[]"){
    try{
        HID-Write-Status -Message "Starting to remove AD group [$groupName] from AD users $usersToRemove" -Event Information
        $usersToRemoveJson =  $usersToRemove | ConvertFrom-Json
        
        Remove-ADGroupMember -Identity $adGroup -Members $usersToRemoveJson.sAMAccountName -Confirm:$false
        HID-Write-Status -Message "Finished removing AD group [$groupName] from AD users $usersToRemove" -Event Success
        HID-Write-Summary -Message "Successfully removed AD group [$groupName] from AD users $usersToRemove" -Event Success
    }catch{
        HID-Write-Status -Message "Could not remove AD group [$groupName] from users $usersToRemove. Error: $($_.Exception.Message)" -Event Error
        HID-Write-Summary -Message "Failed to remove AD group [$groupName] from users $usersToRemove" -Event Failed
    }    
}
