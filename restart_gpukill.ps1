# restart_gpukill.ps1
Write-Host "GPUKill 自动重启脚本已启动..."
Write-Host "将每隔 1 秒重启一次 gpukill server。"
Write-Host "按 Ctrl+C 停止此脚本。"
Write-Host "--------------------------------------------"

while ($true) {
    Write-Host "[$(Get-Date -Format 'T')] 正在启动 gpukill server..."
    
    # 启动 gpukill 进程
    $proc = Start-Process gpukill -ArgumentList "--server --server-port 9998" -PassThru -NoNewWindow
    
    # --- 让服务器运行 1 秒钟 ---
    Start-Sleep -Seconds 1
    
    # 检查进程是否还在 (有可能它自己启动失败了)
    if ($proc -and !$proc.HasExited) {
        Write-Host "[$(Get-Date -Format 'T')] 正在停止 gpukill (PID: $($proc.Id))..."
        
        # 强制停止进程
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "[$(Get-Date -Format 'T')] gpukill 进程似乎已自行退出或启动失败。"
    }
    
    # 关键：等待 1 秒，确保 9998 端口被完全释放
    # 如果没有这一步，下一次循环会 100% 失败 (端口占用)
    Write-Host "[$(Get-Date -Format 'T')] 等待端口释放..."
    Start-Sleep -Seconds 1
}