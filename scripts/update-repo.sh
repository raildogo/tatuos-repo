#!/bin/bash
# ==============================================================================
# TatuOS Repository — Atualizar índices APT
# ==============================================================================
# Uso: ./scripts/update-repo.sh [--sign]
#   --sign: Assina o Release com GPG (requer chave privada)
#
# Este script:
#   1. Escaneia pool/main/ com dpkg-scanpackages
#   2. Gera Packages e Packages.gz
#   3. Gera Release com apt-ftparchive
#   4. Opcionalmente assina com GPG → Release.gpg e InRelease
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dists/tatuos"
MAIN_DIR="$DIST_DIR/main/binary-amd64"
POOL_DIR="$REPO_ROOT/pool/main"
SIGN=false

# Parse args
for arg in "$@"; do
    case "$arg" in
        --sign) SIGN=true ;;
        *) echo "⚠️  Argumento desconhecido: $arg"; exit 1 ;;
    esac
done

echo "📦 Atualizando repositório TatuOS..."
echo "   REPO_ROOT: $REPO_ROOT"

# Garantir diretórios existem
mkdir -p "$MAIN_DIR" "$POOL_DIR"

# 1. Gerar Packages
echo "📋 Gerando Packages..."
cd "$REPO_ROOT"

if ls "$POOL_DIR"/*.deb 1>/dev/null 2>&1; then
    dpkg-scanpackages --arch amd64 pool/main /dev/null > "$MAIN_DIR/Packages"
    gzip -9c "$MAIN_DIR/Packages" > "$MAIN_DIR/Packages.gz"
    
    PKG_COUNT=$(grep -c "^Package:" "$MAIN_DIR/Packages" 2>/dev/null || echo "0")
    echo "   ✅ $PKG_COUNT pacote(s) indexado(s)"
else
    echo "   ⚠️  Nenhum .deb encontrado em pool/main/. Criando índices vazios."
    : > "$MAIN_DIR/Packages"
    gzip -9c "$MAIN_DIR/Packages" > "$MAIN_DIR/Packages.gz"
fi

# 2. Gerar Release
echo "📝 Gerando Release..."

# Calcular checksums dos arquivos de índice
PACKAGES_SIZE=$(wc -c < "$MAIN_DIR/Packages")
PACKAGES_GZ_SIZE=$(wc -c < "$MAIN_DIR/Packages.gz")
PACKAGES_MD5=$(md5sum "$MAIN_DIR/Packages" | awk '{print $1}')
PACKAGES_GZ_MD5=$(md5sum "$MAIN_DIR/Packages.gz" | awk '{print $1}')
PACKAGES_SHA256=$(sha256sum "$MAIN_DIR/Packages" | awk '{print $1}')
PACKAGES_GZ_SHA256=$(sha256sum "$MAIN_DIR/Packages.gz" | awk '{print $1}')

cat > "$DIST_DIR/Release" <<RELEASE
Origin: TatuOS
Label: TatuOS Repository
Suite: tatuos
Codename: tatuos
Version: 1.0
Architectures: amd64
Components: main
Description: Repositório oficial de pacotes do TatuOS
Date: $(date -Ru)
MD5Sum:
 $PACKAGES_MD5 $PACKAGES_SIZE main/binary-amd64/Packages
 $PACKAGES_GZ_MD5 $PACKAGES_GZ_SIZE main/binary-amd64/Packages.gz
SHA256:
 $PACKAGES_SHA256 $PACKAGES_SIZE main/binary-amd64/Packages
 $PACKAGES_GZ_SHA256 $PACKAGES_GZ_SIZE main/binary-amd64/Packages.gz
RELEASE

echo "   ✅ Release gerado"

# 3. Assinar com GPG (opcional)
if [ "$SIGN" = true ]; then
    echo "🔐 Assinando com GPG..."
    
    GPG_KEY="TatuOS Repository"
    
    # Release.gpg (assinatura detached)
    gpg --default-key "$GPG_KEY" \
        --armor --detach-sign \
        --output "$DIST_DIR/Release.gpg" \
        "$DIST_DIR/Release"
    
    # InRelease (assinatura inline — preferido pelo APT moderno)
    gpg --default-key "$GPG_KEY" \
        --armor --clearsign \
        --output "$DIST_DIR/InRelease" \
        "$DIST_DIR/Release"
    
    echo "   ✅ Release.gpg e InRelease gerados"
else
    echo "   ⏭️  Assinatura GPG ignorada (use --sign para assinar)"
fi

echo ""
echo "✅ Repositório atualizado com sucesso!"
echo "   Dist: $DIST_DIR"
ls -la "$MAIN_DIR/"
echo ""
ls -la "$DIST_DIR/" | grep -v "^total\|^d"
