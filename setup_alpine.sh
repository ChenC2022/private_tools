#!/bin/sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}错误：此脚本必须以root用户运行！${NC}" >&2
        exit 1
    fi
}

# 修改软件源
change_repo() {
    echo -e "${YELLOW}正在替换软件源为USTC镜像...${NC}"
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
    echo -e "${GREEN}软件源已更新为：${NC}"
    cat /etc/apk/repositories
    echo ""
}

# 更新系统
update_system() {
    echo -e "${YELLOW}正在更新系统...${NC}"
    apk update && apk upgrade
    echo -e "${GREEN}系统更新完成！${NC}"
}

# 安装基础工具
install_tools() {
    echo -e "${YELLOW}正在安装nano和openssh...${NC}"
    apk add nano openssh
    echo -e "${GREEN}工具安装完成！${NC}"
}

# 配置SSH
config_ssh() {
    echo -e "${YELLOW}正在配置SSH...${NC}"
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    rc-update add sshd
    rc-service sshd start
    echo -e "${GREEN}SSH已配置并启动！${NC}"
    echo -e "${YELLOW}注意：已允许root密码登录，请确保设置强密码！${NC}"
}

# 安装Docker
install_docker() {
    echo -e "${YELLOW}正在安装Docker...${NC}"
    apk add docker docker-compose
    rc-update add docker default
    service docker start
    rc-update add cgroups
    echo -e "${GREEN}Docker已安装并启动！${NC}"
    echo -e "Docker版本：$(docker --version)"
    echo -e "Docker Compose版本：$(docker-compose --version)"
}

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN} Alpine Linux 一键配置脚本 ${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "1. 更换USTC软件源镜像"
    echo -e "2. 更新系统"
    echo -e "3. 安装基础工具 (nano+openssh)"
    echo -e "4. 配置SSH服务 (允许root登录)"
    echo -e "5. 安装Docker和Docker Compose"
    echo -e "6. 一键执行全部操作"
    echo -e "0. 退出脚本"
    echo -e "${GREEN}================================${NC}"
    read -p "请输入选项 [0-6]: " option
    case $option in
        1) change_repo; pause ;;
        2) update_system; pause ;;
        3) install_tools; pause ;;
        4) config_ssh; pause ;;
        5) install_docker; pause ;;
        6) 
            change_repo
            update_system
            install_tools
            config_ssh
            install_docker
            pause 
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入！${NC}"; sleep 1; show_menu ;;
    esac
}

# 按任意键继续
pause() {
    echo ""
    read -n 1 -s -r -p "按任意键继续..."
    show_menu
}

# 主函数
main() {
    check_root
    show_menu
}

main
