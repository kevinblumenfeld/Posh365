Function Invoke-LoadMethod {
    param(
        [Parameter(Mandatory)]
        [Microsoft.SharePoint.Client.ClientObject]$Object,
        [Parameter(Mandatory)]
        [string]$PropertyName
    ) 
    $ctx = $Object.Context
    $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
    $type = $Object.GetType()
    $clientLoad = $load.MakeGenericMethod($type) 

    $Parameter = [System.Linq.Expressions.Expression]::Parameter(($type), $type.Name)
    $Expression = [System.Linq.Expressions.Expression]::Lambda(
        [System.Linq.Expressions.Expression]::Convert(
            [System.Linq.Expressions.Expression]::PropertyOrField($Parameter, $PropertyName),
            [System.Object]
        ),
        $($Parameter)
    )
    $ExpressionArray = [System.Array]::CreateInstance($Expression.GetType(), 1)
    $ExpressionArray.SetValue($Expression, 0)
    $clientLoad.Invoke($ctx, @($Object, $ExpressionArray))
}