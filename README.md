# Servidor-Web-Nginx
Este projeto consiste em um script automatizado para monitorar a disponibilidade de um site. Ele verifica periodicamente se o site está online e, em caso de falha, registra logs e envia alertas para um canal do Discord via Webhook.

# 🚀 Guia Completo de Configuração e Monitoramento AWS + Nginx + Monitoramento via Webhook

Este guia detalha a configuração de uma infraestrutura AWS, a instalação de um servidor Nginx e a implementação de um sistema de monitoramento automatizado com alertas via Discord Webhook.

## 📌 1️⃣ Criar a VPC
### Via AWS Console:
1. Acesse o AWS Management Console → VPC

![Captura de tela 2025-03-24 104659](https://github.com/user-attachments/assets/20b88f57-432a-44ab-9908-df164b9cb2fe)

2. Clique em **Create VPC**
 
![Captura de tela 2025-03-18 092506](https://github.com/user-attachments/assets/56f8d3eb-5f2d-4845-91b1-5386f7c0edb8)

3. Clique em VPC only
4. Defina:
   - **Nome:** VPCNginxServer
   - **IPv4 CIDR:** 10.0.0.0/16 (Exemplo, pode ajustar)
   - **Tenancy:** Default
5. Clique em **Create VPC**

![Captura de tela 2025-03-18 092844](https://github.com/user-attachments/assets/04386eb4-34bf-4970-a74c-255bfc255ee4)


## 🌐 2️⃣ Criar Sub-redes Públicas e Privadas
1. No menu lateral, clique em **Subnets** → **Create Subnet**

![Captura de tela 2025-03-18 110459](https://github.com/user-attachments/assets/24ba6ab6-8225-42d0-b5ec-fd7df4ed237f)

2. Escolha a VPC criada e defina:

![Captura de tela 2025-03-24 080312](https://github.com/user-attachments/assets/63ff62e1-0847-4600-9c7e-44e0710b5582)

   - **Sub-rede Pública 1:** CIDR 10.0.1.0/24, Zona us-east-1a
   - **Sub-rede Pública 2:** CIDR 10.0.2.0/24, Zona us-east-1b
   
   ![Captura de tela 2025-03-18 093246](https://github.com/user-attachments/assets/9dca65be-f6e8-41d1-a0eb-82854ffedb2f)

   - **Sub-rede Privada 1:** CIDR 10.0.3.0/24, Zona us-east-1a
   - **Sub-rede Privada 2:** CIDR 10.0.4.0/24, Zona us-east-1b

   ![Captura de tela 2025-03-18 093535](https://github.com/user-attachments/assets/e6c01fc2-db01-4140-9fed-cc03552cfd9c)

3. Torne as **sub-redes públicas** ativando **Auto-assign Public IPv4**
   - Clique nas sub-redes publicas
   - Clique em **Actions**  → **Edit subnet settings**

 ![Captura de tela 2025-03-18 093823](https://github.com/user-attachments/assets/362e4013-8c9a-46c5-8cd0-9d4077b8282e)


## 🌍 3️⃣ Configurar Internet Gateway e Tabela de Rotas
1. **Internet Gateway**
   - Vá para **Internet Gateways** → **Create Internet Gateway**
   
![Captura de tela 2025-03-18 094039](https://github.com/user-attachments/assets/7d020a5a-8795-466e-a488-07b9f016bae9)

   - Nomeie (ex: IGWNginxServer) → **Create** → **Attach to VPC**

![Captura de tela 2025-03-18 094111](https://github.com/user-attachments/assets/bf9bbd02-91d4-404c-be18-0075347893a0)

![Captura de tela 2025-03-24 081056](https://github.com/user-attachments/assets/52430ca5-3237-421a-9f38-10f50224a16f)

![Captura de tela 2025-03-24 081132](https://github.com/user-attachments/assets/947312da-e370-42f6-9dcc-9135fccf45a7)

2. **Tabela de Rotas**
   - Vá para **Route Tables** → **Create Route Table**

![Captura de tela 2025-03-18 094339](https://github.com/user-attachments/assets/b20180c5-8a5e-45c8-a666-d3c417cb8e8c)

   - Associe à VPC e edite as **Routes**:
     
     ![Captura de tela 2025-03-18 094505](https://github.com/user-attachments/assets/7708ae9f-d383-4024-a9f0-bde303343641)

     ![Captura de tela 2025-03-24 081318](https://github.com/user-attachments/assets/bb8d8040-16e7-404f-b0bc-8fc32738531a)

     - Clique em **Add route**
     - **Destination:** 0.0.0.0/0
     - **Target:** Internet Gateway (IGWNginxServer)
     - **Save changes**
   - Associe as sub-redes públicas
   
     ![Captura de tela 2025-03-24 081603](https://github.com/user-attachments/assets/779b32e4-366a-4d1e-8107-f820d99b278a)
     ![Captura de tela 2025-03-24 081617](https://github.com/user-attachments/assets/ee04ebaf-a204-4a70-8e23-b966b8053721)

O Mapa final da sua VPC, deve estar assim ao final dessas etapas: 

![Captura de tela 2025-03-18 094840](https://github.com/user-attachments/assets/db85728e-e7ed-4b63-95e9-df35e72c0681)


## ☁️ 4️⃣ Criar e Configurar Instância EC2
1. **Criar Instância**
   - AWS Console → **EC2** → **Launch Instance**
   - Escolha uma AMI: Ubuntu 24.04(versão usada nos exemplos), Debian 11 ou Amazon Linux

   ![Captura de tela 2025-03-18 095707](https://github.com/user-attachments/assets/3b3354d1-1ef4-4a72-8ee1-24d89ca35b39)

   - **Instance type:** t2.micro (grátis no Free Tier)
   
   ![Captura de tela 2025-03-18 095804](https://github.com/user-attachments/assets/a495ffd8-b454-47b8-a9c5-84d50b8a9678)

   - **Network settings:** Escolha a VPC e uma sub-rede pública
   - **Habilite IP Público**

   ![Captura de tela 2025-03-24 082337](https://github.com/user-attachments/assets/bc28126a-a77c-466a-90a2-26c6e1e5ac67)

2. **Create Security Group** com regras:
   - **SSH (22):** Seu IP ou 0.0.0.0/0 (inseguro para produção)
   - **HTTP (80):** 0.0.0.0/0

   ![Captura de tela 2025-03-24 082354](https://github.com/user-attachments/assets/b85d1e13-7e45-49af-9858-e8f3336a269f)

3. **Key pair (login)**
   - **Create new key pair**
   - Criar Chave SSH
   - Nome: ChaveNginx
   - Formato: .pem (For use with OpenSSH)  
   - Clique em Create Key Pair e faça o download do arquivo .pem (caso não tenha feito automaticamente)

   ![Captura de tela 2025-03-18 095909](https://github.com/user-attachments/assets/6e0730ad-a213-4c60-ba6f-adcf6f3e42ba)

4. **Launch instance**

## 🔑 5️⃣ Acesso via SSH e Configuração no WSL

Se estiver utilizando **WSL (Windows Subsystem for Linux)**, siga os passos para mover a chave `.pem` e conectar-se à instância:

1. **Mova a chave para o ambiente WSL:**
   - No **WSL**, copie a chave para o diretório home do WSL:
     ```bash
     mv /mnt/c/Users/SeuUsuario/Downloads/ChaveNginx.pem ~/
     ```
   - No **WSL**, ajuste as permissões da chave:
     ```bash
     chmod 400 ~/ChaveNginx.pem
     ```
2. **Acesse a instância via SSH:**
   ```bash
   ssh -i ~/ChaveNginx.pem ubuntu@IP_PUBLICO
   ```

## ⚙️ 6️⃣ Instalar e Configurar Nginx
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
<body><h1>Servidor Nginx Online!</h1></body>
</html>
```
(para salvar o arquivo no nano,  digite Ctrl + x, aperte y e aperte enter)
Reinicie o Nginx:
```bash
sudo systemctl restart nginx
```
Teste a configuração:
```bash
curl -I http://localhost
```
Para acessar o servidor via navegador, copie o **IP Público** da instância no AWS e cole na barra de endereços do seu navegador:
```
http://IP_PUBLICO
```

## 🔔 7️⃣ Configurar Webhook do Discord
1. **Criar Webhook**:
   - Vá até **Configurações do Servidor** → **Integrações** → **Webhooks**
   - Clique em **Novo Webhook**, escolha um canal e copie a **URL**

## 🛠️ 8️⃣ Criar Script de Monitoramento
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
        resposta = requests.get(URL, timeout=10)
        if resposta.status_code == 200:
            logging.info(f"✅ Site online: {URL}")
            enviar_alerta(f"✅ O site {URL} está online!")   
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

## 🔄 9️⃣ Agendar Execução Automática
Para rodar o script a cada **1 minuto**, edite o crontab:
```bash
sudo crontab -e
```
Se for a primeira vez, o sistema perguntará qual editor deseja usar (nano, vim, etc.). Escolha um e então adicione a seguinte linha no final do arquivo:
```bash
* * * * * /usr/local/bin/monitorar_site.py
```


## ✅ 🔎 1️⃣0️⃣ Testes Finais

1. **Verificar logs do monitoramento:**
   ```bash
   cat /var/log/monitoramento.log
   ```
2. **Testar envio de alertas ao Discord:**
   ```bash
   tail -f /var/log/monitoramento.log
   ```
3. **Simular indisponibilidade do servidor:**
   ```bash
   sudo systemctl stop nginx
   ```
   Depois, reinicie:
   ```bash
   sudo systemctl start nginx
   ```
Se os alertas estiverem aparecendo corretamente no Discord, a configuração está completa! 🎉















