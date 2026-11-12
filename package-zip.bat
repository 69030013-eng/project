@echo off
title Package SIET App for Cloudflare Pages
echo ========================================================
echo   Packaging SIET App for Cloudflare Pages Deployment
echo ========================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path 'index.html', 'css', 'js', 'icons', 'manifest.json', 'sw.js', 'functions', 'schema.sql', 'wrangler.toml' -DestinationPath 'siet-canteen-deploy.zip' -Force"
echo.
echo [SUCCESS] Created package: siet-canteen-deploy.zip
echo You can directly upload this ZIP file to Cloudflare Pages Dashboard!
pause
