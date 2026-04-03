# 修复所有md文件编码：GBK -> UTF-8
Add-Type -AssemblyName System.Web

$files = Get-ChildItem "c:\Users\LHT\Desktop\gitwms\docs" -Recurse -Filter *.md
$fixed = 0
$failed = @()

foreach ($f in $files) {
    try {
        # 使用GBK编码读取
        $gbk = [System.Text.Encoding]::GetEncoding("GB2312")
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        $content = $gbk.GetString($bytes)
        
        # 用UTF-8无BOM写入
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host ("OK: {0}" -f $f.Name)
        $fixed++
    } catch {
        Write-Host ("FAIL: {0} - {1}" -f $f.Name, $_.Exception.Message)
        $failed += $f.Name
    }
}

Write-Host ("`nDone: Fixed={0}, Failed={1}" -f $fixed, $failed.Count)
if ($failed.Count -gt 0) {
    Write-Host "Failed files:"
    $failed | ForEach-Object { Write-Host "  - $_" }
}
