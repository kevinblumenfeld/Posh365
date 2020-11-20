function Format-Vertical {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [object[]] $Policy
    )

    begin {
        $objects = [System.Collections.Generic.List[Object]]::new()
    }

    process {
        $objects.AddRange($Policy)
    }

    end {
        $propertyNames = $objects[0].PSObject.Properties.Name

        foreach ($name in $propertyNames) {
            $line = [Ordered]@{
                Property = $name
            }

            foreach ($object in $objects) {
                $line[$object.DisplayName] = $object.$name
            }

            [PSCustomObject]$line
        }
    }
}