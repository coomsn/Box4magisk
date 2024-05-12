#!/system/bin/sh
clear
cd ${0%/*}
normal=$(printf '\033[0m'); green=$(printf '\033[0;32m'); red=$(printf '\033[91m'); yellow=$(printf '\033[33m')
# Turn off proxy services
touch /data/adb/modules/box-module/disable && echo "${red}代理服务已关闭!!!${normal}"
# Select profile
while true; do
    echo "请选择配置文件："
    select file in $(find ./config_files -maxdepth 1 -type f ! -name "output.json" -exec basename {} \;)
    do
        if [ -n "${file}" ]; then
            echo "${green}您选择的配置文件是: ${file}${normal}"
            break 2
        else
            echo "${red}输入无效，请重新选择${normal}"
        fi
    done
done
# Select binary file
while true; do
echo "请选择内核文件："
select bin in $(find ./binary_files -maxdepth 1 -type f ! -name "output.json" -exec basename {} \;)
    do
        if [ -n "${bin}" ]; then
            echo "${green}您选择的内核文件是: ${bin}${normal}"
            break 2
        else
            echo "${red}输入无效，请重新选择${normal}"
        fi
    done
done
# Choose proxy method
while true; do
echo "请选择代理方式："
select mode in "tproxy" "tun" "mixed"
    do
        if [ -n "${mode}" ]; then
            echo "${green}您选择的代理方式是: ${mode}${normal}"
            break 2
        else
            echo "${red}输入无效，请重新选择${normal}"
        fi
    done
done
# substitution variable
sed -i 's/\(config_file=\).*/\1\"..\/config_files\/'"${file}"'\"/' ./scripts/box.scripts
sed -i 's/\(kernel=\)".*"/\1\"'"${bin}"'\"/' ./scripts/box.scripts
sed -i 's/\(mode=\).*/\1\"'"${mode}"'\"/' ./scripts/box.scripts
# Start proxy service
rm /data/adb/modules/box-module/disable
# Prompt information
text=$(echo "${yellow}即将使用${bin}启动${file}配置文件，当前代理模式为${mode}。man,enjoy it.${normal}")
for i in $(seq 0 $((${#text}-1))); do
    echo -n "${text:$i:1}"
    sleep 0.01  # 调整延迟以控制打印速度
done
for i in $(seq 3); do
    printf "..."
    sleep 1  # 每次循环1秒
    if [ $i -eq 3 ]; then
        printf "\n"
    fi
done
echo "${green}\n代理服务启动完毕。${normal}"
