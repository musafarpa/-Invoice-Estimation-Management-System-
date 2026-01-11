@echo off
REM Run Flutter web with disabled web security for development
REM This allows API calls to work without CORS restrictions
REM NOTE: Only use this for development, not production!

echo Starting Flutter Web in Development Mode (CORS disabled)...
echo.
echo WARNING: Web security is disabled. Use only for development!
echo.

flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--disable-site-isolation-trials" --web-browser-flag "--user-data-dir=C:\temp\chrome_dev_session"
