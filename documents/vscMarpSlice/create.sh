#!/bin/bash
#
# 1. prefix : leyan
# 2. name: cdChannel
# 3. alias: 发布泳道
# 4. mkdir images

REPO_HOME=`git rev-parse --show-toplevel`
SLICES_HOME="$REPO_HOME/documents/vscMarpSlice"

read -p "Plz select you subject name: " SubjectName

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

# echo -n $MARP_STYLE > $SLICES_HOME/$SubjectName/$SubjectName.md

