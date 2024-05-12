#!/system/bin/sh
#####################
# Box Customization
#####################
SKIPUNZIP=1
ASH_STANDALONE=1
unzip_path="/data/adb"

# Define the paths of source folder and the destination folder
source_folder="/data/adb/Box"
destination_folder="/data/adb/Box$(date +%Y%m%d_%H%M%S)"

# Check if the source folder exists
if [ -d "$source_folder" ]; then
    # If the source folder exists, execute the move operation
    mv "$source_folder" "$destination_folder"
    ui_print "- 正在备份已有文件"
    # Delete old folders and update them
    rm -rf "$source_folder"
else
    # If the source folder does not exist, output initial installation information 
    ui_print "- 正在初始安装"
fi

ui_print "- 正在释放新文件"
unzip -o "$ZIPFILE" 'Box/*' -d $unzip_path >&2
unzip -j -o "$ZIPFILE" 'box4magisk_service.sh' -d /data/adb/service.d >&2
unzip -j -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "module.prop" -d $MODPATH >&2
ui_print "- 正在设置权限"
set_perm /data/adb/service.d/box4magisk_service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $unzip_path/Box 0 0 0755 0755
ui_print "- 完成权限设置"
ui_print "- enjoy"
