$files = Get-ChildItem "c:\Users\LHT\Desktop\gitwms\docs" -Recurse -Filter *.md
foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $enc = if ($bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
        "UTF8-BOM"
    } elseif ($bytes[0] -eq 255 -and $bytes[1] -eq 254) {
        "UTF16-LE"
    } else {
        "Other/None"
    }
    Write-Host ("{0}: {1}" -f $f.Name, $enc)
}
