
# Load quotes and tips from JSON
$dataPath = Join-Path $PSScriptRoot "Quotes_Tips.json"
if (-not (Test-Path $dataPath)) {
    Write-Error "Data file not found: $dataPath"
    exit 1
}

$data = Get-Content -Raw $dataPath | ConvertFrom-Json
$quotes = $data.quotes
$techTips = $data.techTips

# Get today's date
$today = Get-Date
$dayOfYear = $today.DayOfYear
$currentDate = Get-Date -Format "MMMM dd, yyyy"
$dayOfWeek = (Get-Date).DayOfWeek

# Pick today's quote and tip based on day of year
$quoteIndex = $dayOfYear % $quotes.Count
$tipIndex = $dayOfYear % $techTips.Count
$todayQuote = $quotes[$quoteIndex]
$todayTip = $techTips[$tipIndex]

# Load and process SVG template
$templatePath = Join-Path $PSScriptRoot "template.svg"
if (-not (Test-Path $templatePath)) {
    Write-Error "Template file not found: $templatePath"
    exit 1
}

$svgContent = Get-Content -Raw $templatePath

# Replace placeholders in template
$svgContent = $svgContent -replace "{QUOTE}", $todayQuote
$svgContent = $svgContent -replace "{TECH_TIP}", $todayTip
$svgContent = $svgContent -replace "{CURRENT_DATE}", $currentDate
$svgContent = $svgContent -replace "{DAY_OF_WEEK}", $dayOfWeek

# Save the SVG
$outputPath = Join-Path $PSScriptRoot "motivational-quotes.svg"
Set-Content -Path $outputPath -Value $svgContent -Encoding UTF8

# Show results
Write-Host "✅ SVG generated at: $outputPath"
Write-Host "📖 Quote: $todayQuote"
Write-Host "💡 Tip: $todayTip"
