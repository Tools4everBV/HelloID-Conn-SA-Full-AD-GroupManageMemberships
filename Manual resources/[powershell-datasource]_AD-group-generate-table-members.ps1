try {
    $groupName = $datasource.selectedGroup.name     
    Write-information "Searching AD group [$groupName]"
     
    if(-not [String]::IsNullOrEmpty($groupName)){
        $adGroup = Get-ADgroup -Filter {Name -eq $groupName}
        Write-information "Finished searching AD group [$groupName]"
         
        $users = Get-ADGroupMember $adGroup | Where objectClass -eq "user"
        $resultCount = @($users).Count
              
        Write-information "User memberships: $resultCount"
        
        if($resultCount -gt 0){
            foreach($user in $users)
            {
                $adUser = Get-ADUser $user -properties *
                $displayValue = $adUser.displayName + " [" + $adUser.sAMAccountName + "]"
                 
                $returnObject = @{sAMAccountName="$($adUser.sAMAccountName)"; name=$displayValue}
                Write-output $returnObject
            }
        } else {
            return
        }
    }
} catch {
    Write-error "Error getting members for AD group [$groupName]. Error: $($_.Exception.Message)"
    return
}
