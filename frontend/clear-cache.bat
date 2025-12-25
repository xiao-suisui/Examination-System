@echo off
chcp 65001 >nul
echo ====================================
echo 清除前端缓存
echo ====================================
echo.

echo [1/3] 删除 Vite 缓存...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo ✓ Vite 缓存已删除
) else (
    echo ✓ Vite 缓存不存在
)

echo.
echo [2/3] 删除 dist 目录...
if exist "dist" (
    rmdir /s /q "dist"
    echo ✓ dist 目录已删除
) else (
    echo ✓ dist 目录不存在
)

echo.
echo [3/3] 提示清除浏览器缓存...
echo.
echo 请在浏览器中执行以下操作：
echo 1. 打开开发者工具（F12）
echo 2. 在控制台中执行：
echo    localStorage.clear()
echo    sessionStorage.clear()
echo 3. 强制刷新页面（Ctrl + F5）
echo.

echo ====================================
echo 缓存清除完成！
echo ====================================
echo.
echo 现在可以重新启动开发服务器：
echo   npm run dev
echo.
pause

