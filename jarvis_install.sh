#!/bin/bash

# ============================================
# Джарвис - универсальный установщик Telegram бота
# Версия: 4.0 - с навыками (skills)
# ============================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Файлы конфигурации
JARVIS_DIR="/opt/jarvis"
JARVIS_USER="jarvis"
BOT_SCRIPT="$JARVIS_DIR/jarvis_bot.py"
SKILLS_SCRIPT="$JARVIS_DIR/skills.py"
SERVICE_FILE="/etc/systemd/system/jarvis-bot.service"
CONFIG_FILE="$JARVIS_DIR/config.env"
SKILLS_CONFIG="$JARVIS_DIR/skills_config.json"

# Функции вывода
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

pause() {
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

get_model_by_number() {
    case $1 in
        1) echo "deepseek-r1:7b" ;;
        2) echo "deepseek-r1:8b" ;;
        3) echo "qwq:32b" ;;
        4) echo "qwen3:8b" ;;
        5) echo "qwen3:14b" ;;
        6) echo "qwen2.5:7b" ;;
        7) echo "llama3.3:70b" ;;
        8) echo "gpt-oss:20b" ;;
        9) echo "gpt-oss:120b" ;;
        10) echo "deepseek-coder:6.7b" ;;
        11) echo "qwen2.5-coder:7b" ;;
        12) echo "qwen2.5:1.5b" ;;
        13) echo "llama3.2:3b" ;;
        14) echo "phi3:3.8b" ;;
        15) echo "llava:7b" ;;
        16) echo "llava-phi3:3.8b" ;;
        17) echo "moondream:1.8b" ;;
        18) echo "qwen3-vl:8b" ;;
        19) echo "gemma3:12b-vision" ;;
        20) echo "minicpm-v:8b" ;;
        21) echo "deepseek-ocr:3b" ;;
        22) echo "cogvlm:17b" ;;
        23) echo "bakllava:7b" ;;
        24) echo "llava-llama3:8b" ;;
        25) echo "granite3.2-vision:2b" ;;
        26) echo "qwen2.5vl:7b" ;;
        27) echo "qwen2.5vl:32b" ;;
        28) echo "whisper:tiny" ;;
        29) echo "whisper:small" ;;
        30) echo "whisper:medium" ;;
        31) echo "whisper:large" ;;
        32) echo "video-llava:7b" ;;
        33) echo "internvl2:8b" ;;
        34) echo "llava-next:7b" ;;
        *) echo "qwen2.5:1.5b" ;;
    esac
}

# ============================================
# ПОКАЗ ВСЕХ МОДЕЛЕЙ
# ============================================
show_all_models() {
    clear
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                              📦 ДОСТУПНЫЕ МОДЕЛИ (44 варианта)                              ${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}🧠 REASONING (думают вслух):${NC}"
    echo -e "     1. deepseek-r1:7b       2. deepseek-r1:8b       3. qwq:32b"
    echo ""
    echo -e "  ${YELLOW}🏆 ТОПОВЫЕ ЛОКАЛЬНЫЕ:${NC}"
    echo -e "     4. qwen3:8b             5. qwen3:14b            6. qwen2.5:7b"
    echo -e "     7. llama3.3:70b         8. gpt-oss:20b          9. gpt-oss:120b"
    echo ""
    echo -e "  ${YELLOW}💻 КОД И ТЕХНИЧЕСКИЕ:${NC}"
    echo -e "    10. deepseek-coder:6.7b  11. qwen2.5-coder:7b"
    echo ""
    echo -e "  ${YELLOW}⚡ ЛЁГКИЕ (для слабых серверов):${NC}"
    echo -e "    12. qwen2.5:1.5b         13. llama3.2:3b         14. phi3:3.8b"
    echo ""
    echo -e "  ${YELLOW}🎨 МУЛЬТИМОДАЛЬНЫЕ (видят изображения):${NC}"
    echo -e "    15. llava:7b             16. llava-phi3:3.8b     17. moondream:1.8b"
    echo -e "    18. qwen3-vl:8b          19. gemma3:12b-vision   20. minicpm-v:8b"
    echo -e "    21. deepseek-ocr:3b      22. cogvlm:17b          23. bakllava:7b"
    echo -e "    24. llava-llama3:8b      25. granite3.2-vision   26. qwen2.5vl:7b"
    echo -e "    27. qwen2.5vl:32b"
    echo ""
    echo -e "  ${YELLOW}🎵 АУДИО МОДЕЛИ (распознавание речи):${NC}"
    echo -e "    28. whisper:tiny         29. whisper:small       30. whisper:medium"
    echo -e "    31. whisper:large"
    echo ""
    echo -e "  ${YELLOW}🎥 ВИДЕО МОДЕЛИ:${NC}"
    echo -e "    32. video-llava:7b       33. internvl2:8b        34. llava-next:7b"
    echo ""
    echo -e "  ${YELLOW}🤖 CHATGPT (платные варианты):${NC}"
    echo -e "    35. ChatGPT (OpenAI API)       - 💰 платный API"
    echo -e "    36. ChatGPT (ChatMock)         - 💰 требует ChatGPT Plus"
    echo -e "    37. ChatGPT (GPT-OSS)          - ✅ бесплатно, локально"
    echo ""
    echo -e "  ${YELLOW}🔧 38. Своя модель${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================
# СОЗДАНИЕ СКРИПТА НАВЫКОВ
# ============================================
create_skills_script() {
    cat > $SKILLS_SCRIPT << 'EOF'
#!/usr/bin/env python3
import subprocess
import json
import os
import requests
import re
from datetime import datetime

SKILLS_CONFIG = "/opt/jarvis/skills_config.json"

def load_skills_config():
    if os.path.exists(SKILLS_CONFIG):
        with open(SKILLS_CONFIG, 'r') as f:
            return json.load(f)
    return {
        "system": True,
        "file": True,
        "weather": True,
        "reminder": True,
        "search": True
    }

def save_skills_config(config):
    with open(SKILLS_CONFIG, 'w') as f:
        json.dump(config, f, indent=2)

# ============================================
# НАВЫКИ
# ============================================

def execute_shell(command, user_id):
    dangerous = ["rm -rf /", "mkfs", "dd if=", "> /dev/sda", "shutdown", "reboot", "poweroff"]
    for d in dangerous:
        if d in command:
            return f"⛔ Команда '{d}' заблокирована"
    
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=30)
        output = result.stdout if result.stdout else result.stderr
        if len(output) > 4000:
            output = output[:4000] + "\n\n... (обрезано)"
        return output if output else "✅ Команда выполнена (нет вывода)"
    except subprocess.TimeoutExpired:
        return "⏰ Команда выполнялась >30 сек, прервано"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def read_file(path):
    try:
        if not os.path.exists(path):
            return f"❌ Файл {path} не найден"
        with open(path, 'r') as f:
            content = f.read(10000)
            return content if content else "(файл пуст)"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def write_file(path, content):
    try:
        with open(path, 'w') as f:
            f.write(content)
        return f"✅ Файл {path} сохранён"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def get_weather(city="Moscow"):
    try:
        response = requests.get(f"https://wttr.in/{city}?format=%C+%t+%w", timeout=10)
        if response.status_code == 200:
            return f"🌤️ {city}: {response.text.strip()}"
        return f"❌ Не удалось получить погоду для {city}"
    except:
        return "❌ Ошибка подключения к сервису погоды"

def search_web(query):
    try:
        response = requests.get(
            f"https://html.duckduckgo.com/html/?q={query}",
            headers={"User-Agent": "Mozilla/5.0"},
            timeout=10
        )
        results = re.findall(r'<a rel="nofollow" class="result-link" href="([^"]+)"', response.text)
        titles = re.findall(r'<a class="result-link" [^>]*><span[^>]*>([^<]+)</span>', response.text)
        
        output = f"🔍 Результаты поиска для '{query}':\n\n"
        for i, (title, url) in enumerate(zip(titles[:5], results[:5])):
            output += f"{i+1}. {title}\n   {url}\n\n"
        return output if output else "❌ Ничего не найдено"
    except:
        return "❌ Ошибка поиска"

reminders = {}

def add_reminder(user_id, text, seconds):
    import threading
    def remind():
        import time
        time.sleep(seconds)
        print(f"REMINDER:{user_id}:{text}")
    t = threading.Thread(target=remind)
    t.daemon = True
    t.start()
    return f"✅ Напоминание установлено на {seconds} сек: {text}"

def process_skills(text, user_id, skills_config, send_callback=None):
    text_lower = text.lower()
    
    if text_lower.startswith('!') or text_lower.startswith('$'):
        if skills_config.get("system", False):
            command = text[1:] if text.startswith('!') else text[1:]
            return execute_shell(command, user_id)
        return "⛔ Навык 'system' отключён"
    
    if text_lower.startswith('@cat '):
        if skills_config.get("file", False):
            path = text[5:].strip()
            return read_file(path)
        return "⛔ Навык 'file' отключён"
    
    if text_lower.startswith('@write '):
        if skills_config.get("file", False):
            parts = text[7:].split('||', 1)
            if len(parts) == 2:
                path = parts[0].strip()
                content = parts[1].strip()
                return write_file(path, content)
            return "❌ Формат: @write /путь/файла || содержание"
        return "⛔ Навык 'file' отключён"
    
    if 'погода' in text_lower or 'weather' in text_lower:
        if skills_config.get("weather", False):
            city_match = re.search(r'(?:в|in)\s+([A-Za-zА-Яа-я-]+)', text)
            city = city_match.group(1) if city_match else "Moscow"
            return get_weather(city)
        return "⛔ Навык 'weather' отключён"
    
    if text_lower.startswith('найди ') or text_lower.startswith('поиск ') or text_lower.startswith('search '):
        if skills_config.get("search", False):
            query = text_lower.replace('найди ', '').replace('поиск ', '').replace('search ', '')
            return search_web(query)
        return "⛔ Навык 'search' отключён"
    
    if text_lower.startswith('напомни ') or text_lower.startswith('remind '):
        if skills_config.get("reminder", False):
            parts = text_lower.replace('напомни ', '').replace('remind ', '').split(' через ', 1)
            if len(parts) == 2:
                reminder_text = parts[0]
                time_part = parts[1]
                seconds = 60
                if 'мин' in time_part:
                    seconds = int(re.search(r'\d+', time_part).group()) * 60
                elif 'сек' in time_part:
                    seconds = int(re.search(r'\d+', time_part).group())
                elif 'час' in time_part:
                    seconds = int(re.search(r'\d+', time_part).group()) * 3600
                return add_reminder(user_id, reminder_text, seconds)
            return "❌ Формат: напомни [текст] через [время] (сек/мин/час)"
        return "⛔ Навык 'reminder' отключён"
    
    return None

def toggle_skill(skill_name, enable):
    config = load_skills_config()
    if skill_name in config:
        config[skill_name] = enable
        save_skills_config(config)
        return f"✅ Навык '{skill_name}' {'включён' if enable else 'отключён'}"
    return f"❌ Навык '{skill_name}' не найден"

def list_skills():
    config = load_skills_config()
    output = "📦 **Доступные навыки:**\n\n"
    for skill, enabled in config.items():
        status = "🟢" if enabled else "🔴"
        output += f"{status} {skill}\n"
    return output

def help_skills():
    return """
📦 **Навыки Джарвиса:**

| Команда | Описание |
|---------|----------|
| `!команда` | Выполнить shell команду |
| `@cat /путь/файла` | Показать содержимое файла |
| `@write /путь || текст` | Записать текст в файл |
| `погода в Москве` | Показать погоду |
| `найди что-то` | Поиск в интернете |
| `напомни текст через 5 мин` | Напоминание |

**Управление (только админ):**
`/skills` — список навыков
`/skill on system` — включить навык
`/skill off system` — выключить навык
"""
EOF

    chown $JARVIS_USER:$JARVIS_USER $SKILLS_SCRIPT
}

# ============================================
# СОЗДАНИЕ СКРИПТА БОТА
# ============================================
create_bot_script() {
    cat > $BOT_SCRIPT << 'EOF'
#!/usr/bin/env python3
import os
import sys
import json
import requests
import base64
import subprocess
import asyncio
from datetime import datetime
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
import skills

CONFIG_FILE = "/opt/jarvis/config.env"

def load_config():
    config = {}
    with open(CONFIG_FILE, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                key, value = line.split('=', 1)
                config[key] = value.strip('"')
    return config

config = load_config()
BOT_TOKEN = config.get("BOT_TOKEN")
MODEL = config.get("MODEL", "qwen2.5:1.5b")
ALLOWED_USERS = config.get("ALLOWED_USERS", "").split()
OLLAMA_URL = config.get("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
USE_OPENAI = config.get("USE_OPENAI", "false") == "true"
OPENAI_KEY = config.get("OPENAI_API_KEY", "")
OPENAI_MODEL = config.get("OPENAI_MODEL", "gpt-4o-mini")

def is_vision_model(model_name):
    vision_models = ["llava", "bakllava", "moondream", "qwen3-vl", "gemma3", "minicpm-v", "cogvlm", "qwen2.5vl", "video-llava", "internvl2", "llava-next", "granite3.2-vision"]
    return any(vm in model_name.lower() for vm in vision_models)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    await update.message.reply_text(
        "🦞 **Джарвис**\n\n"
        "Я ваш персональный AI-ассистент.\n\n"
        "📸 **Отправьте фото** — опишу\n"
        "🎤 **Отправьте голосовое** — распознаю речь\n"
        "💬 **Напишите текст** — отвечу\n\n"
        "⚡ **Навыки:** !команда, @cat, погода, найди, напомни\n"
        "/skills — список навыков\n"
        "/help — помощь",
        parse_mode="Markdown"
    )

async def help_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(skills.help_skills())

async def model_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    await update.message.reply_text(
        f"🤖 **Модель:** `{MODEL}`\n"
        f"🖼️ Vision: {'✅' if is_vision_model(MODEL) else '❌'}",
        parse_mode="Markdown"
    )

async def skills_list(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    await update.message.reply_text(skills.list_skills(), parse_mode="Markdown")

async def skill_toggle(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    if len(context.args) != 2:
        await update.message.reply_text("Использование: /skill on/off название")
        return
    action = context.args[0].lower()
    skill_name = context.args[1].lower()
    if action == "on":
        result = skills.toggle_skill(skill_name, True)
    elif action == "off":
        result = skills.toggle_skill(skill_name, False)
    else:
        result = "❌ Используйте on или off"
    await update.message.reply_text(result)

async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    if not is_vision_model(MODEL):
        await update.message.reply_text(f"❌ Модель {MODEL} не поддерживает изображения")
        return
    await update.message.reply_chat_action("typing")
    try:
        photo_file = await update.message.photo[-1].get_file()
        photo_bytes = await photo_file.download_as_bytearray()
        image_b64 = base64.b64encode(photo_bytes).decode()
        response = requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "prompt": "Опиши подробно, что видишь на изображении",
            "images": [image_b64],
            "stream": False
        }, timeout=120)
        if response.status_code == 200:
            reply = response.json().get("response", "Не могу описать")
            await update.message.reply_text(reply)
        else:
            await update.message.reply_text("⚠️ Ошибка обработки")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def handle_voice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    await update.message.reply_chat_action("typing")
    try:
        voice_file = await update.message.voice.get_file()
        voice_path = f"/tmp/voice_{user_id}.ogg"
        await voice_file.download_to_drive(voice_path)
        wav_path = f"/tmp/voice_{user_id}.wav"
        subprocess.run(["ffmpeg", "-i", voice_path, "-ar", "16000", "-ac", "1", wav_path, "-y"], capture_output=True)
        whisper_response = requests.post("http://127.0.0.1:11434/api/generate", json={
            "model": "whisper:tiny",
            "prompt": "",
            "file": wav_path,
            "stream": False
        }, timeout=60)
        text = whisper_response.json().get("response", "") if whisper_response.status_code == 200 else ""
        if text:
            response = requests.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": f"Пользователь сказал: {text}\n\nОтветь:",
                "stream": False
            }, timeout=60)
            if response.status_code == 200:
                await update.message.reply_text(response.json().get("response", ""))
            else:
                await update.message.reply_text(f"🎤 Распознано: {text}")
        else:
            await update.message.reply_text("🎤 Не удалось распознать речь")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    
    user_text = update.message.text
    skills_config = skills.load_skills_config()
    
    skill_result = skills.process_skills(user_text, user_id, skills_config)
    if skill_result:
        await update.message.reply_text(skill_result)
        return
    
    await update.message.reply_chat_action("typing")
    try:
        if USE_OPENAI and OPENAI_KEY:
            import openai
            openai.api_key = OPENAI_KEY
            response = openai.ChatCompletion.create(
                model=OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": "Ты Джарвис. Отвечай кратко и по делу."},
                    {"role": "user", "content": user_text}
                ],
                timeout=60
            )
            reply = response.choices[0].message.content
            await update.message.reply_text(reply)
        else:
            response = requests.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": f"Ты Джарвис. Отвечай кратко и по делу. Пользователь: {user_text}",
                "stream": False
            }, timeout=120)
            if response.status_code == 200:
                reply = response.json().get("response", "Не могу ответить")
                await update.message.reply_text(reply)
            else:
                await update.message.reply_text("⚠️ Ошибка модели")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def status_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    try:
        cpu = subprocess.check_output("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1", shell=True).decode().strip()
        mem = subprocess.check_output("free -h | awk '/^Mem:/ {print $3\"/\"$2}'", shell=True).decode().strip()
        uptime = subprocess.check_output("uptime -p", shell=True).decode().strip()
    except:
        cpu = mem = uptime = "N/A"
    await update.message.reply_text(
        f"🦞 **Джарвис**\n\n"
        f"🤖 Модель: `{MODEL}`\n"
        f"📊 CPU: {cpu}%\n"
        f"💾 Память: {mem}\n"
        f"⏱️ Время работы: {uptime}",
        parse_mode="Markdown"
    )

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_cmd))
    app.add_handler(CommandHandler("model", model_cmd))
    app.add_handler(CommandHandler("skills", skills_list))
    app.add_handler(CommandHandler("skill", skill_toggle))
    app.add_handler(CommandHandler("status", status_cmd))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.VOICE, handle_voice))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print(f"🦞 Джарвис запущен! Модель: {MODEL}")
    app.run_polling()

if __name__ == "__main__":
    main()
EOF

    chown $JARVIS_USER:$JARVIS_USER $BOT_SCRIPT
}

# ============================================
# СОЗДАНИЕ SYSTEMD СЕРВИСА
# ============================================
create_systemd_service() {
    cat > $SERVICE_FILE << EOF
[Unit]
Description=Jarvis Telegram Bot
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=$JARVIS_USER
WorkingDirectory=$JARVIS_DIR
Environment="PATH=$JARVIS_DIR/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$JARVIS_DIR/venv/bin/python $BOT_SCRIPT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ============================================
# ФУНКЦИЯ УСТАНОВКИ
# ============================================
install_jarvis() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                                    🦞 ${CYAN}${BOLD}ДЖАРВИС 4.0${NC} 🦞                                      ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                                                                                    ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                        ${YELLOW}✨ Передай привеД ПОТАПу !!! ✨${NC}                           ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$EUID" -ne 0 ]; then 
        print_error "Запустите скрипт от root (sudo ./jarvis_install.sh)"
        exit 1
    fi

    # Telegram бот
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🤖 TELEGRAM БОТ                          │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│ 1. Найдите @BotFather в Telegram                                   │"
    echo -e "│ 2. Отправьте /newbot                                               │"
    echo -e "│ 3. Получите токен                                                  │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Введите токен: " BOT_TOKEN
    while [ -z "$BOT_TOKEN" ]; do
        print_error "Токен не может быть пустым!"
        read -p "👉 Введите токен: " BOT_TOKEN
    done

    # Chat ID
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    👤 ВАШ CHAT ID                          │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│ 1. Найдите @userinfobot в Telegram                                 │"
    echo -e "│ 2. Отправьте любое сообщение                                        │"
    echo -e "│ 3. Скопируйте ID (число)                                           │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Введите Chat ID: " CHAT_ID
    while [ -z "$CHAT_ID" ]; do
        print_error "Chat ID не может быть пустым!"
        read -p "👉 Введите Chat ID: " CHAT_ID
    done

    # Модель
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🧠 ВЫБОР МОДЕЛИ                          │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│  ${GREEN}1${NC}) qwen2.5:1.5b  - 1GB   - быстрая                        │"
    echo -e "│  ${GREEN}2${NC}) llama3.2:3b    - 2GB   - хороший баланс                │"
    echo -e "│  ${GREEN}3${NC}) qwen2.5:7b     - 4.5GB - умная                         │"
    echo -e "│  ${GREEN}4${NC}) deepseek-r1:7b - 4.7GB - reasoning (думает вслух)      │"
    echo -e "│  ${GREEN}5${NC}) llava:7b       - 4.5GB - видит изображения              │"
    echo -e "│  ${GREEN}6${NC}) moondream:1.8b - 1.2GB - лёгкая, видит фото            │"
    echo -e "│  ${GREEN}7${NC}) Показать все 44 модели                                │"
    echo -e "│  ${GREEN}8${NC}) Своя модель                                           │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    FREE_RAM=$(free -g | awk '/^Mem:/{print $7}')
    echo -e "${BLUE}💾 Ваш сервер:${NC} ${TOTAL_RAM}GB RAM (свободно ~${FREE_RAM}GB)"
    echo ""
    
    read -p "👉 Выберите [1-8]: " MODEL_CHOICE
    
    case $MODEL_CHOICE in
        1) MODEL="qwen2.5:1.5b" ;;
        2) MODEL="llama3.2:3b" ;;
        3) MODEL="qwen2.5:7b" ;;
        4) MODEL="deepseek-r1:7b" ;;
        5) MODEL="llava:7b" ;;
        6) MODEL="moondream:1.8b" ;;
        7) 
            show_all_models
            read -p "👉 Введите номер модели: " num
            MODEL=$(get_model_by_number $num)
            ;;
        8) 
            read -p "👉 Введите название модели: " MODEL
            ;;
        *) MODEL="qwen2.5:1.5b" ;;
    esac

    # Дополнительные пользователи
    echo ""
    read -p "👉 Дополнительные Chat ID (через пробел, или пусто): " EXTRA_USERS

    # ChatGPT API
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🤖 CHATGPT API                          │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│ Использовать ChatGPT через API? (платно)                          │"
    echo -e "│ Ключ: https://platform.openai.com/api-keys                        │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Использовать ChatGPT API? (y/N): " use_openai
    if [[ "$use_openai" == "y" || "$use_openai" == "Y" ]]; then
        read -p "👉 OpenAI API ключ: " OPENAI_KEY
        read -p "👉 Модель (gpt-4o-mini/gpt-4o): " OPENAI_MODEL
        USE_OPENAI="true"
    else
        USE_OPENAI="false"
    fi

    # Подтверждение
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ ВСЕ ДАННЫЕ СОБРАНЫ!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🤖 Токен: ${GREEN}${BOT_TOKEN:0:20}...${NC}"
    echo -e "👤 Chat ID: ${GREEN}$CHAT_ID${NC}"
    echo -e "🧠 Модель: ${GREEN}$MODEL${NC}"
    echo -e "👥 Доп. пользователи: ${GREEN}${EXTRA_USERS:-нет}${NC}"
    echo -e "🤖 ChatGPT API: ${GREEN}$USE_OPENAI${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Начать установку? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Установка отменена"
        pause
        return
    fi

    # Установка
    print_info "Начинаю установку..."
    apt update && apt upgrade -y
    apt install -y curl git wget python3 python3-pip python3-venv ufw ffmpeg

    if ! command -v ollama &> /dev/null; then
        print_info "Установка Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi

    print_info "Загрузка модели $MODEL..."
    ollama pull $MODEL

    if [[ "$MODEL" == *"llava"* ]] || [[ "$MODEL" == *"moondream"* ]]; then
        print_info "Скачивание whisper для голоса..."
        ollama pull whisper:tiny 2>/dev/null || true
    fi

    id "$JARVIS_USER" &>/dev/null || useradd -m -s /usr/sbin/nologin $JARVIS_USER
    mkdir -p $JARVIS_DIR
    chown $JARVIS_USER:$JARVIS_USER $JARVIS_DIR

    cat > $CONFIG_FILE << EOF
BOT_TOKEN="$BOT_TOKEN"
MODEL="$MODEL"
ALLOWED_USERS="$CHAT_ID $EXTRA_USERS"
OLLAMA_URL="http://127.0.0.1:11434/api/generate"
USE_OPENAI="$USE_OPENAI"
EOF
    if [[ "$USE_OPENAI" == "true" ]]; then
        echo "OPENAI_API_KEY=\"$OPENAI_KEY\"" >> $CONFIG_FILE
        echo "OPENAI_MODEL=\"$OPENAI_MODEL\"" >> $CONFIG_FILE
    fi

    create_skills_script
    create_bot_script
    chmod +x $BOT_SCRIPT $SKILLS_SCRIPT
    chown -R $JARVIS_USER:$JARVIS_USER $JARVIS_DIR

    sudo -u $JARVIS_USER python3 -m venv $JARVIS_DIR/venv
    sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install --quiet python-telegram-bot requests pillow

    create_systemd_service
    systemctl daemon-reload
    systemctl enable jarvis-bot
    systemctl restart ollama
    sleep 3
    systemctl restart jarvis-bot

    print_success "Джарвис установлен и запущен!"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ УСТАНОВКА ЗАВЕРШЕНА!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🔹 Telegram бот: @$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)"
    echo -e "🔹 Статус: ${GREEN}systemctl status jarvis-bot${NC}"
    echo -e "🔹 Логи: ${GREEN}journalctl -u jarvis-bot -f${NC}"
    echo -e "🔹 Управление: ${GREEN}$0${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause
}

# ============================================
# МЕНЮ УПРАВЛЕНИЯ
# ============================================
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                                    🦞 ${CYAN}${BOLD}ДЖАРВИС 4.0${NC} 🦞                                      ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                                                                                    ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                        ${YELLOW}✨ Передай привеД ПОТАПу !!! ✨${NC}                           ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN} 1)${NC}  Установить/переустановить Джарвиса"
    echo -e "  ${RED} 2)${NC}  Полное удаление"
    echo ""
    echo -e "  ${YELLOW} 3)${NC}  Изменить Telegram токен"
    echo -e "  ${YELLOW} 4)${NC}  Изменить модель (44+ вариантов)"
    echo ""
    echo -e "  ${BLUE} 5)${NC}  Добавить пользователя"
    echo -e "  ${BLUE} 6)${NC}  Удалить пользователя"
    echo ""
    echo -e "  ${CYAN} 7)${NC}  Показать конфигурацию"
    echo -e "  ${CYAN} 8)${NC}  Перезапустить бота"
    echo -e "  ${CYAN} 9)${NC}  Остановить бота"
    echo -e "  ${CYAN}10)${NC}  Запустить бота"
    echo -e "  ${CYAN}11)${NC}  Статус бота"
    echo -e "  ${CYAN}12)${NC}  Показать логи"
    echo ""
    echo -e "  ${RED} 0)${NC}  Выход"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Выберите действие: " choice
}

# ============================================
# ОСНОВНАЯ ПРОГРАММА
# ============================================
if [ ! -f "$CONFIG_FILE" ] && [ ! -f "$BOT_SCRIPT" ]; then
    install_jarvis
    exit 0
fi

while true; do
    show_menu
    case $choice in
        1) install_jarvis ;;
        2) 
            systemctl stop jarvis-bot 2>/dev/null
            systemctl disable jarvis-bot 2>/dev/null
            rm -rf $JARVIS_DIR $SERVICE_FILE
            systemctl daemon-reload
            print_success "Джарвис удалён"
            pause
            ;;
        3)
            read -p "Новый токен: " NEW_TOKEN
            sed -i "s/BOT_TOKEN=.*/BOT_TOKEN=\"$NEW_TOKEN\"/" $CONFIG_FILE
            systemctl restart jarvis-bot
            print_success "Токен обновлён"
            pause
            ;;
        4)
            echo ""
            read -p "👉 Название модели: " NEW_MODEL
            if [ -n "$NEW_MODEL" ]; then
                print_info "Скачивание $NEW_MODEL..."
                ollama pull "$NEW_MODEL"
                sed -i "s/MODEL=.*/MODEL=\"$NEW_MODEL\"/" $CONFIG_FILE
                systemctl restart jarvis-bot
                print_success "Модель изменена на $NEW_MODEL"
            fi
            pause
            ;;
        5)
            read -p "👉 Chat ID нового пользователя: " NEW_USER
            CURRENT=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
            sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$CURRENT $NEW_USER\"/" $CONFIG_FILE
            systemctl restart jarvis-bot
            print_success "Пользователь добавлен"
            pause
            ;;
        6)
            CURRENT=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
            echo -e "${YELLOW}Текущие пользователи:${NC} $CURRENT"
            read -p "👉 Chat ID для удаления: " REMOVE
            NEW=$(echo "$CURRENT" | sed "s/$REMOVE//g" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
            sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$NEW\"/" $CONFIG_FILE
            systemctl restart jarvis-bot
            print_success "Пользователь удалён"
            pause
            ;;
        7) cat $CONFIG_FILE 2>/dev/null; pause ;;
        8) systemctl restart jarvis-bot && print_success "Бот перезапущен"; pause ;;
        9) systemctl stop jarvis-bot && print_success "Бот остановлен"; pause ;;
        10) systemctl start jarvis-bot && print_success "Бот запущен"; pause ;;
        11) systemctl status jarvis-bot; pause ;;
        12) journalctl -u jarvis-bot -f ;;
        0) exit 0 ;;
        *) print_warning "Неверный выбор"; pause ;;
    esac
done
