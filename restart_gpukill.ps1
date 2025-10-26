# restart_gpukill.ps1
Write-Host "GPUKill �Զ������ű�������..."
Write-Host "��ÿ�� 1 ������һ�� gpukill server��"
Write-Host "�� Ctrl+C ֹͣ�˽ű���"
Write-Host "--------------------------------------------"

while ($true) {
    Write-Host "[$(Get-Date -Format 'T')] �������� gpukill server..."
    
    # ���� gpukill ����
    $proc = Start-Process gpukill -ArgumentList "--server --server-port 9998" -PassThru -NoNewWindow
    
    # --- �÷��������� 1 ���� ---
    Start-Sleep -Seconds 1
    
    # �������Ƿ��� (�п������Լ�����ʧ����)
    if ($proc -and !$proc.HasExited) {
        Write-Host "[$(Get-Date -Format 'T')] ����ֹͣ gpukill (PID: $($proc.Id))..."
        
        # ǿ��ֹͣ����
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "[$(Get-Date -Format 'T')] gpukill �����ƺ��������˳�������ʧ�ܡ�"
    }
    
    # �ؼ����ȴ� 1 �룬ȷ�� 9998 �˿ڱ���ȫ�ͷ�
    # ���û����һ������һ��ѭ���� 100% ʧ�� (�˿�ռ��)
    Write-Host "[$(Get-Date -Format 'T')] �ȴ��˿��ͷ�..."
    Start-Sleep -Seconds 1
}