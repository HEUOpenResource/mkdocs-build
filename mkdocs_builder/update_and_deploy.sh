#!/bin/bash

# 获取当前时间和两小时前的时间
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
two_hours_ago=$(date -u -d '2 hours ago' +"%Y-%m-%dT%H:%M:%SZ")

# 从环境变量读取token
token=$1

# 使用 GitHub API 获取过去两小时内的提交信息
curl -s -H "Authorization: token $token" "https://api.github.com/repos/HEUOpenResource/heu-icicles/commits?since=$two_hours_ago&until=$current_time" > commits.json

# 判断是否有提交
if jq -e '. | length > 0' commits.json >/dev/null; then
    echo "Repository has been updated within the last two hours."

    # 执行指定的操作
    python dist.py
    git init
    git config --local user.name "only9464"
    git config --local user.email "sky9464@qq.com"
    export remote_repo="https://FuxuanNet:$token@github.com/HEUOpenResource/heu-icicles.git"
    git remote add origin $remote_repo
    mkdocs gh-deploy --force
else
    echo "#######################仓库两小时内无更新######################"
fi
