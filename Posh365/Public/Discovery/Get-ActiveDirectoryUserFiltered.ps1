function Get-ActiveDirectoryUserFiltered { 
    <#
    .SYNOPSIS
    Get ADUsers filtered by attributes

    .DESCRIPTION
    Get ADUsers filtered by attributes.  Provide the name of attribute(s) and the function will look for a txt file of the same name.
    The txt file will contain the values to be found.

    .PARAMETER JoinType
    AND or OR are the options here.  This decides if the filter is 
    (foo -eq 'bar' -or bar -eq 'foo') -AND (foo -eq 'bar' -or bar -eq 'foo')
                                    or
    (foo -eq 'bar' -or bar -eq 'foo') -OR (foo -eq 'bar' -or bar -eq 'foo')

    The DEFAULT is AND

    .PARAMETER Attributes
    The attributes to be filtered

    .EXAMPLE
    Get-ActiveDirectoryUserFiltered -Attributes @('DepartmentNumber','City')

    .NOTES
    Name of attribute expects same named .txt file.
    In the above example DepartmentNumber.txt and City.txt is expected in c:\scripts
    OUs.txt is expected in same location
#>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType = 'and',

        [Parameter()]
        [String[]]$Attributes

    )

    $InputPath = 'C:\Scripts'

    $filterElements = ForEach ($Attribute in $Attributes) {
        $AttributePath = Join-Path $InputPath ($Attribute + ".txt")
        $List = Get-Content $AttributePath
        $elements = ForEach ($L in $List) {
            $logicOperator = ' -or '
            $comparisonOperator = '-eq'
            '{0} {1} "{2}"' -f $Attribute, $comparisonOperator, $L
        }
        $elements -join $logicOperator
    }

    $filterString = '({0})' -f ($filterElements -join (') -{0} (' -f $JoinType))
    $filter = [ScriptBlock]::Create($filterString)
    Write-Verbose "Filter being used: $filter"
    $OUPath = Join-Path $InputPath OUs.txt
    $OUs = Get-Content $OUPath
    ForEach ($OU in $OUs) {
        $ADSplat = @{
            Properties = $Attributes
            SearchBase = $OU
            Filter     = $filter
        }
        Get-ADUser @ADSplat
    }
}