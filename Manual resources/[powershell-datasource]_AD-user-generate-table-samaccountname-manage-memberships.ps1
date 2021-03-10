try {
    $ous = $ADusersSearchOU | ConvertFrom-Json
    $users = foreach($item in $ous) {
        Get-ADUser -Filter {Name -like "*"} -SearchBase $item.ou -properties displayName, sAMAccountName
    }
    
    $users = $users | Sort-Object -Property DisplayName
    $resultCount = @($users).Count
    Write-information "Result count: $resultCount"
    
if($resultCount -gt 0){
        foreach($user in $users){
            $displayValue = $user.displayName + " [" + $user.sAMAccountName + "]"
            $returnObject = @{sAMAccountName=$user.sAMAccountName; name=$displayValue}
    
            Write-output $returnObject
        }
    } else {
        return
    }
} catch {
    Write-error "Error searching AD users. Error: $($_.Exception.Message)"
    return
}
