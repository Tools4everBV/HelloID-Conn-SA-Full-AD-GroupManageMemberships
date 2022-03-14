$groupName = $form.gridGroups.name
$usersToAdd = $form.members.leftToRight
$usersToRemove = $form.members.rightToLeft

try{
    $adGroup = Get-ADgroup -Filter { Name -eq $groupName }
    Write-Information "Found AD group [$groupName]"
}catch{
    Write-Error "Could not find AD group [$groupName]. Error: $($_.Exception.Message)"
    throw "Failed to find AD group [$groupName]"
}

if($usersToAdd -ne $null){
    try{
        Write-Information "Starting to add AD group [$groupName] to AD users $($usersToAdd | Out-String)"
        
        $addMember = Add-ADGroupMember -Identity $adGroup -Members $usersToAdd.sAMAccountName -Confirm:$false
        Write-Information "Finished adding AD group [$groupName] to AD users  $($usersToAddJson.sAMAccountName)"
    }catch{
        Write-Error "Could not add AD group [$groupName] to AD users $($usersToAddJson.sAMAccountName). Error: $($_.Exception.Message)"
        throw "Failed to add AD group [$groupName] to AD users  $($usersToAddJson.sAMAccountName)"
    }
}


if($usersToRemove -ne $null){
    try{
        Write-Information "Starting to remove AD group [$groupName] from AD users $($usersToRemove | Out-String)"
        
        $removeMember = Remove-ADGroupMember -Identity $adGroup -Members $usersToRemove.sAMAccountName -Confirm:$false
        Write-Information "Finished removing AD group [$groupName] from AD users $($usersToRemove.sAMAccountName)"
    }catch{
        Write-Error "Could not remove AD group [$groupName] from users $($usersToRemove.sAMAccountName). Error: $($_.Exception.Message)"
        throw "Failed to remove AD group [$groupName] from users $($usersToRemove.sAMAccountName)"
    }    
}
