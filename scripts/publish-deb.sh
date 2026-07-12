#!/bin/bash
# ==============================================================================
# TatuOS Repository — Publicar pacotes .deb
# ==============================================================================
# Uso: ./scripts/publish-deb.sh <arquivo.deb> [arquivo2.deb] ...
#
# Este script:
#   1. Copia .deb para pool/main/
#   2. Executa update-repo.sh --sign
#   3. Faz commit e push para o GitHub
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
POOL_DIR="$REPO_ROOT/pool/main"
SCRIPT_DIR="$REPO_ROOT/scripts"

if [ $# -eq 0 ]; then
    echo "❌ Uso: $0 <arquivo.deb> [arquivo2.deb] ..."
    echo ""
    echo "Exemplo:"
    echo "  $0 /caminho/para/meu-pacote_1.0_amd64.deb"
    exit 1
fi

echo "📦 Publicando pacote(s) no repositório TatuOS..."

# Validar e copiar cada .deb
COPIED=0
for DEB_FILE in "$@"; do
    if [ ! -f "$DEB_FILE" ]; then
        echo "   ❌ Arquivo não encontrado: $DEB_FILE"
        continue
    fi
    
    if [[ "$DEB_FILE" != *.deb ]]; then
        echo "   ❌ Não é um .deb: $DEB_FILE"
        continue
    fi
    
    # Validar integridade do .deb
    if ! dpkg-deb --info "$DEB_FILE" > /dev/null 2>&1; then
        echo "   ❌ Arquivo .deb inválido: $DEB_FILE"
        continue
    fi
    
    BASENAME=$(basename "$DEB_FILE")
    cp "$DEB_FILE" "$POOL_DIR/$BASENAME"
    echo "   ✅ Copiado: $BASENAME"
    ((COPIED++))
done

if [ "$COPIED" -eq 0 ]; then
    echo "❌ Nenhum pacote válido para publicar."
    exit 1
fi

# Atualizar índices e assinar
echo ""
"$SCRIPT_DIR/update-repo.sh" --sign

# Git commit e push
echo ""
echo "🚀 Fazendo commit e push..."
cd "$REPO_ROOT"
git add -A
git commit -m "📦 Publicar $COPIED pacote(s): $(date +%Y-%m-%d_%H:%M)"
git push origin main

echo ""
echo "✅ Publicação concluída!"
echo "   Os pacotes estarão disponíveis em:"
echo "   https://raildogo.github.io/tatuos-repo"
echo ""
echo "   Nos clientes TatuOS, execute:"
echo "   sudo apt update && sudo apt upgrade"
