# Change Log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com), and this project adheres to [Semantic Versioning](https://semver.org).

## [2.0.1] - 2026-05-28

### Added

- Best practice documentation highlighting the recommended use of HelloID Products for permission management and lifecycle governance

## [2.0.0.0] - 2025-02-05

### Added
- Added comprehensive audit logging for all group membership operations
- Added detailed error handling and logging with line number information
- Added support for GrantMembership and RevokeMembership audit action types
- Added error tracking in audit logs for compliance and troubleshooting
- Added user display formatting with Name and UserPrincipalName for better identification

### Changed
- **BREAKING**: Refactored task script to use ObjectGuid for reliable user and group identification
- Updated task error handling with separate try-catch blocks for add and remove operations
- Improved form task to log all errors to HelloID audit system
- Enhanced error messages with detailed context including user and group information
- Updated README with comprehensive documentation including requirements and remarks
- Improved documentation structure for clarity and consistency
- Updated all-in-one setup script
- Updated manual resources

### Removed
- Removed basic attribute Grid

### Fixed
- Fixed group membership operations to use ObjectGuid instead of relying on other identifiers for reliability

## [1.1.1] - 2022-06-08

### Changed
- Updated with audit logging capabilities to track all changes made to AD group memberships

## [1.1.0] - 2022-03-14

### Changed
- Updated with code for SA agent support

## [1.0.1] - 2021-11-03

### Added
- Added version number to the release

### Changed
- Updated all-in-one setup script

## [1.0.0] - 2020-09-07

### Added
- Initial release of HelloID-Conn-SA-Full-AD-GroupManageMemberships
- AD group membership management functionality
- Search and select target AD group
- Modify AD group memberships
- Process and validate updates (add or remove AD account memberships)
