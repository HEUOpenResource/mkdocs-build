#!/bin/bash

# 获取当前时间
CURRENT_TIME=$(date +%s)

# 获取上次更新时间
LAST_UPDATE=$(git log -n 1 --format=%ct)

# 计算时间差（秒）
TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))

# 定义更新间隔（两小时）
UPDATE_INTERVAL=$((2 * 60 * 60))

# 如果两小时内有更新，则执行操作
if [ $TIME_DIFF -lt $UPDATE_INTERVAL ]; then
    echo "Repository has been updated within the last two hours."

    # 执行指定的操作
    python dist.py
    git init
    git config --local user.name "xhd0728"
    git config --local user.email "hdxin2002@gmail.com"
    export remote_repo="https://xhd0728:${TOKEN}@github.com/HEUOpenResource/heu-icicles.git"
    git remote add origin "${remote_repo}"
    mkdocs gh-deploy --force
else
    echo "#######################仓库两小时内无更新######################"
fi
