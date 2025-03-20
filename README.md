# Servidor-Web-Nginx
Este projeto consiste em um script automatizado para monitorar a disponibilidade de um site. Ele verifica periodicamente se o site está online e, em caso de falha, registra logs e envia alertas para um canal do Discord via Webhook.

# 🚀 AWS VPC + EC2 + NGINX + Monitoramento com Discord Webhooks

Este repositório contém um guia detalhado para a criação de uma infraestrutura na AWS, incluindo a configuração de uma VPC, instâncias EC2 com Nginx, e um sistema de monitoramento automatizado com notificações via Discord Webhooks.

---

## 📌 1. Criar a VPC
### Via AWS Console:
1. Acesse o AWS Management Console → VPC
2. Clique em **Create VPC**
3. Defina:
   - **Nome**: MinhaVPC
   - **IPv4 CIDR Block**: `10.0.0.0/16`
   - **Tenancy**: Default
4. Clique em **Create VPC**

---

## 📌 2. Criar as Sub-redes

### Criar Sub-redes Públicas:
1. Acesse **VPC → Subnets → Create Subnet**
2. Escolha a VPC criada anteriormente
3. Defina um Nome (**Publica-1**), escolha uma Zona de Disponibilidade (**us-east-1a**)
4. Defina o **CIDR Block**: `10.0.1.0/24`
5. Clique em **Create Subnet**
6. Repita para a segunda sub-rede pública (**Publica-2**, `10.0.2.0/24` em **us-east-1b**)

### Criar Sub-redes Privadas:
1. Siga os mesmos passos, mas com:
   - Nome: **Privada-1** e **Privada-2**
   - CIDR Blocks: `10.0.3.0/24` e `10.0.4.0/24`
   - AZs: **us-east-1a** e **us-east-1b**

### Tornar as Sub-redes Públicas:
1. Vá em **Subnets** e selecione **Publica-1** e **Publica-2**
2. Clique em **Actions → Modify auto-assign IP settings**
3. Marque **Enable auto-assign public IPv4 address**
4. Clique em **Save**

---

## 📌 3. Configurar a Internet Gateway
1. Vá em **Internet Gateways → Create Internet Gateway**
2. Nomeie como **MeuIGW** e clique em **Create**
3. Selecione o IGW criado e clique em **Attach to VPC**
4. Escolha a **VPC** e clique em **Attach Internet Gateway**

### Configurar a Tabela de Rotas
1. Vá em **Route Tables → Create Route Table**
2. Nomeie como **PublicRouteTable** e escolha a **VPC**
3. Após criar, edite **Routes → Add Route**
4. **Destination**: `0.0.0.0/0`  → **Target**: Selecione o **Internet Gateway criado (MeuIGW)**
5. Vá para **Subnet Associations → Edit subnet associations**
6. Associe as **sub-redes públicas** e clique em **Save associations**

---

## 📌 4. Criar a Instância EC2
### Escolher a AMI
1. Vá para **EC2 → Launch Instance**
2. Escolha uma AMI baseada em Linux:
   - **Amazon Linux 2023**
   - **Ubuntu Server 22.04 LTS**
   - **Debian 11**
3. Escolha o tipo da instância: **t2.micro** (Free Tier)
4. Selecione a **VPC** e a **sub-rede pública**
5. Habilite **Auto-assign Public IP**
6. Configure o **Security Group**:
   - **SSH (22)**: Apenas para seu IP ou `0.0.0.0/0` (não recomendado)
   - **HTTP (80)**: `0.0.0.0/0`
7. **Crie e Baixe** a chave de acesso `.pem`

---

## 📌 5. Instalar e Configurar o Nginx
### Instalar Nginx
```bash
sudo apt update
sudo apt install nginx -y
```
### Iniciar e Habilitar o Serviço
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```
### Criar Página HTML
```bash
sudo nano /var/www/html/index.html
```
Adicione:
```html
<!DOCTYPE html>
<html>
<head><title>Meu Projeto</title></head>
<body>
<h1>Bem-vindo ao Meu Projeto!</h1>
<p>Esta é a página inicial do nosso servidor Nginx na AWS.</p>
</body>
</html>
```
Reinicie o Nginx:
```bash
sudo systemctl restart nginx
```

### Configurar Restart Automático
```bash
sudo nano /etc/systemd/system/nginx.service
```
Adicione dentro de `[Service]`:
```ini
Restart=always
RestartSec=5
```
Reinicie o serviço:
```bash
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

---

## 📌 6. Criar Script de Monitoramento
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
logging.basicConfig(filename=LOG_FILE, level=logging.INFO)
def verificar_site():
    try:
        r = requests.get(URL, timeout=10)
        logging.info(f"✅ Site está online: {URL}") if r.status_code == 200 else enviar_alerta()
    except:
        enviar_alerta()
def enviar_alerta():
    requests.post(DISCORD_WEBHOOK, json={"content": f"🚨 Site {URL} está fora do ar!"})
if __name__ == "__main__": verificar_site()
```
Torne executável:
```bash
sudo chmod +x /usr/local/bin/monitorar_site.py
```

### Configurar Execução Automática
#### Usando Cron
```bash
sudo crontab -e
```
Adicione:
```bash
* * * * * /usr/local/bin/monitorar_site.py
```
#### Usando Systemd Timer
```bash
sudo nano /etc/systemd/system/monitoramento.timer
```
```ini
[Unit]
Description=Monitoramento do site a cada 1 minuto
[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
[Install]
WantedBy=timers.target
```
Ativar:
```bash
sudo systemctl enable --now monitoramento.timer
```

---

## 📌 7. Como Testar e Validar
- Acesse `http://SEU_IP` no navegador
- Para testar o monitoramento:
```bash
sudo pkill -9 nginx
sudo /usr/local/bin/monitorar_site.py
cat /var/log/monitoramento.log
```
Se configurado corretamente, uma notificação será enviada ao Discord! 🚀


