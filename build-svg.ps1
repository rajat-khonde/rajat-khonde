
# Load quotes and tips from JSON
$dataPath = Join-Path $PSScriptRoot "Quotes_Tips.json"
if (-not (Test-Path $dataPath)) {
    Write-Error "Data file not found: $dataPath"
    exit 1
}

$data = Get-Content -Raw $dataPath | ConvertFrom-Json
$quotes = $data.quotes
$techTips = $data.techTips

# Pick random quote and tip
$todayQuote = $quotes | Get-Random
$todayTip = $techTips | Get-Random

# Function to wrap text into multiple lines
function WrapText {
    param([string]$text, [int]$maxWidth = 55)
    $words = $text -split ' '
    $lines = @()
    $line = ''
    
    foreach ($word in $words) {
        if (($line + ' ' + $word).Length -gt $maxWidth -and $line) {
            $lines += $line
            $line = $word
        } else {
            $line = if ($line) { $line + ' ' + $word } else { $word }
        }
    }
    if ($line) { $lines += $line }
    return @($lines)  # Return as array to avoid unrolling single items
}

# Wrap quote and tip text - force to array
$quoteLines = @(WrapText -text $todayQuote -maxWidth 75)
$tipLines = @(WrapText -text $todayTip -maxWidth 65)

# Build quote with tspan elements - first line with quotes, rest without
$quoteLine0 = $quoteLines[0] -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
$quoteText =  $quoteLine0 
if ($quoteLines.Count -gt 1) {
    for ($i = 1; $i -lt $quoteLines.Count; $i++) {
        $escapedLine = $quoteLines[$i] -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
        $quoteText += '<tspan x="60" dy="1.3em">' + $escapedLine + '</tspan>'
    }
}

# Build tip with tspan elements
$tipText = $tipLines[0]
if ($tipLines.Count -gt 1) {
    for ($i = 1; $i -lt $tipLines.Count; $i++) {
        $escapedLine = $tipLines[$i] -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
        $tipText = $tipText + '<tspan x="60" dy="1.3em">' + $escapedLine + '</tspan>'
    }
}

# Get current date info
$currentDate = Get-Date -Format "MMMM dd, yyyy"
$dayOfWeek = (Get-Date).DayOfWeek

# Load and process SVG template
$templatePath = Join-Path $PSScriptRoot "template.svg"
if (-not (Test-Path $templatePath)) {
    Write-Error "Template file not found: $templatePath"
    exit 1
}

$svgContent = Get-Content -Raw $templatePath

# Replace placeholders in template
$svgContent = $svgContent.Replace("{QUOTE}", $quoteText)
$svgContent = $svgContent.Replace("{TECH_TIP}", $tipText)
$svgContent = $svgContent.Replace("{CURRENT_DATE}", $currentDate)
$svgContent = $svgContent.Replace("{DAY_OF_WEEK}", $dayOfWeek)

# Save the SVG
$outputPath = Join-Path $PSScriptRoot "motivational-quotes.svg"
Set-Content -Path $outputPath -Value $svgContent -Encoding UTF8

# Show results
Write-Host "✅ SVG generated at: $outputPath"
Write-Host "📖 Quote: $todayQuote"
Write-Host "💡 Tip: $todayTip"