function Get-ExEmailAddressPolicy {
    Get-EmailAddressPolicy | Select-Object @(
        'Priority'
        'Name'
        @{
            Name       = 'EnabledEmailAddressTemplates'
            Expression = { @($_.EnabledEmailAddressTemplates) -ne '' -join '|' }
        }
        'EnabledPrimarySMTPAddressTemplate'
        'RecipientFilter'
        'LdapRecipientFilter'
        'IncludedRecipients'
        'WhenCreated'
        'WhenChanged'
        @{
            Name       = 'ConditionalCustomAttribute1'
            Expression = { @($_.ConditionalCustomAttribute1) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute2'
            Expression = { @($_.ConditionalCustomAttribute2) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute3'
            Expression = { @($_.ConditionalCustomAttribute3) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute4'
            Expression = { @($_.ConditionalCustomAttribute4) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute5'
            Expression = { @($_.ConditionalCustomAttribute5) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute6'
            Expression = { @($_.ConditionalCustomAttribute6) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute7'
            Expression = { @($_.ConditionalCustomAttribute7) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute8'
            Expression = { @($_.ConditionalCustomAttribute8) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute9'
            Expression = { @($_.ConditionalCustomAttribute9) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute10'
            Expression = { @($_.ConditionalCustomAttribute10) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute11'
            Expression = { @($_.ConditionalCustomAttribute11) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute12'
            Expression = { @($_.ConditionalCustomAttribute12) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute13'
            Expression = { @($_.ConditionalCustomAttribute13) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute14'
            Expression = { @($_.ConditionalCustomAttribute14) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCustomAttribute15'
            Expression = { @($_.ConditionalCustomAttribute15) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalCompany'
            Expression = { @($_.ConditionalCompany) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalDepartment'
            Expression = { @($_.ConditionalDepartment) -ne '' -join '|' }
        }
        @{
            Name       = 'ConditionalStateOrProvince'
            Expression = { @($_.ConditionalStateOrProvince) -ne '' -join '|' }
        }
        'HasMailboxManagerSetting'
        'RecipientFilterType'
        'Guid'
    )
}
