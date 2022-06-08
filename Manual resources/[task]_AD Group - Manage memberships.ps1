$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# variables configured in form
$groupName = $form.gridGroups.name
$usersToAdd = $form.members.leftToRight
$usersToRemove = $form.members.rightToLeft

try{
    $adGroup = Get-ADgroup $groupName
    Write-Information "Found AD group [$groupName]"
}catch{
    Write-Error "Could not find AD group [$groupName]. Error: $($_.Exception.Message)"
}

if($usersToAdd -ne $null){
    foreach($userToAdd in $usersToAdd){
        try{
            $adUser = Get-ADuser $userToAdd.sAMAccountName
            
            $adUserDisplayName = $adUser.DisplayName
            $adUserSID = $([string]$adUser.SID)

            $adGroupDisplayName = $adGroup.DisplayName
            $adGroupSID = $([string]$adGroup.SID)

            $addMember = Add-ADGroupMember -Identity $adGroup -Members $adUser.sAMAccountName -Confirm:$false
            Write-Information "Successfully added AD user $adUserDisplayName ($adUserSID) to group $adGroupDisplayName ($adGroupSID)"

            $Log = @{
                Action            = "GrantMembership" # optional. ENUM (undefined = default) 
                System            = "ActiveDirectory" # optional (free format text) 
                Message           = "Successfully added AD user $adUserDisplayName ($adUserSID) to group $adGroupDisplayName ($adGroupSID)" # required (free format text) 
                IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $groupName # optional (free format text)
                TargetIdentifier  = $adGroupSID # optional (free format text)
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log
        }catch{
            $adGroupSID = $([string]$adGroup.SID)
            $Log = @{
                Action            = "GrantMembership" # optional. ENUM (undefined = default) 
                System            = "ActiveDirectory" # optional (free format text) 
                Message           = "Failed to add AD user $adUserDisplayName ($adUserSID) to group $adGroupDisplayName ($adGroupSID). Error: $($_.Exception.Message)" # required (free format text) 
                IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $groupName # optional (free format text)
                TargetIdentifier  = $adGroupSID # optional (free format text)
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log

            Write-Error "Could not add AD user $adUserDisplayName ($adUserSID) to group $adGroupDisplayName ($adGroupSID). Error: $($_.Exception.Message)"            
        }
    }
}

if($usersToRemove -ne $null){
    foreach($userToRemove in $usersToRemove){
        try{
            $adUser = Get-ADuser $userToRemove.sAMAccountName
            
            $adUserDisplayName = $adUser.DisplayName
            $adUserSID = $([string]$adUser.SID)

            $adGroupDisplayName = $adGroup.DisplayName
            $adGroupSID = $([string]$adGroup.SID)

            $addMember = Remove-ADGroupMember -Identity $adGroup -Members $adUser.sAMAccountName -Confirm:$false
            Write-Information "Successfully removed AD user $adUserDisplayName ($adUserSID) from group $adGroupDisplayName ($adGroupSID)"

            $Log = @{
                Action            = "RevokeMembership" # optional. ENUM (undefined = default) 
                System            = "ActiveDirectory" # optional (free format text) 
                Message           = "Successfully removed AD user $adUserDisplayName ($adUserSID) from group $adGroupDisplayName ($adGroupSID)" # required (free format text) 
                IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $groupName # optional (free format text)
                TargetIdentifier  = $adGroupSID # optional (free format text)
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log
        }catch{
            $adGroupSID = $([string]$adGroup.SID)
            $Log = @{
                Action            = "RevokeMembership" # optional. ENUM (undefined = default) 
                System            = "ActiveDirectory" # optional (free format text) 
                Message           = "Failed to remove AD user $adUserDisplayName ($adUserSID) from group $adGroupDisplayName ($adGroupSID). Error: $($_.Exception.Message)" # required (free format text) 
                IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $groupName # optional (free format text)
                TargetIdentifier  = $adGroupSID # optional (free format text)
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log

            Write-Error "Could not add AD user $adUserDisplayName ($adUserSID) from group $adGroupDisplayName ($adGroupSID). Error: $($_.Exception.Message)"
        }
    }
}
