#!/bin/bash
#

REPO_HOME=`git rev-parse --show-toplevel`
SLICES_HOME="$REPO_HOME/documents/vscMarpSlice"

read -p "Plz select you subject name: " SubjectName

# 测试: 如果 $SubjectName 存在, 则 报错退出.
if [ -d "$SLICES_HOME/$SubjectName" ]; then
    echo -e "Error: 目录 $SLICES_HOME/$SubjectName 已存在 !!! \n退出."
    exit 1
fi

# 创建 slice 目录, 创建 slice 模板.
mkdir -p $SLICES_HOME/$SubjectName/imgs/ && \
cat << EOF > $SLICES_HOME/$SubjectName/$SubjectName.md
---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---

EOF

