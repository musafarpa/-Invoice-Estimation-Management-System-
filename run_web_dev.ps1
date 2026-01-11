# Run Flutter web with disabled web security for development
# This allows API calls to work without CORS restrictions
# NOTE: Only use this for development, not production!

Write-Host "Starting Flutter Web in Development Mode (CORS disabled)..." -ForegroundColor Green
Write-Host ""
Write-Host "WARNING: Web security is disabled. Use only for development!" -ForegroundColor Yellow
Write-Host ""

flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--disable-site-isolation-trials" --web-browser-flag "--user-data-dir=C:\temp\chrome_dev_session"
