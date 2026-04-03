$files = @(
    'c:\Users\LHT\Desktop\gitwms\docs\半低代码平台PRD-V1.0.md',
    'c:\Users\LHT\Desktop\gitwms\docs\WmsSearchBar组件分析.md',
    'c:\Users\LHT\Desktop\gitwms\docs\项目状态.md',
    'c:\Users\LHT\Desktop\gitwms\docs\tasks\BE-任务清单.md',
    'c:\Users\LHT\Desktop\gitwms\docs\tasks\FE-任务清单.md',
    'c:\Users\LHT\Desktop\gitwms\docs\tasks\PM-任务清单.md',
    'c:\Users\LHT\Desktop\gitwms\docs\tasks\QA-任务清单.md'
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Write-Host ('=== ' + (Split-Path $f -Leaf) + ' ===')
        $content = Get-Content $f -Raw -Encoding UTF8
        $lines = $content -split "`n"
        Write-Host $lines[0]
        Write-Host ''
    } else {
        Write-Host ('=== MISSING: ' + $f + ' ===')
    }
}
