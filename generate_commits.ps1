$dates = @(
    "2026-01-21",
    "2026-01-26",
    "2026-02-11",
    "2026-02-20",
    "2026-02-23",
    "2026-03-04",
    "2026-03-06",
    "2026-03-12",
    "2026-03-13"
)

$messages = @(
    "Minor UI tweaks",
    "Refactoring utility classes",
    "Cleaning up whitespace",
    "Fixing a minor typo",
    "Updating comments",
    "Formatting code",
    "Optimizing imports",
    "Removing unused variables",
    "Updating minor dependencies",
    "Tuning performance slightly",
    "Fixing a minor bug in edge case",
    "Refactoring component structure"
)

$file = "CHANGELOG.md"
if (-Not (Test-Path $file)) {
    Set-Content -Path $file -Value "# Changelog`n`n## Updates`n"
}

foreach ($d in $dates) {
    for ($i = 0; $i -lt 12; $i++) {
        $msg = $messages[$i]
        $hour = (10 + ($i % 8)).ToString("00")
        $min = (10 + ($i * 4)).ToString("00")
        $sec = (10 + $i).ToString("00")
        $timestamp = "$d`T$hour`:$min`:$sec"
        
        Add-Content -Path $file -Value "- $msg"
        
        git add $file
        $env:GIT_COMMITTER_DATE = $timestamp
        $env:GIT_AUTHOR_DATE = $timestamp
        git commit --date=$timestamp -m $msg | Out-Null
        Write-Host "Created commit for $timestamp"
    }
}
