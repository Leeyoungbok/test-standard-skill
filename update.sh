#!/bin/bash

echo "🔄 test-standard-skill 업데이트 중..."

# 현재 디렉토리 저장
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Git pull
echo "📥 최신 코드 가져오는 중..."
git pull origin main

# npm install (package.json이 변경된 경우)
if git diff HEAD@{1} HEAD --name-only | grep -q "package.json"; then
    echo "📦 의존성 업데이트 중..."
    npm install
fi

echo "✅ 업데이트 완료!"
echo "💡 Claude Desktop을 재시작하면 변경사항이 적용됩니다."
