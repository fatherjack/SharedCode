function Compare-Array {
    param(
        [array]$Ref,
        [array]$Diff
    )

    $max = [math]::Max($Ref.Length, $Diff.Length)

    for ($i = 0; $i -lt $max; $i++) {
        if ($Ref[$i] -ne $Diff[$i]) {
            [pscustomobject]@{ 
                Index = $i
                Left  = $Ref[$i]
                Right = $Diff[$i]
            }
        }
    }
}