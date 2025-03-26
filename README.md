# Servidor-Web-Nginx
Este projeto consiste em um script automatizado para monitorar a disponibilidade de um site. Ele verifica periodicamente se o site está online e, em caso de falha, registra logs e envia alertas para um canal do Discord via Webhook.

# 🚀 Guia Completo de Configuração e Monitoramento AWS + Nginx + Monitoramento via Webhook

Este guia detalha a configuração de uma infraestrutura AWS, a instalação de um servidor Nginx e a implementação de um sistema de monitoramento automatizado com alertas via Discord Webhook.

## 📖 Sumário
1. [Introdução](#servidor-web-nginx)  
2. [Criar a VPC](#📌-1️⃣-Criar-a-vpc)  
3. [Criar Sub-redes Públicas e Privadas](#2️⃣-criar-sub-redes-públicas-e-privadas)  
4. [Configurar Internet Gateway e Tabela de Rotas](#3️⃣-configurar-internet-gateway-e-tabela-de-rotas)  
5. [Criar e Configurar Instância EC2](#4️⃣-criar-e-configurar-instância-ec2)  
6. [Acesso via SSH e Configuração no WSL](#5️⃣-acesso-via-ssh-e-configuração-no-wsl)  
7. [Instalar e Configurar Nginx](#6️⃣-instalar-e-configurar-nginx)  
8. [Configurar Webhook do Discord](#7️⃣-configurar-webhook-do-discord)  
9. [Criar Script de Monitoramento](#8️⃣-criar-script-de-monitoramento)  
10. [Agendar Execução Automática](#9️⃣-agendar-execução-automática)  
11. [Testes Finais](#1️⃣0️⃣-testes-finais)  
12. [Infraestrutura Automatizada na AWS](#🚀-infraestrutura-automatizada-na-aws)  
13. [Configuração Automática via User Data](#⚙️-configuração-automática-via-user-data)  


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
   - Descobrir o IP da sua Maquina:
    
   ![Captura de tela 2025-03-24 083835](https://github.com/user-attachments/assets/0d09a8e0-7c88-4c42-8027-946915872eb5)

   ![Captura de tela 2025-03-24 083956](https://github.com/user-attachments/assets/75d1e6a8-9eed-47d9-9b0d-663811ff7ab7)

Conexão efetuada com sucesso: 

   ![Captura de tela 2025-03-24 084016](https://github.com/user-attachments/assets/e4e152a6-adf9-40a7-a792-2c4550f4df9f)

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
  
     ![Captura de tela 2025-03-19 104146](https://github.com/user-attachments/assets/075052a8-5aa8-47c7-b1af-db2f36bcb0f4)

     ![Captura de tela 2025-03-19 104201](https://github.com/user-attachments/assets/ad3caac7-e99b-4bc1-be47-e8fd79563f21)

   - Clique em **Novo Webhook**, escolha um canal e copie a **URL**

     ![Captura de tela 2025-03-19 104209](https://github.com/user-attachments/assets/5d9dfcf7-5a36-46ed-89fd-528d3eb09d36)

     ![Captura de tela 2025-03-19 104220](https://github.com/user-attachments/assets/e55a43b1-a356-4fa3-bf61-8739ba70ac3e)

     ![Captura de tela 2025-03-24 090223](https://github.com/user-attachments/assets/a1636934-c058-41e0-b98e-9fdb486c6572)


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
   ![Captura de tela 2025-03-24 092047](https://github.com/user-attachments/assets/0fb6932d-b00e-42fc-abc0-7d14319c3176)
   ![Captura de tela 2025-03-24 092056](https://github.com/user-attachments/assets/7a09527c-7d1c-4547-8042-6aa8215333ce)

Se os alertas estiverem aparecendo corretamente no Discord, a configuração está completa! 🎉



# 🚀 Infraestrutura Automatizada na AWS

Este repositório também fornece um guia completo para automatizar a criação de uma infraestrutura AWS usando **User Data** e **CloudFormation**. Ele provisiona automaticamente uma instância EC2 com **Nginx**, um **HTML personalizado** e um **script de monitoramento** que envia alertas para o Discord via Webhook.

## 📌 Requisitos

- Conta AWS com permissão para criar recursos EC2, VPC e Security Groups
- Chave SSH criada no AWS
- Webhook do Discord para monitoramento

---

## ⚙️ Configuração Automática via User Data

O script abaixo deve ser adicionado no campo **User Data** ao criar a instância EC2. Ele:

✅ Instala o **Nginx**
✅ Configura um **HTML de boas-vindas**
✅ Reinicia o **Nginx** automaticamente
✅ Baixa e configura um **script de monitoramento**
✅ Cria um **serviço systemd** para manter o Nginx sempre ativo

![Captura de tela 2025-03-25 084435](https://github.com/user-attachments/assets/d14c4187-1e66-4336-ac7c-37396b931b58)

![Captura de tela 2025-03-25 084542](https://github.com/user-attachments/assets/0db41170-f60d-44d8-8067-77be5125162e)

```bash
#!/bin/bash
# Atualiza pacotes e instala Nginx
apt update -y
apt install -y nginx python3-pip

# Configura o HTML da página inicial
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitoramento Ativo</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: #f4f4f4; }
        h1 { color: #333; }
        p { color: #555; }
    </style>
</head>
<body>
    <h1>Servidor Online!</h1>
</body>
</html>
EOF

# Reinicia o Nginx
systemctl restart nginx

# Cria um serviço systemd para reiniciar Nginx automaticamente
cat <<EOF > /etc/systemd/system/nginx-monitor.service
[Unit]
Description=Monitoramento do Nginx
After=network.target

[Service]
ExecStart=/bin/bash -c 'while true; do systemctl is-active --quiet nginx || systemctl restart nginx; sleep 60; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx-monitor
systemctl start nginx-monitor

# Baixa e configura o script de monitoramento
cat <<EOF > /usr/local/bin/monitorar_site.py
#!/usr/bin/env python3
import requests, logging

URL = "http://localhost"
DISCORD_WEBHOOK = "SEU_WEBHOOK_AQUI"
LOG_FILE = "/var/log/monitoramento.log"
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

def verificar_site():
    try:
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
EOF

chmod +x /usr/local/bin/monitorar_site.py

# Adiciona o monitoramento ao crontab para rodar a cada 1 minuto
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/monitorar_site.py") | crontab -
```

---

## 🌍 Infraestrutura Automatizada com CloudFormation
Agora, vamos criar um arquivo YAML para provisionar toda a infraestrutura automaticamente, incluindo:

✅ VPC
✅ Sub-redes
✅ Security Groups
✅ EC2 com User Data

📌 Criando o Template CloudFormation
Crie uma key pair com o nome: minha-chave (como informado no exemplo)
Crie um arquivo chamado infraestrutura.yaml e adicione:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Infraestrutura automatizada com EC2, VPC, Nginx e Monitoramento

Resources:
  MinhaVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: MinhaVPC

  MinhaSubRede:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MinhaVPC
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      AvailabilityZone: us-east-1a
      Tags:
        - Key: Name
          Value: MinhaSubRede

  MeuSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Permitir acesso HTTP e SSH
      VpcId: !Ref MinhaVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: MeuSecurityGroup

  MinhaInstanciaEC2:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0  # Substituir pela AMI da sua região
      InstanceType: t2.micro
      KeyName: minha-chave
      SubnetId: !Ref MinhaSubRede
      SecurityGroupIds:
        - !Ref MeuSecurityGroup
      Tags:
        - Key: Name
          Value: ServidorNginx
      UserData:
        Fn::Base64: |
          #!/bin/bash
          apt update -y
          apt install -y nginx python3-pip

          # Criar página HTML personalizada
          cat <<EOF > /var/www/html/index.html
          <!DOCTYPE html>
          <html lang="pt">
          <head>
              <title>Servidor Automatizado</title>
          </head>
          <body>
              <h1>Servidor Online!</h1>
          </body>
          </html>
          EOF

          systemctl restart nginx

          # Configuração do script de monitoramento
          cat <<EOF > /usr/local/bin/monitorar_site.py
          #!/usr/bin/env python3
          import requests, logging

          URL = "http://127.0.0.1"
          DISCORD_WEBHOOK = "https://discord.com/api/webhooks/SEU_WEBHOOK_AQUI"
          LOG_FILE = "/var/log/monitoramento.log"
          logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

          def verificar_site():
              try:
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
          EOF

          chmod +x /usr/local/bin/monitorar_site.py

          # Criar serviço systemd para execução automática
          cat <<EOF > /etc/systemd/system/monitoramento.service
          [Unit]
          Description=Monitoramento do servidor
          After=network.target

          [Service]
          ExecStart=/usr/bin/python3 /usr/local/bin/monitorar_site.py
          Restart=always
          User=root

          [Install]
          WantedBy=multi-user.target
          EOF

          systemctl enable monitoramento.service
          systemctl start monitoramento.service

          # Configurar cron para rodar a cada minuto
          echo "* * * * * root /usr/bin/python3 /usr/local/bin/monitorar_site.py" >> /etc/crontab

Outputs:
  PublicIP:
    Description: IP público da instância EC2
    Value: !GetAtt MinhaInstanciaEC2.PublicIp

```
## 📌 Como Implantar o CloudFormation
Acesse o AWS CloudFormation

Clique em Create Stack → With new resources

Escolha Upload a template file e envie o arquivo infraestrutura.yaml
















