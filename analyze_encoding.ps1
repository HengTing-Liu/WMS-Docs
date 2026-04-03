# 分析实际字节编码
$files = Get-ChildItem "c:\Users\LHT\Desktop\gitwms\docs" -Recurse -Filter *.md

foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $header = $bytes[0..20] -join ","
    
    # 尝试各种编码
    $encodings = @("UTF-8", "GB2312", "GBK", "Big5", "UTF-16LE", "UTF-16BE")
    $decoded = $null
    
    foreach ($enc in $encodings) {
        try {
            $e = [System.Text.Encoding]::GetEncoding($enc)
            $test = $e.GetString($bytes)
            if ($test -match "[\u4e00-\u9fa5]") {
                $decoded = $enc
                break
            }
        } catch { }
    }
    
    Write-Host ("{0}: {1} | First20: {2}" -f $f.Name, $decoded, $header)
}
