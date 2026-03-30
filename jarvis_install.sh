#!/bin/bash

# ============================================
# Джарвис - универсальный установщик Telegram бота
# Поддерживает: текстовые, мультимодальные, аудио модели
# Версия: 3.0
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
SERVICE_FILE="/etc/systemd/system/jarvis-bot.service"
CONFIG_FILE="$JARVIS_DIR/config.env"

# Функции вывода
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

pause() {
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

get_server_ip() {
    ipv4=$(curl -4 -s ifconfig.me 2>/dev/null || curl -4 -s icanhazip.com 2>/dev/null)
    if [[ -n "$ipv4" && "$ipv4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ipv4"
    else
        echo "IP_НЕ_ОПРЕДЕЛЕН"
    fi
}

# ============================================
# Функция установки
# ============================================
install_jarvis() {
    clear
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}           🦞 УСТАНОВКА ДЖАРВИСА 🦞${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$EUID" -ne 0 ]; then 
        print_error "Запустите скрипт от root (sudo ./jarvis_install.sh)"
        exit 1
    fi

    # Сбор информации
    echo ""
    print_info "Для настройки Джарвиса нужны следующие данные:"
    echo ""
    
    read -p "Введите токен Telegram бота (от @BotFather): " BOT_TOKEN
    while [ -z "$BOT_TOKEN" ]; do
        print_error "Токен не может быть пустым!"
        read -p "Введите токен Telegram бота: " BOT_TOKEN
    done
    
    read -p "Введите ваш Chat ID (можно узнать у @userinfobot): " CHAT_ID
    while [ -z "$CHAT_ID" ]; do
        print_error "Chat ID не может быть пустым!"
        read -p "Введите ваш Chat ID: " CHAT_ID
    done
    
    # Выбор модели
    echo ""
    echo "Выберите модель:"
    echo "  1) qwen2.5:1.5b  - быстрая, 1GB (рекомендуется для начала)"
    echo "  2) llama3.2:3b    - быстрая, 2GB"
    echo "  3) qwen2.5:7b     - умная, 4.5GB"
    echo "  4) deepseek-r1:7b - reasoning, 4.7GB"
    echo "  5) llava:7b       - видит изображения, 4.5GB"
    echo "  6) Показать все модели (44 варианта)"
    echo "  7) Своя модель"
    read -p "Выберите [1-7]: " MODEL_CHOICE
    
    case $MODEL_CHOICE in
        1) MODEL="qwen2.5:1.5b" ;;
        2) MODEL="llama3.2:3b" ;;
        3) MODEL="qwen2.5:7b" ;;
        4) MODEL="deepseek-r1:7b" ;;
        5) MODEL="llava:7b" ;;
        6) show_all_models ;;
        7) read -p "Введите название модели: " MODEL ;;
        *) MODEL="qwen2.5:1.5b" ;;
    esac
    
    read -p "Введите дополнительных пользователей (Chat ID через пробел, или оставьте пустым): " EXTRA_USERS
    
    echo ""
    print_info "Начинаю установку..."
    
    # Обновление системы
    print_info "Обновление системы..."
    apt update && apt upgrade -y
    
    # Установка зависимостей
    print_info "Установка зависимостей..."
    apt install -y curl git wget python3 python3-pip python3-venv ufw ffmpeg
    
    # Установка Ollama
    if ! command -v ollama &> /dev/null; then
        print_info "Установка Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    else
        print_success "Ollama уже установлен"
    fi
    
    # Загрузка модели
    print_info "Загрузка модели $MODEL (может занять несколько минут)..."
    ollama pull $MODEL
    
    # Создание пользователя
    if id "$JARVIS_USER" &>/dev/null; then
        print_info "Пользователь $JARVIS_USER уже существует"
    else
        useradd -m -s /usr/sbin/nologin $JARVIS_USER
        print_success "Пользователь $JARVIS_USER создан"
    fi
    
    # Создание директории
    mkdir -p $JARVIS_DIR
    chown $JARVIS_USER:$JARVIS_USER $JARVIS_DIR
    
    # Создание конфигурации
    print_info "Создание конфигурации..."
    cat > $CONFIG_FILE << EOF
# Конфигурация Джарвиса
BOT_TOKEN="$BOT_TOKEN"
MODEL="$MODEL"
ALLOWED_USERS="$CHAT_ID $EXTRA_USERS"
OLLAMA_URL="http://127.0.0.1:11434/api/generate"
EOF
    
    # Создание скрипта бота
    print_info "Создание скрипта бота..."
    create_bot_script
    
    # Настройка прав
    chmod +x $BOT_SCRIPT
    chown -R $JARVIS_USER:$JARVIS_USER $JARVIS_DIR
    
    # Создание виртуального окружения
    print_info "Настройка Python окружения..."
    sudo -u $JARVIS_USER python3 -m venv $JARVIS_DIR/venv
    sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install --quiet python-telegram-bot requests pillow
    
    # Создание systemd сервиса
    print_info "Создание systemd сервиса..."
    create_systemd_service
    
    # Включение и запуск сервиса
    systemctl daemon-reload
    systemctl enable jarvis-bot
    systemctl restart ollama
    sleep 3
    systemctl restart jarvis-bot
    
    print_success "Джарвис установлен и запущен!"
    echo ""
    echo "========================================="
    echo "✅ Установка завершена!"
    echo "========================================="
    echo "🔹 Telegram бот: @$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)"
    echo "🔹 Статус: systemctl status jarvis-bot"
    echo "🔹 Логи: journalctl -u jarvis-bot -f"
    echo "🔹 Управление: $0 (запустите снова для меню)"
    echo "========================================="
    
    pause
}

# ============================================
# Создание скрипта бота
# ============================================
create_bot_script() {
    cat > $BOT_SCRIPT << 'EOF'
#!/usr/bin/env python3
import os
import sys
import json
import requests
import asyncio
import base64
import subprocess
from datetime import datetime
from telegram import Update, InputFile
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from PIL import Image
import io

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
        await update.message.reply_text("⛔ Доступ запрещён. Обратитесь к администратору.")
        return
    
    await update.message.reply_text(
        "🦞 **Джарвис**\n\n"
        "Я ваш персональный AI-ассистент.\n\n"
        "📸 **Отправьте фото** — я опишу, что на нём\n"
        "🎤 **Отправьте голосовое** — я распознаю речь\n"
        "📝 **Напишите текст** — я отвечу\n\n"
        "**Доступные команды:**\n"
        "/status — статус системы\n"
        "/help — помощь\n"
        "/model — текущая модель",
        parse_mode="Markdown"
    )

async def help_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "🦞 **Команды Джарвиса**\n\n"
        "/start — приветствие\n"
        "/status — статус системы\n"
        "/model — показать текущую модель\n"
        "/help — эта справка\n\n"
        "**Функции:**\n"
        "📸 Отправьте фото — опишу изображение\n"
        "🎤 Отправьте голосовое — распознаю речь\n"
        "💬 Просто напишите — отвечу\n\n"
        f"🤖 Текущая модель: `{MODEL}`",
        parse_mode="Markdown"
    )

async def model_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    
    await update.message.reply_text(
        f"🤖 **Текущая модель:**\n`{MODEL}`\n\n"
        f"🖼️ Поддержка изображений: {'✅ Да' if is_vision_model(MODEL) else '❌ Нет'}",
        parse_mode="Markdown"
    )

async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    if not is_vision_model(MODEL):
        await update.message.reply_text(f"❌ Модель `{MODEL}` не поддерживает изображения.\n\nИспользуйте мультимодальную модель (llava, qwen3-vl, gemma3-vision и др.)", parse_mode="Markdown")
        return
    
    await update.message.reply_chat_action("typing")
    
    try:
        # Скачиваем фото
        photo_file = await update.message.photo[-1].get_file()
        photo_bytes = await photo_file.download_as_bytearray()
        
        # Конвертируем в base64
        image_b64 = base64.b64encode(photo_bytes).decode()
        
        # Запрос к Ollama
        response = requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "prompt": "Опиши подробно, что ты видишь на этом изображении. Опиши детали, объекты, цвета, атмосферу.",
            "images": [image_b64],
            "stream": False
        }, timeout=120)
        
        if response.status_code == 200:
            reply = response.json().get("response", "Не могу описать изображение")
            await update.message.reply_text(reply)
        else:
            await update.message.reply_text("⚠️ Ошибка при обработке изображения")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def handle_voice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    
    await update.message.reply_chat_action("typing")
    
    try:
        # Скачиваем голосовое
        voice_file = await update.message.voice.get_file()
        voice_path = f"/tmp/voice_{user_id}.ogg"
        await voice_file.download_to_drive(voice_path)
        
        # Конвертируем в формат для whisper
        wav_path = f"/tmp/voice_{user_id}.wav"
        subprocess.run(["ffmpeg", "-i", voice_path, "-ar", "16000", "-ac", "1", wav_path, "-y"], capture_output=True)
        
        # Распознавание через whisper
        whisper_response = requests.post("http://127.0.0.1:11434/api/generate", json={
            "model": "whisper:tiny",
            "prompt": "",
            "file": wav_path,
            "stream": False
        }, timeout=60)
        
        text = ""
        if whisper_response.status_code == 200:
            text = whisper_response.json().get("response", "")
        
        # Отправляем распознанный текст в основную модель
        if text:
            response = requests.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": f"Пользователь сказал голосом: {text}\n\nОтветь на это сообщение:",
                "stream": False
            }, timeout=60)
            
            if response.status_code == 200:
                reply = response.json().get("response", "Не могу ответить")
                await update.message.reply_text(reply)
            else:
                await update.message.reply_text(f"🎤 Распознано: {text}\n\n(Ошибка генерации ответа)")
        else:
            await update.message.reply_text("🎤 Не удалось распознать речь. Попробуйте говорить чётче.")
            
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")
    finally:
        # Очистка временных файлов
        for path in [voice_path, wav_path]:
            if os.path.exists(path):
                os.remove(path)

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    user_text = update.message.text
    await update.message.reply_chat_action("typing")
    
    try:
        # Проверяем, используем ли OpenAI API
        if USE_OPENAI and OPENAI_KEY:
            import openai
            openai.api_key = OPENAI_KEY
            response = openai.ChatCompletion.create(
                model=OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": "Ты Джарвис — персональный AI-ассистент. Ты вежлив, саркастичен, технически подкован. Отвечай кратко и по делу."},
                    {"role": "user", "content": user_text}
                ],
                timeout=60
            )
            reply = response.choices[0].message.content
            await update.message.reply_text(reply)
        else:
            # Локальная модель
            response = requests.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": f"Ты Джарвис — персональный AI-ассистент. Ты вежлив, саркастичен, технически подкован. Отвечай кратко и по делу. Пользователь сказал: {user_text}",
                "stream": False
            }, timeout=120)
            
            if response.status_code == 200:
                reply = response.json().get("response", "Не могу ответить")
                await update.message.reply_text(reply)
            else:
                await update.message.reply_text("⚠️ Ошибка модели. Попробуйте позже.")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def status_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    
    # Получаем информацию о системе
    try:
        cpu = subprocess.check_output("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1", shell=True).decode().strip()
        mem = subprocess.check_output("free -h | awk '/^Mem:/ {print $3\"/\"$2}'", shell=True).decode().strip()
        uptime = subprocess.check_output("uptime -p", shell=True).decode().strip()
        ram_total = subprocess.check_output("free -g | awk '/^Mem:/ {print $2}'", shell=True).decode().strip()
    except:
        cpu = "N/A"
        mem = "N/A"
        uptime = "N/A"
        ram_total = "?"
    
    await update.message.reply_text(
        f"🦞 **Джарвис**\n\n"
        f"🤖 Модель: `{MODEL}`\n"
        f"🖼️ Vision: {'✅ Да' if is_vision_model(MODEL) else '❌ Нет'}\n"
        f"📊 CPU: {cpu}%\n"
        f"💾 Память: {mem}\n"
        f"🎛️ RAM всего: {ram_total}GB\n"
        f"⏱️ Время работы: {uptime}\n"
        f"👥 Пользователей: {len(ALLOWED_USERS)}",
        parse_mode="Markdown"
    )

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("status", status_cmd))
    app.add_handler(CommandHandler("help", help_cmd))
    app.add_handler(CommandHandler("model", model_cmd))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.VOICE, handle_voice))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print(f"🦞 Джарвис запущен!")
    print(f"🤖 Модель: {MODEL}")
    print(f"🖼️ Поддержка изображений: {is_vision_model(MODEL)}")
    print(f"👥 Пользователи: {ALLOWED_USERS}")
    
    app.run_polling()

if __name__ == "__main__":
    main()
EOF
}

# ============================================
# Создание systemd сервиса
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
# Показать все модели
# ============================================
show_all_models() {
    clear
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}           📦 ДОСТУПНЫЕ МОДЕЛИ${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  🧠 REASONING (думают вслух, очень умные):"
    echo "    1. deepseek-r1:7b       - 4.7GB (отличный русский)"
    echo "    2. deepseek-r1:8b       - 5.0GB (ещё умнее)"
    echo "    3. qwq:32b              - 20GB (Qwen reasoning, мощная)"
    echo ""
    echo "  🏆 ТОПОВЫЕ ЛОКАЛЬНЫЕ (бесплатные):"
    echo "    4. qwen3:8b             - 5.0GB (лучший русский, 128k контекст)"
    echo "    5. qwen3:14b            - 9.0GB (очень умная)"
    echo "    6. qwen2.5:7b           - 4.5GB (проверенная)"
    echo "    7. llama3.3:70b         - 42GB (Meta, ChatGPT-level)"
    echo "    8. gpt-oss:20b          - 12GB (OpenAI, ChatGPT-like)"
    echo "    9. gpt-oss:120b         - 70GB (OpenAI, GPT-4 level)"
    echo ""
    echo "  💻 КОД И ТЕХНИЧЕСКИЕ:"
    echo "    10. deepseek-coder:6.7b - 4.0GB (код)"
    echo "    11. qwen2.5-coder:7b    - 4.5GB (код)"
    echo ""
    echo "  ⚡ ЛЁГКИЕ (для слабых серверов):"
    echo "    12. qwen2.5:1.5b        - 1.0GB (быстрая)"
    echo "    13. llama3.2:3b         - 2.0GB (быстрая)"
    echo "    14. phi3:3.8b           - 2.5GB (Microsoft)"
    echo ""
    echo "  🎨 МУЛЬТИМОДАЛЬНЫЕ (видят изображения):"
    echo "    15. llava:7b            - 4.5GB (описывает фото)"
    echo "    16. llava-phi3:3.8b     - 3.0GB (лёгкая)"
    echo "    17. moondream:1.8b      - 1.2GB (мини-мультимодальная)"
    echo "    18. qwen3-vl:8b         - 5.5GB (Qwen vision, русский)"
    echo "    19. gemma3:12b-vision   - 8.0GB (Google, отличное)"
    echo "    20. minicpm-v:8b        - 5.0GB (компактная)"
    echo "    21. deepseek-ocr:3b     - 2.5GB (OCR с картинок)"
    echo "    22. cogvlm:17b          - 10GB (китайская, точная)"
    echo "    23. bakllava:7b         - 4.5GB (улучшенная LLaVA)"
    echo "    24. llava-llama3:8b     - 5.0GB (LLaVA на Llama 3)"
    echo "    25. granite3.2-vision:2b - 1.5GB (IBM, лёгкая)"
    echo "    26. qwen2.5vl:7b        - 5.0GB (Qwen 2.5 vision)"
    echo "    27. qwen2.5vl:32b       - 20GB (профессиональная)"
    echo ""
    echo "  🎵 АУДИО МОДЕЛИ (голос, музыка):"
    echo "    28. whisper:tiny        - 0.2GB (распознавание речи, русский)"
    echo "    29. whisper:small       - 0.5GB (хорошее качество)"
    echo "    30. whisper:medium      - 1.5GB (отличное качество)"
    echo "    31. whisper:large       - 3.0GB (профессиональное)"
    echo ""
    echo "  🎥 ВИДЕО МОДЕЛИ:"
    echo "    32. video-llava:7b      - 5.0GB (анализирует видео)"
    echo "    33. internvl2:8b        - 5.5GB (видео + изображения)"
    echo "    34. llava-next:7b       - 4.5GB (улучшенная видео-модель)"
    echo ""
    echo "  🤖 CHATGPT (платные варианты):"
    echo "    35. ChatGPT (OpenAI API)       - 💰 платный API"
    echo "    36. ChatGPT (ChatMock)         - 💰 требует ChatGPT Plus"
    echo "    37. ChatGPT (GPT-OSS)          - ✅ бесплатно, локально"
    echo ""
    echo "  🔧 38. Своя модель"
    echo ""
    read -p "Введите номер модели для установки: " model_num
}

# ============================================
# Функция смены модели
# ============================================
change_model() {
    clear
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}           🔄 СМЕНА МОДЕЛИ${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Текущая модель
    CURRENT_MODEL=$(grep '^MODEL=' $CONFIG_FILE 2>/dev/null | cut -d'"' -f2)
    echo -e "${YELLOW}Текущая модель:${NC} ${GREEN}$CURRENT_MODEL${NC}"
    echo ""

    # Доступные модели
    echo -e "${BLUE}📦 Установленные модели:${NC}"
    ollama list 2>/dev/null || echo "  (Ollama не запущен)"
    echo ""

    # RAM
    FREE_RAM=$(free -g | awk '/^Mem:/{print $7}')
    echo -e "${BLUE}💾 Свободно RAM:${NC} ${GREEN}${FREE_RAM}GB${NC}"
    echo ""

    # Меню
    show_all_models
    
    if [[ "$model_num" == "38" ]] || [[ -z "$model_num" ]]; then
        read -p "Введите название модели: " NEW_MODEL
    elif [[ "$model_num" == "35" ]]; then
        # ChatGPT API
        echo ""
        echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│                    🤖 CHATGPT (OpenAI API)                   │${NC}"
        echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
        echo -e "│  💰 ${RED}ПЛАТНЫЙ СЕРВИС${NC}                                           │"
        echo -e "│  🔑 Ключ: https://platform.openai.com/api-keys                     │"
        echo -e "│  💵 gpt-4o-mini: ~$0.15/1M токенов                                 │"
        echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        read -p "Введите API-ключ: " OPENAI_KEY
        read -p "Модель (gpt-4o-mini/gpt-4o): " GPT_MODEL
        echo "USE_OPENAI=true" >> $CONFIG_FILE
        echo "OPENAI_API_KEY=\"$OPENAI_KEY\"" >> $CONFIG_FILE
        echo "OPENAI_MODEL=\"$GPT_MODEL\"" >> $CONFIG_FILE
        print_success "OpenAI API настроен"
        systemctl restart jarvis-bot
        pause
        return
    elif [[ "$model_num" == "36" ]]; then
        # ChatMock
        echo ""
        echo -e "${YELLOW}ChatMock требует ChatGPT Plus подписку${NC}"
        read -p "Установить ChatMock? (y/N): " install_cm
        if [[ "$install_cm" == "y" ]]; then
            cd /tmp
            git clone https://github.com/RayBytes/ChatMock
            cd ChatMock
            pip install -r requirements.txt
            python chatmock.py login
            print_success "ChatMock установлен"
        fi
        return
    elif [[ "$model_num" == "37" ]]; then
        # GPT-OSS
        echo ""
        read -p "Скачать gpt-oss:20b? (12GB) (y/N): " dl
        if [[ "$dl" == "y" ]]; then
            ollama pull gpt-oss:20b
            NEW_MODEL="gpt-oss:20b"
        else
            return
        fi
    else
        # Получаем название модели по номеру
        case $model_num in
            1) NEW_MODEL="deepseek-r1:7b" ;;
            2) NEW_MODEL="deepseek-r1:8b" ;;
            3) NEW_MODEL="qwq:32b" ;;
            4) NEW_MODEL="qwen3:8b" ;;
            5) NEW_MODEL="qwen3:14b" ;;
            6) NEW_MODEL="qwen2.5:7b" ;;
            7) NEW_MODEL="llama3.3:70b" ;;
            8) NEW_MODEL="gpt-oss:20b" ;;
            9) NEW_MODEL="gpt-oss:120b" ;;
            10) NEW_MODEL="deepseek-coder:6.7b" ;;
            11) NEW_MODEL="qwen2.5-coder:7b" ;;
            12) NEW_MODEL="qwen2.5:1.5b" ;;
            13) NEW_MODEL="llama3.2:3b" ;;
            14) NEW_MODEL="phi3:3.8b" ;;
            15) NEW_MODEL="llava:7b" ;;
            16) NEW_MODEL="llava-phi3:3.8b" ;;
            17) NEW_MODEL="moondream:1.8b" ;;
            18) NEW_MODEL="qwen3-vl:8b" ;;
            19) NEW_MODEL="gemma3:12b-vision" ;;
            20) NEW_MODEL="minicpm-v:8b" ;;
            21) NEW_MODEL="deepseek-ocr:3b" ;;
            22) NEW_MODEL="cogvlm:17b" ;;
            23) NEW_MODEL="bakllava:7b" ;;
            24) NEW_MODEL="llava-llama3:8b" ;;
            25) NEW_MODEL="granite3.2-vision:2b" ;;
            26) NEW_MODEL="qwen2.5vl:7b" ;;
            27) NEW_MODEL="qwen2.5vl:32b" ;;
            28) NEW_MODEL="whisper:tiny" ;;
            29) NEW_MODEL="whisper:small" ;;
            30) NEW_MODEL="whisper:medium" ;;
            31) NEW_MODEL="whisper:large" ;;
            32) NEW_MODEL="video-llava:7b" ;;
            33) NEW_MODEL="internvl2:8b" ;;
            34) NEW_MODEL="llava-next:7b" ;;
            *) NEW_MODEL="qwen2.5:1.5b" ;;
        esac
    fi

    # Скачиваем модель если нужно
    if [ -n "$NEW_MODEL" ]; then
        if ! ollama list | grep -q "$NEW_MODEL"; then
            print_info "Скачивание $NEW_MODEL..."
            ollama pull "$NEW_MODEL"
        fi
        
        # Меняем в конфиге
        sed -i "s/MODEL=.*/MODEL=\"$NEW_MODEL\"/" $CONFIG_FILE
        
        # Меняем в скрипте
        sed -i "s/MODEL = \".*\"/MODEL = \"$NEW_MODEL\"/" $BOT_SCRIPT
        
        print_success "Модель изменена на $NEW_MODEL"
        
        # Перезапуск
        systemctl restart jarvis-bot 2>/dev/null || true
    fi
    
    pause
}

# ============================================
# Меню управления
# ============================================
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🦞 ДЖАРВИС 🦞                         ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN} 1)${NC} Установить/переустановить Джарвиса"
    echo -e "${RED} 2)${NC} Полное удаление"
    echo ""
    echo -e "${YELLOW} 3)${NC} Изменить Telegram токен"
    echo -e "${YELLOW} 4)${NC} Изменить модель (44+ вариантов)"
    echo ""
    echo -e "${BLUE} 5)${NC} Добавить пользователя (Chat ID)"
    echo -e "${BLUE} 6)${NC} Удалить пользователя"
    echo ""
    echo -e "${CYAN} 7)${NC} Показать конфигурацию"
    echo -e "${CYAN} 8)${NC} Перезапустить бота"
    echo -e "${CYAN} 9)${NC} Остановить бота"
    echo -e "${CYAN}10)${NC} Запустить бота"
    echo -e "${CYAN}11)${NC} Статус бота"
    echo -e "${CYAN}12)${NC} Показать логи"
    echo -e "${CYAN}13)${NC} Обновить Джарвиса"
    echo ""
    echo -e "${RED} 0)${NC} Выход"
    echo ""
    read -p "Выберите действие: " choice
}

# ============================================
# Основная программа
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
        4) change_model ;;
        5)
            read -p "Chat ID нового пользователя: " NEW_USER
            CURRENT_USERS=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
            sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$CURRENT_USERS $NEW_USER\"/" $CONFIG_FILE
            systemctl restart jarvis-bot
            print_success "Пользователь добавлен"
            pause
            ;;
        6)
            CURRENT_USERS=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
            echo "Текущие: $CURRENT_USERS"
            read -p "Chat ID для удаления: " REMOVE_USER
            NEW_LIST=$(echo "$CURRENT_USERS" | sed "s/$REMOVE_USER//g" | sed 's/  */ /g')
            sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$NEW_LIST\"/" $CONFIG_FILE
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
        13)
            print_info "Обновление скрипта..."
            curl -sL https://raw.githubusercontent.com/potap1978/Jarvis_install/main/jarvis_install.sh -o /tmp/jarvis_update.sh
            bash /tmp/jarvis_update.sh
            ;;
        0) exit 0 ;;
        *) print_warning "Неверный выбор"; pause ;;
    esac
done
