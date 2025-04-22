#!/bin/bash
set -eo pipefail  # 启用严格错误处理

# 调试信息（生产环境可注释）
echo "=== 开始执行文档部署流程 ==="
date

# API请求时间范围
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
two_hours_ago=$(date -u -d '2 hours ago' +"%Y-%m-%dT%H:%M:%SZ")

# 获取提交记录
response=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: token ${{ secrets.TOKEN }}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/HEUOpenResource/heu-icicles/commits?since=$two_hours_ago&until=$current_time")

# 分离响应内容和状态码
response_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

# 检查API响应
if [ "$response_code" -ne 200 ]; then
  echo "❌ GitHub API请求失败 (HTTP $response_code)"
  echo "响应内容：$response_body"
  exit 1
fi

# 判断是否有新提交
commit_count=$(echo "$response_body" | jq '. | length')
if [ "$commit_count" -gt 0 ]; then
  echo "✅ 检测到 $commit_count 条新提交，开始构建..."
  
  # 执行文档构建
  python dist.py
  
  # MkDocs部署（使用SSH方式）
  mkdocs gh-deploy --force \
    --remote-branch gh-pages \
    --verbose  # 显示详细日志

  echo "🎉 文档部署完成！"
else
  echo "####################################"
  echo "##  仓库两小时内无更新，跳过部署  ##"
  echo "####################################"
fi

# 清理临时文件
find . -name "*.pyc" -delete
rm -rf site/  # 清理构建产物

echo "=== 流程执行完毕 ==="