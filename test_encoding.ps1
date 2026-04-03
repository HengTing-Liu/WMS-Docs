# 尝试不同的中文编码来正确读取文件

$encodings = @(
    @{ Name="GB2312"; Enc=[System.Text.Encoding]::GetEncoding("GB2312") },
    @{ Name="GBK"; Enc=[System.Text.Encoding]::GetEncoding("GBK") },
    @{ Name="GB18030"; Enc=[System.Text.Encoding]::GetEncoding("GB18030") },
    @{ Name="CP936"; Enc=[System.Text.Encoding]::GetEncoding(936) },
    @{ Name="ASCII+GBK"; Enc=[System.Text.Encoding]::GetEncoding("GBK") }
)

$testFile = "c:\Users\LHT\Desktop\gitwms\docs\半低代码平台PRD-V1.0.md"
$bytes = [System.IO.File]::ReadAllBytes($testFile)

Write-Host ("File size: " + $bytes.Length + " bytes")
Write-Host ("First 20 bytes: " + ($bytes[0..19] -join ","))
Write-Host ("")

foreach ($e in $encodings) {
    try {
        $content = $e.Enc.GetString($bytes)
        $firstLine = ($content -split "`n")[0]
        Write-Host ($e.Name + ": " + $firstLine.Substring(0, [Math]::Min(60, $firstLine.Length)))
    } catch {
        Write-Host ($e.Name + ": ERROR - " + $_.Exception.Message)
    }
}
