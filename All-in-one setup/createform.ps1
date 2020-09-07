#HelloID variables
$PortalBaseUrl = "https://CUSTOMER.helloid.com"
$apiKey = "API_KEY"
$apiSecret = "API_SECRET"
$delegatedFormAccessGroupName = "Users"
 
# Create authorization headers with HelloID API key
$pair = "$apiKey" + ":" + "$apiSecret"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$key = "Basic $base64"
$headers = @{"authorization" = $Key}
# Define specific endpoint URI
if($PortalBaseUrl.EndsWith("/") -eq $false){
    $PortalBaseUrl = $PortalBaseUrl + "/"
}
 
 
 
$variableName = "ADusersSearchOU"
$variableGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automation/variables/named/$variableName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationVariableGuid)) {
        #Create Variable
        $body = @{
            name = "$variableName";
            value = '[{ "OU": "OU=Employees,OU=Users,OU=Enyoi,DC=enyoi-media,DC=local"},{ "OU": "OU=Disabled,OU=Users,OU=Enyoi,DC=enyoi-media,DC=local"},{"OU": "OU=External,OU=Users,OU=Enyoi,DC=enyoi-media,DC=local"}]';
            secret = "false";
            ItemType = 0;
        }
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automation/variable")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $variableGuid = $response.automationVariableGuid
    } else {
        $variableGuid = $response.automationVariableGuid
    }
  
    $variableGuid
} catch {
    $_
}
  
  
  
$variableName = "ADgroupsSearchOU"
$variableGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automation/variables/named/$variableName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationVariableGuid)) {
        #Create Variable
        $body = @{
            name = "$variableName";
            value = '[{ "OU": "OU=Groups,OU=Enyoi,DC=enyoi-media,DC=local"}]';
            secret = "false";
            ItemType = 0;
        }
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automation/variable")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $variableGuid = $response.automationVariableGuid
    } else {
        $variableGuid = $response.automationVariableGuid
    }
  
    $variableGuid
} catch {
    $_
}
  
  
  
  
$taskName = "AD-group-generate-table-wildcard"
$taskGetADGroupsGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskName&container=1")
    $response = (Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false) | Where-Object -filter {$_.name -eq $taskName}
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskName";
            useTemplate = "false";
            powerShellScript = @'
try {
    $searchValue = $formInput.searchValue
    $searchQuery = "*$searchValue*"
     
     
    if([String]::IsNullOrEmpty($searchValue) -eq $true){
        Hid-Add-TaskResult -ResultValue []
    }else{
        Hid-Write-Status -Message "SearchQuery: $searchQuery" -Event Information
        HID-Write-Summary -Message "Searching for: $searchQuery" -Event Information
        Hid-Write-Status -Message "SearchBase: $searchOUs" -Event Information
         
        $ous = $searchOUs | ConvertFrom-Json
     
        $groups = foreach($item in $ous) {
             Get-ADGroup -Filter {Name -like $searchQuery} -SearchBase $item.ou -properties *
        }
         
        $groups = $groups | Sort-Object -Property Name
        $resultCount = @($groups).Count
        Hid-Write-Status -Message "Result count: $resultCount" -Event Information
        HID-Write-Summary -Message "Result count: $resultCount" -Event Information
         
        if(@($groups).Count -gt 0){
            foreach($group in $groups)
            {
                $returnObject = @{name=$group.name; description=$group.description;}
                Hid-Add-TaskResult -ResultValue $returnObject
            }
        }else{
            Hid-Add-TaskResult -ResultValue []
        }
    }
} catch {
    HID-Write-Status -Message "Error searching AD user [$searchValue]. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Error searching AD user [$searchValue]" -Event Failed
     
    Hid-Add-TaskResult -ResultValue []
}
'@;
            automationContainer = "1";
            variables = @(@{name = "searchOUs"; value = "{{variable.ADgroupsSearchOU}}"; typeConstraint = "string"; secret = "False"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskGetADGroupsGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskGetADGroupsGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskGetADGroupsGuid
  
  
  
$dataSourceName = "AD-group-generate-table-wildcard"
$dataSourceGetADGroupsGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/datasource/named/$dataSourceName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.dataSourceGUID)) {
        #Create DataSource
        $body = @{
            name = "$dataSourceName";
            type = "3";
            model = @(@{key = "description"; type = 0}, @{key = "name"; type = 0});
            automationTaskGUID = "$taskGetADGroupsGuid";
            input = @(@{description = ""; translateDescription = "False"; inputFieldType = "1"; key = "searchValue"; type = "0"; options = "1"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/datasource")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
          
        $dataSourceGetADGroupsGuid = $response.dataSourceGUID
    } else {
        #Get DatasourceGUID
        $dataSourceGetADGroupsGuid = $response.dataSourceGUID
    }
} catch {
    $_
}
  
$dataSourceGetADGroupsGuid
  
 
 
$taskName = "AD-user-generate-table-user-samaccountname"
$taskGetUsersGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskName&container=1")
    $response = (Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false) | Where-Object -filter {$_.name -eq $taskName}
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskName";
            useTemplate = "false";
            powerShellScript = @'
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
'@;
            automationContainer = "1";
            variables = @(@{name = "searchOUs"; value = "{{variable.ADusersSearchOU}}"; typeConstraint = "string"; secret = "False"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskGetUsersGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskGetUsersGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskGetUsersGuid
  
  
  
$dataSourceName = "AD-user-generate-table-samaccountname"
$dataSourceGetUsersGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/datasource/named/$dataSourceName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.dataSourceGUID)) {
        #Create DataSource
        $body = @{
            name = "$dataSourceName";
            type = "3";
            model = @(@{key = "name"; type = 0}, @{key = "sAMAccountName"; type = 0});
            automationTaskGUID = "$taskGetUsersGuid";
            input = @()
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/datasource")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
          
        $dataSourceGetUsersGuid = $response.dataSourceGUID
    } else {
        #Get DatasourceGUID
        $dataSourceGetUsersGuid = $response.dataSourceGUID
    }
} catch {}
$dataSourceGetUsersGuid
 
 
  
$taskName = "AD-group-generate-table-members"
$taskGetADGroupMembershipsGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskName&container=1")
    $response = (Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false) | Where-Object -filter {$_.name -eq $taskName}
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskName";
            useTemplate = "false";
            powerShellScript = @'
try {
    $groupName = $formInput.selectedGroup.name
      
    HID-Write-Status -Message "Searching AD group [$groupName]" -Event Information
      
    if([String]::IsNullOrEmpty($groupName) -eq $true){
        Hid-Add-TaskResult -ResultValue []
    } else {
        $adGroup = Get-ADgroup -Filter {Name -eq $groupName}
        HID-Write-Status -Message "Finished searching AD group [$groupName]" -Event Information
          
        $users = Get-ADGroupMember $adGroup | Where objectClass -eq "user"
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
'@;
            automationContainer = "1";
            variables = @()
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskGetADGroupMembershipsGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskGetADGroupMembershipsGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskGetADGroupMembershipsGuid
  
  
  
$dataSourceName = "AD-group-generate-table-members"
$dataSourceGetADGroupMembershipsGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/datasource/named/$dataSourceName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.dataSourceGUID)) {
        #Create DataSource
        $body = @{
            name = "$dataSourceName";
            type = "3";
            model = @(@{key = "name"; type = 0}, @{key = "sAMAccountName"; type = 0});
            automationTaskGUID = "$taskGetADGroupMembershipsGuid";
            input = @(@{description = ""; translateDescription = "False"; inputFieldType = "1"; key = "selectedGroup"; type = "0"; options = "1"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/datasource")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
          
        $dataSourceGetADGroupMembershipsGuid = $response.dataSourceGUID
    } else {
        #Get DatasourceGUID
        $dataSourceGetADGroupMembershipsGuid = $response.dataSourceGUID
    }
} catch {
    $_
}
  
$dataSourceGetADGroupMembershipsGuid
  
  
  
  
$formName = "AD Group - Manage memberships"
$formGuid = ""
  
try
{
    try {
        $uri = ($PortalBaseUrl +"api/v1/forms/$formName")
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    } catch {
        $response = $null
    }
  
    if(([string]::IsNullOrEmpty($response.dynamicFormGUID)) -or ($response.isUpdated -eq $true))
    {
        #Create Dynamic form
        $form = @"
[
  {
    "label": "Select group",
    "fields": [
      {
        "key": "searchfield",
        "templateOptions": {
          "label": "Search",
          "placeholder": ""
        },
        "type": "input",
        "summaryVisibility": "Hide element",
        "requiresTemplateOptions": true
      },
      {
        "key": "gridGroups",
        "templateOptions": {
          "label": "Select group",
          "required": true,
          "grid": {
            "columns": [
              {
                "headerName": "Name",
                "field": "name"
              },
              {
                "headerName": "Description",
                "field": "description"
              }
            ],
            "height": 300,
            "rowSelection": "single"
          },
          "dataSourceConfig": {
            "dataSourceGuid": "$dataSourceGetADGroupsGuid",
            "input": {
              "propertyInputs": [
                {
                  "propertyName": "searchValue",
                  "otherFieldValue": {
                    "otherFieldKey": "searchfield"
                  }
                }
              ]
            }
          },
          "useFilter": false
        },
        "type": "grid",
        "summaryVisibility": "Show",
        "requiresTemplateOptions": true
      }
    ]
  },
  {
    "label": "Members",
    "fields": [
      {
        "key": "members",
        "templateOptions": {
          "label": "Manage group memberships",
          "required": false,
          "filterable": true,
          "useDataSource": true,
          "dualList": {
            "options": [
              {
                "guid": "75ea2890-88f8-4851-b202-626123054e14",
                "Name": "Apple"
              },
              {
                "guid": "0607270d-83e2-4574-9894-0b70011b663f",
                "Name": "Pear"
              },
              {
                "guid": "1ef6fe01-3095-4614-a6db-7c8cd416ae3b",
                "Name": "Orange"
              }
            ],
            "optionKeyProperty": "sAMAccountName",
            "optionDisplayProperty": "name",
            "labelLeft": "Available",
            "labelRight": "Member of"
          },
          "dataSourceConfig": {
            "dataSourceGuid": "$dataSourceGetUsersGuid",
            "input": {
              "propertyInputs": []
            }
          },
          "destinationDataSourceConfig": {
            "dataSourceGuid": "$dataSourceGetADGroupMembershipsGuid",
            "input": {
              "propertyInputs": [
                {
                  "propertyName": "selectedGroup",
                  "otherFieldValue": {
                    "otherFieldKey": "gridGroups"
                  }
                }
              ]
            }
          },
          "useFilter": false
        },
        "type": "duallist",
        "summaryVisibility": "Show",
        "requiresTemplateOptions": true
      }
    ]
  }
]
"@
  
        $body = @{
            Name = "$formName";
            FormSchema = $form
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/forms")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
  
        $formGuid = $response.dynamicFormGUID
    } else {
        $formGuid = $response.dynamicFormGUID
    }
} catch {
    $_
}
  
$formGuid
  
  
  
  
$delegatedFormAccessGroupGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/groups/$delegatedFormAccessGroupName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    $delegatedFormAccessGroupGuid = $response.groupGuid
} catch {
    $_
}
  
$delegatedFormAccessGroupGuid
  
  
  
$delegatedFormName = "AD Groep - Manage memberships"
$delegatedFormGuid = ""
  
try {
    try {
        $uri = ($PortalBaseUrl +"api/v1/delegatedforms/$delegatedFormName")
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    } catch {
        $response = $null
    }
  
    if([string]::IsNullOrEmpty($response.delegatedFormGUID)) {
        #Create DelegatedForm
        $body = @{
            name = "$delegatedFormName";
            dynamicFormGUID = "$formGuid";
            isEnabled = "True";
            accessGroups = @("$delegatedFormAccessGroupGuid");
            useFaIcon = "True";
            faIcon = "fa fa-users";
        }  
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/delegatedforms")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
  
        $delegatedFormGuid = $response.delegatedFormGUID
    } else {
        #Get delegatedFormGUID
        $delegatedFormGuid = $response.delegatedFormGUID
    }
} catch {
    $_
}
  
$delegatedFormGuid
  
  
  
  
$taskActionName = "AD-group-update-members"
$taskActionGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskActionName&container=8")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskActionName";
            useTemplate = "false";
            powerShellScript = @'
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
'@;
            automationContainer = "8";
            objectGuid = "$delegatedFormGuid";
            variables = @(@{name = "usersToAdd"; value = "{{form.members.leftToRight.toJsonString}}"; typeConstraint = "string"; secret = "False"},
                        @{name = "usersToRemove"; value = "{{form.members.rightToLeft.toJsonString}}"; typeConstraint = "string"; secret = "False"},
                        @{name = "groupName"; value = "{{form.gridGroups.name}}"; typeConstraint = "string"; secret = "False"});
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskActionGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskActionGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskActionGuid