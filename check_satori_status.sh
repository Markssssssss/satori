#!/bin/bash
# 目标服务器IP列表
SERVERS=(
    47.91.88.99
47.91.75.205
47.254.144.174
)
# 失败日志文件
FAILED_LOG="satori_install_failed.log"
# 检查安装状态的函数
check_install_status() {
    local server=$1
    status=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$server "if systemctl is-active --quiet satori.service; then echo '安装成功'; else echo '安装失败或未完成'; fi" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        status="连接失败"
    fi
    
    echo "$server: $status"
    
    # 如果安装失败或连接失败，将 IP 写入日志
    if [[ "$status" != *"安装成功"* ]]; then
        echo "$server" >> $FAILED_LOG
    fi
}
# 主函数
main() {
    echo "检查安装状态:"
    
    # 清空或创建失败日志文件
    > $FAILED_LOG
    
    for server in "${SERVERS[@]}"; do
        check_install_status $server &
    done
    # 等待所有后台任务完成
    wait
    
    echo "检查完成。失败的安装已记录在 $FAILED_LOG 文件中。"
    
    # 显示失败安装的数量
    failed_count=$(wc -l < $FAILED_LOG)
    echo "总共有 $failed_count 个服务器安装失败或无法连接。"
}
# 运行主函数
main
EOF
