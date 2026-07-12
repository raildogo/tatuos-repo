# 🐾 TatuOS Repository

Repositório APT oficial do **TatuOS** — distribuição Linux baseada em Debian Trixie (amd64).

## 📦 Como usar

### Adicionar o repositório manualmente

```bash
# 1. Baixar e instalar a chave GPG
curl -fsSL https://raildogo.github.io/tatuos-repo/tatuos-repo.gpg | \
  gpg --dearmor -o /usr/share/keyrings/tatuos-repo.gpg

# 2. Adicionar o repositório
echo "deb [signed-by=/usr/share/keyrings/tatuos-repo.gpg] https://raildogo.github.io/tatuos-repo tatuos main" | \
  sudo tee /etc/apt/sources.list.d/tatuos-repo.list

# 3. Atualizar e instalar
sudo apt update
```

### Para quem já usa TatuOS

O repositório já vem configurado automaticamente na instalação. Basta:

```bash
sudo apt update && sudo apt upgrade
```

## 🏗️ Estrutura

```
tatuos-repo/
├── dists/tatuos/main/binary-amd64/   # Índices de pacotes
├── pool/main/                         # Pacotes .deb
├── tatuos-repo.gpg                    # Chave GPG pública
└── scripts/                           # Scripts de manutenção
```

## 🔑 Verificação GPG

**Fingerprint da chave**: `B92C 00EB BCBF 9AF2 5AFE B165 C076 C0C1 A6E8 B946`

## 📋 Informações

| Item | Valor |
|---|---|
| **Distribuição** | TatuOS |
| **Base** | Debian Trixie |
| **Arquitetura** | amd64 |
| **Componente** | main |
| **Mantenedor** | raildogo |

## 📝 Licença

Este repositório e seus pacotes são distribuídos sob os termos de suas respectivas licenças.
