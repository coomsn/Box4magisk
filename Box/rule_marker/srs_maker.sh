#!/system/bin/sh
clear; cd ${0%/*}

source ../scripts/box.scripts

geo_file() {
# determine whether to download database files
if [ -e "geoip.db" ] && [ -e "geosite.db" ]; then
    echo "两个文件同时存在，不需要下载"
else
    echo "两个文件不同时存在，重新下载"
    curl -o geosite.db https://cdn.jsdelivr.net/gh/soffchen/sing-geosite@release/geosite.db
    curl -o geoip.db https://cdn.jsdelivr.net/gh/soffchen/sing-geoip@release/geoip.db
fi
}

sitename=(category-ads-all google@cn bing@cn microsoft@cn telegram openai geolocation-!cn private geolocation-cn)

ipname=(cn tw hk telegram)

# create configuration file
srs_local() {
for element in "${sitename[@]}"; do
      ${binfile} geosite -c geosite.db export $element
    echo geosite-$element.srs
      ${binfile} rule-set compile -o geosite-$element.srs geosite-$element.json
    find . -maxdepth 1 -name '*.json' \( -not -name 'rule_template_*.json' \) -exec mv {} ./geo_json \;
    mv ./*.srs ./geo_srs
config_content+="{
  \"type\": \"local\",
  \"tag\": \"geosite-$element\",
  \"format\": \"binary\",
  \"path\": \"../rule_files/geosite-$element.srs\"
},"
done
for element in "${ipname[@]}"; do
      ${binfile} geoip -c geoip.db export $element
    echo geoip-$element.srs
      ${binfile} rule-set compile -o geoip-$element.srs geoip-$element.json
    find . -maxdepth 1 -name '*.json' \( -not -name 'rule_template_*.json' \) -exec mv {} ./geo_json \;
    mv ./*.srs ./geo_srs
config_content+="{
  \"type\": \"local\",
  \"tag\": \"geoip-$element\",
  \"format\": \"binary\",
  \"path\": \"../rule_files/geoip-$element.srs\"
},"
done
# file output
config_content=${config_content%,}
echo "[$config_content]" > rule_template_local.json
find ./geo_srs -type f -exec basename {} \; | sed 's/\.[^.]*$//' > rules.list
  ${binfile} geosite -c geosite.db list > geosite.list
  ${binfile} geoip -c geoip.db list > geoip.list
mkdir -p ../rule_files && cp -Rf ./geo_srs/* ../rule_files
}

srs_remote() {
rm -f rules.list
# create configuration file
for element in "${sitename[@]}"; do
    echo geosite-$element.srs | tee -a rules.list
config_content+="{
  \"type\": \"remote\",
  \"tag\": \"geosite-$element\",
  \"path\": \"../rule_files/geosite-$element.srs\",
  \"format\": \"binary\",
  \"url\": \"https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/$element.srs\",
  \"download_detour\": \"out_proxies\",
  \"update_interval\": \"24h\"
},"
done
for element in "${ipname[@]}"; do
    echo geoip-$element.srs | tee -a rules.list
config_content+="{
  \"type\": \"remote\",
  \"tag\": \"geoip-$element\",
  \"path\": \"../rule_files/geoip-$element.srs\",
  \"format\": \"binary\",
  \"url\": \"https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/$element.srs\",
  \"download_detour\": \"out_proxies\",
  \"update_interval\": \"24h\"
},"
done
awk '{gsub(/\.srs/, ""); print}' rules.list > temp.list && mv temp.list rules.list
# file output
config_content=${config_content%,}
echo "[$config_content]" > rule_template_remote.json
  ${binfile} geosite -c geosite.db list > geosite.list
  ${binfile} geoip -c geoip.db list > geoip.list
}

echo "请选择一个选项："
select choice in "srs_local" "srs_remote" "退出"
 do
    case $choice in
        "srs_local")
            mkdir -p geo_srs geo_json
            echo "您选择了 srs_local"
            geo_file
            srs_local
            ;;
        "srs_remote")
            echo "您选择了 srs_remote"
            geo_file
            srs_remote
            ;;
        "退出")
            exit 0
            ;;
        *)
            echo "无效选择，请再次选择。"
            ;;
    esac
 done