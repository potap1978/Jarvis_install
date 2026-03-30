#!/bin/bash

# ============================================
# Джарвис - установщик Telegram бота с Ollama
# ============================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции вывода
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Файлы конфигурации
JARVIS_DIR="/opt/jarvis"
JARVIS_USER="jarvis"
BOT_SCRIPT="$JARVIS_DIR/jarvis_bot.py"
SERVICE_FILE="/etc/systemd/system/jarvis-bot.service"
CONFIG_FILE="$JARVIS_DIR/config.env"

# ============================================
# Функция меню управления
# ============================================
show_menu() {
    echo ""
    echo "========================================="
    echo "        🦞 ДЖАРВИС - МЕНЮ УПРАВЛЕНИЯ"
    echo "========================================="
    echo "1. Установить/переустановить Джарвиса"
    echo "2. Изменить Telegram токен"
    echo "3. Изменить модель Ollama"
    echo "4. Добавить/удалить пользователя (Chat ID)"
    echo "5. Показать текущую конфигурацию"
    echo "6. Перезапустить бота"
    echo "7. Остановить бота"
    echo "8. Запустить бота"
    echo "9. Показать статус бота"
    echo "10. Показать логи"
    echo "11. Обновить Джарвиса (новые функции)"
    echo "0. Выход"
    echo "========================================="
}

# ============================================
# Функция установки
# ============================================
install_jarvis() {
    clear
    echo "========================================="
    echo "     🦞 УСТАНОВКА ДЖАРВИСА 🦞"
    echo "========================================="
    
    # Проверка root
    if [ "$EUID" -ne 0 ]; then 
        print_error "Запустите скрипт от root (sudo ./jarvis.sh)"
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
    
    echo ""
    echo "Выберите модель Ollama (рекомендуется qwen2.5):"
    echo "1. qwen2.5:1.5b (быстрая, 1.5GB)"
    echo "2. qwen2.5:7b (умнее, 4.5GB)"
    echo "3. llama3.2:3b (средняя, 2GB)"
    echo "4. mistral:7b (мощная, 4GB)"
    echo "5. Ввести свою модель"
    read -p "Выберите [1-5]: " MODEL_CHOICE
    
    case $MODEL_CHOICE in
        1) MODEL="qwen2.5:1.5b" ;;
        2) MODEL="qwen2.5:7b" ;;
        3) MODEL="llama3.2:3b" ;;
        4) MODEL="mistral:7b" ;;
        5) read -p "Введите название модели: " MODEL ;;
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
    apt install -y curl git wget python3 python3-pip python3-venv ufw
    
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
    cat > $BOT_SCRIPT << 'EOF'
#!/usr/bin/env python3
import os
import sys
import json
import requests
import asyncio
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

# Загрузка конфигурации
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

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён. Обратитесь к администратору.")
        return
    await update.message.reply_text("🦞 Джарвис готов. Чем могу помочь?")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    user_text = update.message.text
    await update.message.reply_chat_action("typing")
    
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "prompt": f"Ты Джарвис — персональный AI-ассистент. Ты вежлив, саркастичен, технически подкован. Отвечай кратко и по делу. Пользователь сказал: {user_text}",
            "stream": False
        }, timeout=60)
        
        if response.status_code == 200:
            reply = response.json().get("response", "Не могу ответить")
            await update.message.reply_text(reply)
        else:
            await update.message.reply_text("⚠️ Ошибка модели. Попробуйте позже.")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")

async def add_user(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    if not context.args:
        await update.message.reply_text("Использование: /adduser CHAT_ID")
        return
    
    new_user = context.args[0]
    if new_user in ALLOWED_USERS:
        await update.message.reply_text(f"Пользователь {new_user} уже в списке.")
        return
    
    # Обновление конфига
    try:
        with open(CONFIG_FILE, 'r') as f:
            lines = f.readlines()
        
        with open(CONFIG_FILE, 'w') as f:
            for line in lines:
                if line.startswith("ALLOWED_USERS="):
                    f.write(f'ALLOWED_USERS="{ " ".join(ALLOWED_USERS + [new_user]) }"\n')
                else:
                    f.write(line)
        
        await update.message.reply_text(f"✅ Пользователь {new_user} добавлен. Перезапустите бота для применения.")
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {e}")

async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    await update.message.reply_text(
        f"🦞 **Джарвис**\n"
        f"🤖 Модель: `{MODEL}`\n"
        f"👥 Пользователей: {len(ALLOWED_USERS)}\n"
        f"✅ Статус: активен",
        parse_mode="Markdown"
    )

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("adduser", add_user))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print("🦞 Джарвис запущен!")
    print(f"🤖 Модель: {MODEL}")
    print(f"👥 Разрешённые пользователи: {ALLOWED_USERS}")
    
    app.run_polling()

if __name__ == "__main__":
    main()
EOF
    
    # Настройка прав
    chmod +x $BOT_SCRIPT
    chown -R $JARVIS_USER:$JARVIS_USER $JARVIS_DIR
    
    # Создание виртуального окружения
    print_info "Настройка Python окружения..."
    sudo -u $JARVIS_USER python3 -m venv $JARVIS_DIR/venv
    sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install --quiet python-telegram-bot requests
    
    # Создание systemd сервиса
    print_info "Создание systemd сервиса..."
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
    
    # Включение и запуск сервиса
    systemctl daemon-reload
    systemctl enable jarvis-bot
    systemctl restart ollama
    sleep 2
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
}

# ============================================
# Функция изменения токена
# ============================================
change_token() {
    read -p "Введите новый токен Telegram бота: " NEW_TOKEN
    if [ -z "$NEW_TOKEN" ]; then
        print_error "Токен не может быть пустым"
        return
    fi
    
    sed -i "s/BOT_TOKEN=.*/BOT_TOKEN=\"$NEW_TOKEN\"/" $CONFIG_FILE
    systemctl restart jarvis-bot
    print_success "Токен обновлён, бот перезапущен"
}

# ============================================
# Функция изменения модели
# ============================================
change_model() {
    echo "Выберите модель:"
    echo "1. qwen2.5:1.5b"
    echo "2. qwen2.5:7b"
    echo "3. llama3.2:3b"
    echo "4. mistral:7b"
    echo "5. Ввести свою"
    read -p "Выберите [1-5]: " MODEL_CHOICE
    
    case $MODEL_CHOICE in
        1) MODEL="qwen2.5:1.5b" ;;
        2) MODEL="qwen2.5:7b" ;;
        3) MODEL="llama3.2:3b" ;;
        4) MODEL="mistral:7b" ;;
        5) read -p "Введите название модели: " MODEL ;;
        *) MODEL="qwen2.5:1.5b" ;;
    esac
    
    print_info "Загрузка модели $MODEL..."
    ollama pull $MODEL
    
    sed -i "s/MODEL=.*/MODEL=\"$MODEL\"/" $CONFIG_FILE
    systemctl restart jarvis-bot
    print_success "Модель изменена на $MODEL"
}

# ============================================
# Функция добавления пользователя
# ============================================
add_user() {
    read -p "Введите Chat ID пользователя: " NEW_USER
    if [ -z "$NEW_USER" ]; then
        print_error "Chat ID не может быть пустым"
        return
    fi
    
    # Получаем текущих пользователей
    CURRENT_USERS=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
    
    if echo "$CURRENT_USERS" | grep -q "$NEW_USER"; then
        print_warning "Пользователь уже в списке"
        return
    fi
    
    NEW_LIST="$CURRENT_USERS $NEW_USER"
    sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$NEW_LIST\"/" $CONFIG_FILE
    
    systemctl restart jarvis-bot
    print_success "Пользователь $NEW_USER добавлен"
}

# ============================================
# Функция удаления пользователя
# ============================================
remove_user() {
    CURRENT_USERS=$(grep "^ALLOWED_USERS=" $CONFIG_FILE | sed 's/ALLOWED_USERS="//' | sed 's/"//')
    echo "Текущие пользователи: $CURRENT_USERS"
    read -p "Введите Chat ID для удаления: " REMOVE_USER
    
    NEW_LIST=$(echo "$CURRENT_USERS" | sed "s/$REMOVE_USER//g" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
    sed -i "s/ALLOWED_USERS=.*/ALLOWED_USERS=\"$NEW_LIST\"/" $CONFIG_FILE
    
    systemctl restart jarvis-bot
    print_success "Пользователь $REMOVE_USER удалён"
}

# ============================================
# Функция показа конфигурации
# ============================================
show_config() {
    echo ""
    echo "========== ТЕКУЩАЯ КОНФИГУРАЦИЯ =========="
    grep -v "^#" $CONFIG_FILE 2>/dev/null || echo "Файл конфигурации не найден"
    echo "========================================="
    echo ""
    echo "Статус бота:"
    systemctl is-active jarvis-bot
    echo ""
    echo "Статус Ollama:"
    systemctl is-active ollama
}

# ============================================
# Функция обновления
# ============================================
update_jarvis() {
    print_info "Обновление скрипта Джарвиса..."
    
    # Бэкап конфига
    cp $CONFIG_FILE $CONFIG_FILE.bak
    
    # Пересоздаём скрипт с новыми функциями
    cat > $BOT_SCRIPT << 'EOF'
#!/usr/bin/env python3
import os
import sys
import json
import requests
import asyncio
import subprocess
from datetime import datetime
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

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

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    await update.message.reply_text("🦞 Джарвис готов. Чем могу помочь?\n\nДоступные команды:\n/status - статус системы\n/help - помощь")

async def help_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "🦞 **Команды Джарвиса**\n\n"
        "/start - приветствие\n"
        "/status - статус системы\n"
        "/help - эта справка\n\n"
        "Просто напишите вопрос или задачу, и я постараюсь помочь!",
        parse_mode="Markdown"
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    user_text = update.message.text
    await update.message.reply_chat_action("typing")
    
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "prompt": f"Ты Джарвис — персональный AI-ассистент. Ты вежлив, саркастичен, технически подкован. Отвечай кратко и по делу. Пользователь сказал: {user_text}",
            "stream": False
        }, timeout=60)
        
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
        await update.message.reply_text("⛔ Доступ запрещён.")
        return
    
    # Получаем информацию о системе
    try:
        cpu = subprocess.check_output("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1", shell=True).decode().strip()
        mem = subprocess.check_output("free -h | awk '/^Mem:/ {print $3\"/\"$2}'", shell=True).decode().strip()
        uptime = subprocess.check_output("uptime -p", shell=True).decode().strip()
    except:
        cpu = "N/A"
        mem = "N/A"
        uptime = "N/A"
    
    await update.message.reply_text(
        f"🦞 **Джарвис**\n\n"
        f"🤖 Модель: `{MODEL}`\n"
        f"📊 CPU: {cpu}%\n"
        f"💾 Память: {mem}\n"
        f"⏱️ Время работы: {uptime}\n"
        f"👥 Пользователей: {len(ALLOWED_USERS)}",
        parse_mode="Markdown"
    )

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("status", status_cmd))
    app.add_handler(CommandHandler("help", help_cmd))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print("🦞 Джарвис запущен!")
    print(f"🤖 Модель: {MODEL}")
    print(f"👥 Пользователи: {ALLOWED_USERS}")
    
    app.run_polling()

if __name__ == "__main__":
    main()
EOF
    
    chown $JARVIS_USER:$JARVIS_USER $BOT_SCRIPT
    systemctl restart jarvis-bot
    
    print_success "Джарвис обновлён!"
}

# ============================================
# Основная программа
# ============================================
if [ ! -f "$CONFIG_FILE" ]; then
    echo ""
    echo "Джарвис не установлен. Начинаю установку..."
    install_jarvis
    exit 0
fi

while true; do
    show_menu
    read -p "Выберите действие [0-11]: " choice
    case $choice in
        1) install_jarvis ;;
        2) change_token ;;
        3) change_model ;;
        4) 
            echo "1. Добавить пользователя"
            echo "2. Удалить пользователя"
            read -p "Выберите: " sub
            if [ "$sub" = "1" ]; then add_user
            elif [ "$sub" = "2" ]; then remove_user
            else print_warning "Неверный выбор"; fi
            ;;
        5) show_config ;;
        6) systemctl restart jarvis-bot && print_success "Бот перезапущен" ;;
        7) systemctl stop jarvis-bot && print_success "Бот остановлен" ;;
        8) systemctl start jarvis-bot && print_success "Бот запущен" ;;
        9) systemctl status jarvis-bot ;;
        10) journalctl -u jarvis-bot -f ;;
        11) update_jarvis ;;
        0) print_info "Выход"; exit 0 ;;
        *) print_warning "Неверный выбор" ;;
    esac
    echo ""
    read -p "Нажмите Enter для продолжения..."
done
