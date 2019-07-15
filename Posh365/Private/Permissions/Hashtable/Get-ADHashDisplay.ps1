function Get-ADHashDisplay {
    param (

    )
    end {
        $Display = @{
            '0'           = 'MailboxUser'
            '1'           = 'DistributionGroup'
            '2'           = 'PublicFolder'
            '3'           = 'DynamicDistributionGroup'
            '4'           = 'Organization'
            '5'           = 'PrivateDistributionList'
            '6'           = 'RemoteMailUser'
            '7'           = 'ConferenceRoomMailbox'
            '8'           = 'EquipmentMailbox'
            '10'          = 'ArbitrationMailbox'
            '11'          = 'MailboxPlan'
            '12'          = 'LinkedUser'
            '15'          = 'RoomList'
            '1073741833'  = 'SecurityDistributionGroup'
            '1073741824'  = 'ACLableMailboxUser'
            '1073741830'  = 'ACLableRemoteMailUser'
            '-2147481343' = 'SyncedUSGasUDG'
            '-1073739511' = 'SyncedUSGasUSG'
            '-2147481338' = 'SyncedUSGasContact'
            '-1073739514' = 'ACLableSyncedUSGasContact'
            '-2147482874' = 'SyncedDynamicDistributionGroup'
            '-1073741818' = 'ACLableSyncedMailboxUser'
            '-2147483642' = 'SyncedMailboxUser'
            '-2147481850' = 'SyncedConferenceRoomMailbox'
            '-2147481594' = 'SyncedEquipmentMailbox'
            '-2147482106' = 'SyncedRemoteMailUser'
            '-1073740282' = 'ACLableSyncedRemoteMailUser'
            '-2147483130' = 'SyncedPublicFolder'

        }
        $Display
    }
}
