# Servidor-Web-Nginx
Este projeto consiste em um script automatizado para monitorar a disponibilidade de um site. Ele verifica periodicamente se o site está online e, em caso de falha, registra logs e envia alertas para um canal do Discord via Webhook.

# 🚀 Guia Completo de Configuração e Monitoramento AWS + Nginx + Monitoramento via Webhook

Este guia detalha a configuração de uma infraestrutura AWS, a instalação de um servidor Nginx e a implementação de um sistema de monitoramento automatizado com alertas via Discord Webhook.

## 📌 1️⃣ Criar a VPC
### Via AWS Console:
1. Acesse o AWS Management Console → VPC
2. Clique em **Create VPC**
3. Defina:
   - **Nome:** MinhaVPC
   - **IPv4 CIDR Block:** 10.0.0.0/16 (Exemplo, pode ajustar)
   - **Tenancy:** Default
4. Clique em **Create VPC**

## 🌐 2️⃣ Criar Sub-redes Públicas e Privadas
1. No menu lateral, clique em **Subnets** → **Create Subnet**
2. Escolha a VPC criada e defina:
   - **Sub-rede Pública 1:** CIDR 10.0.1.0/24, Zona us-east-1a
   - **Sub-rede Pública 2:** CIDR 10.0.2.0/24, Zona us-east-1b
   - **Sub-rede Privada 1:** CIDR 10.0.3.0/24, Zona us-east-1a
   - **Sub-rede Privada 2:** CIDR 10.0.4.0/24, Zona us-east-1b
3. Torne as **sub-redes públicas** ativando **Auto-assign Public IPv4**

## 🌍 3️⃣ Configurar Internet Gateway e Tabela de Rotas
1. **Internet Gateway**
   - Vá para **Internet Gateways** → **Create Internet Gateway**
   - Nomeie (ex: MeuIGW) → **Create** → **Attach to VPC**
2. **Tabela de Rotas**
   - Vá para **Route Tables** → **Create Route Table**
   - Associe à VPC e edite as **Routes**:
     - **Destination:** 0.0.0.0/0
     - **Target:** Internet Gateway (MeuIGW)
   - Associe as sub-redes públicas

## ☁️ 4️⃣ Criar e Configurar Instância EC2
1. **Criar Instância**
   - AWS Console → **EC2** → **Launch Instance**
   - Escolha uma AMI: Ubuntu 22.04, Debian 11 ou Amazon Linux
   - **Tipo:** t2.micro (grátis no Free Tier)
   - **Rede:** Escolha a VPC e uma sub-rede pública
   - **Habilite IP Público**
2. **Criar Security Group** com regras:
   - **SSH (22):** Seu IP ou 0.0.0.0/0 (inseguro para produção)
   - **HTTP (80):** 0.0.0.0/0
3. **Criar Chave SSH**
   - Nome: minha-chave → **Download Key Pair**
   - **Acesso via SSH**:
     ```bash
     ssh -i minha-chave.pem ubuntu@IP_PUBLICO
     ```

## ⚙️ 5️⃣ Instalar e Configurar Nginx
### Para Ubuntu/Debian:
```bash
sudo apt update && sudo apt install nginx -y
sudo systemctl start nginx && sudo systemctl enable nginx
```
### Configurar Página Web Personalizada:
```bash
sudo nano /var/www/html/index.html
```
Adicione:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head><title>Meu Projeto</title></head>
<body><h1>🚀 Servidor Nginx Online!</h1></body>
</html>
```
Reinicie o Nginx:
```bash
sudo systemctl restart nginx
```
Teste a configuração:
```bash
curl -I http://localhost
```

## 🛠️ 6️⃣ Criar Script de Monitoramento
Crie e edite o script:
```bash
sudo nano /usr/local/bin/monitorar_site.py
```
Adicione:
```python
#!/usr/bin/env python3
import requests, logging

URL = "http://SEU_SITE.com"
DISCORD_WEBHOOK = "https://discord.com/api/webhooks/SEU_WEBHOOK_AQUI"
LOG_FILE = "/var/log/monitoramento.log"
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

def verificar_site():
    try:
        resposta = requests.get(URL, timeout=10)
        if resposta.status_code == 200:
            logging.info(f"✅ Site online: {URL}")
        else:
            logging.warning(f"⚠️ Erro {resposta.status_code}: {URL}")
            enviar_alerta(f"⚠️ Alerta: Site {URL} retornou {resposta.status_code}!")
    except requests.RequestException:
        logging.error(f"❌ Site offline: {URL}")
        enviar_alerta(f"🚨 Alerta: Site {URL} está fora do ar!")

def enviar_alerta(mensagem):
    requests.post(DISCORD_WEBHOOK, json={"content": mensagem})

if __name__ == "__main__":
    verificar_site()
```
Torne o script executável:
```bash
sudo chmod +x /usr/local/bin/monitorar_site.py
```

## 🔄 7️⃣ Agendar Execução Automática
Para rodar o script a cada **1 minuto**, edite o crontab:
```bash
sudo crontab -e
```
Adicione:
```bash
* * * * * /usr/local/bin/monitorar_site.py
```

## 🔔 8️⃣ Configurar Webhook do Discord
1. **Criar Webhook**:
   - Vá até **Configurações do Servidor** → **Integrações** → **Webhooks**
   - Clique em **Novo Webhook**, escolha um canal e copie a **URL**
2. **Testar Webhook Manualmente**:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"content": "🚀 Teste de Webhook!"}' "URL_DO_SEU_WEBHOOK"
```
Se a mensagem aparecer no Discord, está funcionando! ✅

Agora, toda vez que o site cair ou apresentar erro, você receberá um alerta no seu canal do Discord! 🎯




