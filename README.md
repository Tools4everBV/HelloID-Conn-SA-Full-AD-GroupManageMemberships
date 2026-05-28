# HelloID-Conn-SA-Full-AD-GroupManageMemberships

> [!IMPORTANT]
> **Best Practice:** Use **HelloID Products** for requesting and managing permissions (group memberships, mailbox access, application roles). Products provide governance, approval workflows, admin visibility, and full lifecycle management.  
> Use delegated forms for one-time operational actions (creating resources like shared mailboxes, password resets, attribute updates) only.  
>
> **[Read more: Products vs. Delegated Forms](https://docs.helloid.com/en/service-automation/products-vs--delegated-forms.html)**  

| :information_source: Information |
|:---|
| This repository contains the connector and configuration code only. The implementer is responsible for acquiring the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements. |

## Description

_HelloID-Conn-SA-Full-AD-GroupManageMemberships_ is a delegated form designed for use with HelloID Service Automation (SA). It can be imported into HelloID and customized according to your requirements.

By using this delegated form, you can manage Active Directory group memberships. The following options are available:

1. Search for and select the target Active Directory (AD) group by Name or Mail address.
2. View all available AD users (from specified OUs) and the current members of the selected group.
3. Add or remove multiple users to/from the selected group with comprehensive audit logging.

## Getting started

### Requirements

• **Active Directory Access**:
  The connector requires access to an Active Directory domain with sufficient permissions to add and remove group memberships. A service account with appropriate AD permissions is necessary.

• **HelloID Agent**:
  A HelloID Agent must be installed and configured to communicate with the Active Directory domain.

• **PowerShell module 'ActiveDirectory'**:
  The HelloID Agent must have PowerShell available with Active Directory module support.

### Connection settings

The following user-defined variables are used by the connector.

| Setting | Description | Mandatory |
|---------|-------------|-----------|
| ADgroupsSearchOU | Array of Active Directory OUs for scoping AD groups in the search result of this form | Yes |
| ADusersSearchOU | Array of Active Directory OUs for scoping AD user accounts available in this form | Yes |

## Remarks

### Group Search

• **Search Functionality:** Users can search for groups using a wildcard (`*`) to return all groups within the specified OUs, or by entering partial text to search across group Name and Mail attributes.

• **The search scope is limited to the OUs defined in the `ADgroupsSearchOU` variable.**

### User Search

• **Search Functionality:** users are retrieved from the Active Directory OUs specified in the `ADusersSearchOU` variable.

• **Users without a name are filtered out.**

## Development resources

### PowerShell Module
This connector uses the ActiveDirectory PowerShell module for managing Active Directory groups and user accounts.

- [ActiveDirectory Module Documentation](https://learn.microsoft.com/en-us/powershell/module/activedirectory/)

### Cmdlets
The following PowerShell cmdlets are used by the connector:

| Cmdlet | Description |
| --- | --- |
| Get-ADGroup | Retrieves Active Directory groups |
| Get-ADUser | Retrieves Active Directory user accounts |
| Add-ADGroupMember | Adds one or more users to an Active Directory group |
| Remove-ADGroupMember | Removes one or more users from an Active Directory group |

### Cmdlet documentation
- [Get-ADGroup](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adgroup)
- [Get-ADUser](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser)
- [Add-ADGroupMember](https://learn.microsoft.com/en-us/powershell/module/activedirectory/add-adgroupmember)
- [Remove-ADGroupMember](https://learn.microsoft.com/en-us/powershell/module/activedirectory/remove-adgroupmember)


## Getting help

> 💡 **Tip:**
> For more information on Delegated Forms, please refer to our
[documentation](https://docs.helloid.com/en/service-automation/delegated-forms.html) pages.

## HelloID docs
The official HelloID documentation can be found at: [https://docs.helloid.com/](https://docs.helloid.com/)