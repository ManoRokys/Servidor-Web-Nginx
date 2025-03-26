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
