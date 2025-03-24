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
