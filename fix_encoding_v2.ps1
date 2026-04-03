# 修复：GBK内容被错误地写入为"UTF-8 BOM"文件
# 实际内容是GBK编码，需要正确读取后重写为真正的UTF-8

$gbk = [System.Text.Encoding]::GetEncoding("GB2312")
$utf8 = [System.Text.Encoding]::UTF8

$files = Get-ChildItem "c:\Users\LHT\Desktop\gitwms\docs" -Recurse -Filter *.md
$fixed = 0
$failed = @()

foreach ($f in $files) {
    try {
        # 1. 用GBK读取原始字节（文件内容其实是GBK）
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        
        # 2. 跳过UTF-8 BOM (EF BB BF)，用GBK解码剩余内容
        $hasBom = $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
        if ($hasBom) {
            $contentBytes = $bytes[3..($bytes.Length - 1)]
        } else {
            $contentBytes = $bytes
        }
        
        # 3. GBK解码
        $content = $gbk.GetString($contentBytes)
        
        # 4. 验证内容是否包含中文字符（排除掉BOM本身被误读的情况）
        if ($content -match "[\u4e00-\u9fa5]") {
            # 5. 用纯UTF-8（无BOM）写入
            [System.IO.File]::WriteAllText($f.FullName, $content, $utf8)
            Write-Host ("OK: {0}" -f $f.Name)
            $fixed++
        } else {
            Write-Host ("SKIP: {0} (no Chinese found)" -f $f.Name)
        }
    } catch {
        Write-Host ("FAIL: {0} - {1}" -f $f.Name, $_.Exception.Message)
        $failed += $f.Name
    }
}

Write-Host ("`nDone: Fixed={0}, Failed={1}" -f $fixed, $failed.Count)
