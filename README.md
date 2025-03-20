# Servidor-Web-Nginx
Este projeto consiste em um script automatizado para monitorar a disponibilidade de um site. Ele verifica periodicamente se o site está online e, em caso de falha, registra logs e envia alertas para um canal do Discord via Webhook.

# **Monitoramento de Site com Alertas no Discord** 🚀

## **Descrição**
Este projeto implementa um **sistema de monitoramento de site** que verifica periodicamente se o site está online. Caso uma falha seja detectada, o sistema registra logs e envia **alertas automáticos para um canal do Discord** via Webhook. 

## **Funcionalidades**
✅ **Verificação automática** da resposta HTTP do site  
✅ **Registro de logs** em `/var/log/monitoramento.log`  
✅ **Envio de alertas via Discord** quando o site estiver fora do ar  
✅ **Execução automática a cada 1 minuto** via `cron` ou `systemd timers`  

---

## **1️⃣ Configuração da AWS**

### **Criando uma VPC**
1. Acesse o **AWS Console** e vá até **VPC**.
2. Clique em **Create VPC** e defina:
   - **Nome:** MinhaVPC
   - **IPv4 CIDR Block:** `10.0.0.0/16`
   - **Tenancy:** Default
3. Clique em **Create VPC**.

### **Criando Sub-redes**
1. No menu **Subnets**, clique em **Create Subnet**.
2. Escolha a **VPC** criada anteriormente.
3. Crie duas sub-redes públicas:
   - **Publica-1:** `10.0.1.0/24` (us-east-1a)
   - **Publica-2:** `10.0.2.0/24` (us-east-1b)
4. Crie duas sub-redes privadas:
   - **Privada-1:** `10.0.3.0/24` (us-east-1a)
   - **Privada-2:** `10.0.4.0/24` (us-east-1b)

### **Habilitando IP Público nas Sub-redes Públicas**
1. No menu **Subnets**, selecione **Publica-1** e **Publica-2**.
2. Vá em **Actions → Modify auto-assign IP settings**.
3. Marque **Enable auto-assign public IPv4 address** e **Save**.

### **Criando e Configurando um Internet Gateway**
1. No menu **Internet Gateways**, clique em **Create Internet Gateway**.
2. Nomeie como **MeuIGW** e clique em **Create**.
3. Selecione o IGW e clique em **Attach to VPC**.
4. Escolha a **VPC** e clique em **Attach Internet Gateway**.

### **Configurando a Tabela de Rotas**
1. No menu **Route Tables**, clique em **Create Route Table**.
2. Nomeie como **PublicRouteTable** e escolha a **VPC**.
3. Após criar, clique na tabela, vá na aba **Routes** e adicione:
   - **Destination:** `0.0.0.0/0`
   - **Target:** Selecione o **Internet Gateway** criado.
4. Na aba **Subnet associations**, edite e selecione **Publica-1** e **Publica-2**.

---

## **2️⃣ Criando e Configurando a Instância EC2**

### **Criando a Instância**
1. No AWS Console, vá para **EC2** e clique em **Launch Instance**.
2. Escolha uma AMI baseada em Linux:
   - **Amazon Linux 2023**
   - **Ubuntu Server 22.04 LTS**
   - **Debian 11**
3. Escolha o tipo de instância (`t2.micro` para Free Tier).
4. Em **Network**, selecione a **VPC** criada e escolha uma **sub-rede pública**.
5. Ative **Auto-assign Public IP**.
6. Crie um **Security Group** com as seguintes regras:
   - **SSH (22):** Seu IP ou `0.0.0.0/0` (não seguro)
   - **HTTP (80):** `0.0.0.0/0`
7. Crie uma **chave de acesso (.pem)** e faça o download.
8. Clique em **Launch Instance** 🚀

### **Acessando a Instância via SSH**
No **Debian WSL**, mova e configure a chave de acesso:
```bash
mv /mnt/c/Users/SeuUsuario/Downloads/minha-chave.pem ~/ 
chmod 400 ~/minha-chave.pem
```
Acesse a instância com:
```bash
ssh -i ~/minha-chave.pem ubuntu@IP_PUBLICO
```

---

## **3️⃣ Monitoramento com Alertas no Discord**

### **Criando o Webhook no Discord**
1. Vá até **Configurações do Servidor → Integrações**.
2. Clique em **Webhooks → Novo Webhook**.
3. Escolha um **canal** e copie a **URL do Webhook**.

### **Criando o Script Python**
Crie o arquivo:
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
        if r.status_code == 200:
            logging.info(f"✅ Online: {URL}")
        else:
            logging.warning(f"⚠️ Erro {r.status_code}: {URL}")
    except:
        logging.error(f"❌ Offline: {URL}")
        requests.post(DISCORD_WEBHOOK, json={"content": f"🚨 {URL} fora do ar!"})
verificar_site()
```
Torne o script executável:
```bash
sudo chmod +x /usr/local/bin/monitorar_site.py
```
### **Automatizar com Cron**
Adicione ao `crontab`:
```bash
sudo crontab -e
* * * * * /usr/local/bin/monitorar_site.py
```
Agora o monitoramento está ativo! 🚀

