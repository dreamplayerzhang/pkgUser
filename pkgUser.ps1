[cmdletbinding()]
param([string]$targetBinary,[string]$binaryLibrarys,[string]$tlogFile, [string]$copiedFilesLog)

$binaryLocations = $binaryLibrarys.Split(";")

$g_searched = @{}

if ($copiedFilesLog)
{
    Set-Content -Path $copiedFilesLog -Value "" -Encoding Ascii
}

function findBinaryLocation([string]$target) {
    return $binaryLocations | Where-Object { Test-Path "$_\$target" } | Select-Object -First 1
}

function deployBinary([string]$targetLocation,[string]$binaryLocation,[string]$target) {
   if(Test-Path "$targetLocation\$target"){
       Write-Verbose " ${target}:already present"
   } 
   else {
       Write-Verbose " ${target}:Copying $binaryLocation\$target"
       Copy-Item "$binaryLocation\$target" $targetLocation
   }

    if ($copiedFilesLog) { Add-Content $copiedFilesLog "$targetLocation\$target" }
    if ($tlogFile) { Add-Content $tlogFile "$targetLocation\$target" }   
}

function resolveBinary ([string]$targetBinary) {
    Write-Verbose "Resolving $targetBinary..."
    try 
    {
        $targetBinaryPath = Resolve-Path $targetBinary -erroraction stop 
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        return
    }

    $targetBinaryLocation = Split-Path $targetBinaryPath -Parent

    $binarys =  $(dumpbin /DEPENDENTS $targetBinary |Where-Object { $_ -match "^    [^ ].*\.dll"} | ForEach-Object{$_ -replace "^    ",""})
    $binarys | ForEach-Object {
        if([string]::IsNullOrEmpty($_)){
            return
        }
        if($g_searched.ContainsKey($_)){
            Write-Verbose " ${_}:previously searched - Skip"
            return 
        }
        $g_searched.Set_Item($_,$true)

        $location = findBinaryLocation($_)
        if($location){
            deployBinary $targetBinaryLocation $location "$_"
            resolveBinary "$targetBinaryLocation\$_"
        }
        else {
            Write-Verbose " ${_}: ${_} not found"
        }
    }
    Write-Verbose "Done Resolving $targetBinary"
}

resolveBinary($targetBinary)
Write-Verbose $($g_searched | Out-String)


