# This is a PowerShell script

# Run your command
Write-Host 'Running tests' -ForegroundColor Cyan
$output = & php artisan test | Tee-Object -FilePath output.txt

# Extract the number of passed and skipped tests
$testSummary = $output | Select-String -Pattern 'Tests: +([0-9]+) skipped, ([0-9]+) passed' | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value, $_.Groups[2].Value }
# Extract the number of failed tests
$failSummary = $output | Select-String -Pattern 'Tests: +([0-9]+) fail' | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value }

# Check if the output contains "failed"
if ($output -match "failed" -or $output -match "fail") {
    Write-Host "Test failed" -ForegroundColor Red
    Write-Host "Failed tests: $($failSummary[0])" -ForegroundColor Red
} else {
    Write-Host "Test passed" -ForegroundColor Green
    Write-Host "Passed tests: $($testSummary[1])" -ForegroundColor Green
    Write-Host "Skipped tests: $($testSummary[0])" -ForegroundColor Yellow
}

npm run build
if($LASTEXITCODE -ne 0) {
    Write-Host "NPM Build failed" -ForegroundColor Red
    exit 1
}

Write-Host 'Build & Up latest' -ForegroundColor Cyan
docker compose up -d --build