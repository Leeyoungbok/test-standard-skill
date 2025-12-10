#!/bin/bash

set -e

echo "🚀 Test Standard MCP 설치를 시작합니다..."

# 현재 디렉토리 저장
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 설치 경로: $SCRIPT_DIR"

# Node.js 확인
if ! command -v node &> /dev/null; then
    echo "❌ Node.js가 설치되어 있지 않습니다."
    echo "   다음 명령으로 설치하세요: brew install node"
    exit 1
fi

echo "✅ Node.js 버전: $(node --version)"

# npm 의존성 설치
echo "📦 의존성을 설치합니다..."
npm install

# MCP 클라이언트 감지 및 설정
echo ""
echo "🔍 MCP 클라이언트를 감지합니다..."

# Kiro CLI 설정
if [ -f "$HOME/.kiro/settings/mcp.json" ]; then
    echo "✅ Kiro CLI 감지됨"
    
    # 백업 생성
    cp "$HOME/.kiro/settings/mcp.json" "$HOME/.kiro/settings/mcp.json.backup"
    echo "   백업 생성: ~/.kiro/settings/mcp.json.backup"
    
    # jq로 JSON 파싱 및 추가
    if command -v jq &> /dev/null; then
        # test-standard-skill가 이미 있는지 확인
        if jq -e '.mcpServers["test-standard-skill"]' "$HOME/.kiro/settings/mcp.json" > /dev/null 2>&1; then
            echo "   ⚠️  test-standard-skill가 이미 설정되어 있습니다. 업데이트합니다..."
        fi
        
        # 새 설정 추가/업데이트
        jq --arg path "$SCRIPT_DIR/index.js" \
           '.mcpServers["test-standard-skill"] = {
              "command": "node",
              "args": [$path],
              "env": {},
              "timeout": 120000,
              "disabled": false,
              "disabledTools": []
            }' "$HOME/.kiro/settings/mcp.json" > "$HOME/.kiro/settings/mcp.json.tmp"
        
        mv "$HOME/.kiro/settings/mcp.json.tmp" "$HOME/.kiro/settings/mcp.json"
        echo "   ✅ Kiro CLI 설정 완료"
    else
        echo "   ⚠️  jq가 설치되어 있지 않습니다. 수동으로 설정하세요."
        echo "   설치: brew install jq"
    fi
fi

# Claude Desktop 설정
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
    echo "✅ Claude Desktop 감지됨"
    
    # 백업 생성
    cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup"
    echo "   백업 생성: $CLAUDE_CONFIG.backup"
    
    if command -v jq &> /dev/null; then
        # mcpServers 객체가 없으면 생성
        if ! jq -e '.mcpServers' "$CLAUDE_CONFIG" > /dev/null 2>&1; then
            jq '.mcpServers = {}' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp"
            mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
        fi
        
        # test-standard-skill 추가/업데이트
        jq --arg path "$SCRIPT_DIR/index.js" \
           '.mcpServers["test-standard-skill"] = {
              "command": "node",
              "args": [$path]
            }' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp"
        
        mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
        echo "   ✅ Claude Desktop 설정 완료"
    else
        echo "   ⚠️  jq가 설치되어 있지 않습니다. 수동으로 설정하세요."
    fi
fi

# 설정된 클라이언트가 없는 경우
if [ ! -f "$HOME/.kiro/settings/mcp.json" ] && [ ! -f "$CLAUDE_CONFIG" ]; then
    echo "⚠️  MCP 클라이언트를 찾을 수 없습니다."
    echo ""
    echo "수동 설정 방법:"
    echo "1. Kiro CLI: ~/.kiro/settings/mcp.json"
    echo "2. Claude Desktop: ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo ""
    echo "다음 내용을 추가하세요:"
    echo '{'
    echo '  "mcpServers": {'
    echo '    "test-standard-skill": {'
    echo '      "command": "node",'
    echo "      \"args\": [\"$SCRIPT_DIR/index.js\"]"
    echo '    }'
    echo '  }'
    echo '}'
fi

echo ""
echo "✨ 설치가 완료되었습니다!"
echo ""
echo "📝 다음 단계:"
echo "1. MCP 클라이언트를 재시작하세요"
echo "   - Kiro CLI: /quit 후 kiro-cli chat"
echo "   - Claude Desktop: 앱 재시작"
echo ""
echo "2. 설치 확인:"
echo "   'test-standard-skill 도구를 사용해서...' 요청"
echo ""
echo "📚 자세한 사용법: $SCRIPT_DIR/README.md"
