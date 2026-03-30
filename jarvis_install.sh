#!/bin/bash

# ============================================
# Джарвис - универсальный установщик Telegram бота
# Версия: 4.0 - с поддержкой ClawHub навыков и настройкой времени
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
SKILLS_DIR="$JARVIS_DIR/skills"
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
    echo -e "  ${YELLOW}🧠 REASONING:${NC} 1.deepseek-r1:7b  2.deepseek-r1:8b  3.qwq:32b"
    echo -e "  ${YELLOW}🏆 ТОПОВЫЕ:${NC}     4.qwen3:8b       5.qwen3:14b      6.qwen2.5:7b"
    echo -e "  ${YELLOW}💻 КОД:${NC}         10.deepseek-coder:6.7b  11.qwen2.5-coder:7b"
    echo -e "  ${YELLOW}⚡ ЛЁГКИЕ:${NC}      12.qwen2.5:1.5b  13.llama3.2:3b   14.phi3:3.8b"
    echo -e "  ${YELLOW}🎨 МУЛЬТИМОДАЛЬНЫЕ:${NC} 15.llava:7b  16.llava-phi3:3.8b  17.moondream:1.8b  18.qwen3-vl:8b"
    echo -e "  ${YELLOW}🎵 АУДИО:${NC}       28.whisper:tiny  29.whisper:small  30.whisper:medium  31.whisper:large"
    echo -e "  ${YELLOW}🎥 ВИДЕО:${NC}       32.video-llava:7b  33.internvl2:8b  34.llava-next:7b"
    echo -e "  ${YELLOW}🤖 CHATGPT:${NC}     35.ChatGPT(API)  36.ChatMock  37.GPT-OSS"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================
# НАСТРОЙКА ВРЕМЕНИ И ЧАСОВОГО ПОЯСА
# ============================================
configure_time() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🕐 НАСТРОЙКА ВРЕМЕНИ И ЧАСОВОГО ПОЯСА                    ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Показываем текущее время и часовой пояс
    echo -e "${YELLOW}Текущее время на сервере:${NC} $(date)"
    echo -e "${YELLOW}Текущий часовой пояс:${NC} $(cat /etc/timezone 2>/dev/null || echo "не задан")"
    echo ""

    # Список популярных часовых поясов
    echo -e "${CYAN}Выберите часовой пояс:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) Europe/Moscow     (Москва, UTC+3)"
    echo -e "  ${GREEN}2${NC}) Europe/Kaliningrad (Калининград, UTC+2)"
    echo -e "  ${GREEN}3${NC}) Europe/Samara     (Самара, UTC+4)"
    echo -e "  ${GREEN}4${NC}) Asia/Yekaterinburg (Екатеринбург, UTC+5)"
    echo -e "  ${GREEN}5${NC}) Asia/Novosibirsk  (Новосибирск, UTC+7)"
    echo -e "  ${GREEN}6${NC}) Asia/Vladivostok  (Владивосток, UTC+10)"
    echo -e "  ${GREEN}7${NC}) Europe/London     (Лондон, UTC+0)"
    echo -e "  ${GREEN}8${NC}) America/New_York  (Нью-Йорк, UTC-4)"
    echo -e "  ${GREEN}9${NC}) Свой часовой пояс (введите в формате Continent/City)"
    echo -e "  ${GREEN}0${NC}) Пропустить (оставить текущий)"
    echo ""
    read -p "👉 Выберите [0-9]: " timezone_choice

    case $timezone_choice in
        1) TIMEZONE="Europe/Moscow" ;;
        2) TIMEZONE="Europe/Kaliningrad" ;;
        3) TIMEZONE="Europe/Samara" ;;
        4) TIMEZONE="Asia/Yekaterinburg" ;;
        5) TIMEZONE="Asia/Novosibirsk" ;;
        6) TIMEZONE="Asia/Vladivostok" ;;
        7) TIMEZONE="Europe/London" ;;
        8) TIMEZONE="America/New_York" ;;
        9) 
            echo ""
            read -p "👉 Введите часовой пояс (например: Asia/Tokyo): " TIMEZONE
            ;;
        0) 
            print_info "Часовой пояс не изменён"
            TIMEZONE=""
            ;;
        *) TIMEZONE="Europe/Moscow" ;;
    esac

    if [ -n "$TIMEZONE" ]; then
        print_info "Установка часового пояса: $TIMEZONE"
        timedatectl set-timezone $TIMEZONE 2>/dev/null || {
            print_warning "Не удалось установить через timedatectl, пробую через ln..."
            rm -f /etc/localtime
            ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
            echo "$TIMEZONE" > /etc/timezone
        }
        print_success "Часовой пояс установлен: $(date)"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Настройка синхронизации времени (NTP)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Проверка наличия NTP сервисов
    echo -e "${BLUE}Доступные NTP-серверы для синхронизации:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) pool.ntp.org           (стандартные серверы, автоматический выбор)"
    echo -e "  ${GREEN}2${NC}) ru.pool.ntp.org        (российские серверы)"
    echo -e "  ${GREEN}3${NC}) europe.pool.ntp.org    (европейские серверы)"
    echo -e "  ${GREEN}4${NC}) time.google.com        (серверы Google)"
    echo -e "  ${GREEN}5${NC}) time.cloudflare.com    (серверы Cloudflare)"
    echo -e "  ${GREEN}6${NC}) Свои серверы (введите через пробел)"
    echo -e "  ${GREEN}0${NC}) Пропустить (не настраивать синхронизацию)"
    echo ""
    read -p "👉 Выберите NTP-сервер [0-6]: " ntp_choice

    NTP_SERVERS=""
    case $ntp_choice in
        1) NTP_SERVERS="pool.ntp.org" ;;
        2) NTP_SERVERS="ru.pool.ntp.org" ;;
        3) NTP_SERVERS="europe.pool.ntp.org" ;;
        4) NTP_SERVERS="time.google.com" ;;
        5) NTP_SERVERS="time.cloudflare.com" ;;
        6) 
            echo ""
            read -p "👉 Введите NTP-серверы через пробел: " NTP_SERVERS
            ;;
        0) print_info "Синхронизация времени не настроена" ;;
        *) NTP_SERVERS="pool.ntp.org" ;;
    esac

    if [ -n "$NTP_SERVERS" ]; then
        print_info "Настройка синхронизации времени с $NTP_SERVERS..."
        
        # Установка chrony (современный NTP клиент)
        if ! command -v chronyc &> /dev/null; then
            print_info "Установка chrony..."
            apt install -y chrony
        fi
        
        # Настройка chrony
        if [ -f /etc/chrony/chrony.conf ]; then
            # Бэкап конфига
            cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
            
            # Очищаем старые серверы и добавляем новые
            sed -i '/^server /d' /etc/chrony/chrony.conf
            for server in $NTP_SERVERS; do
                echo "server $server iburst" >> /etc/chrony/chrony.conf
            done
            
            # Перезапуск chrony
            systemctl restart chrony
            sleep 2
            
            # Проверка синхронизации
            if chronyc tracking &>/dev/null; then
                print_success "Синхронизация времени настроена"
                echo ""
                chronyc sources -v
            else
                print_warning "Не удалось настроить chrony, пробую systemd-timesyncd..."
                
                # Альтернатива: systemd-timesyncd
                if command -v timedatectl &> /dev/null; then
                    timedatectl set-ntp true
                    for server in $NTP_SERVERS; do
                        echo "NTP=$server" >> /etc/systemd/timesyncd.conf
                    done
                    systemctl restart systemd-timesyncd
                    print_success "Синхронизация через systemd-timesyncd настроена"
                fi
            fi
        fi
    fi

    echo ""
    print_success "Настройка времени завершена!"
    echo -e "${YELLOW}Текущее время:${NC} $(date)"
    pause
}

# ============================================
# ВЫБОР ПРОВАЙДЕРОВ НАВЫКОВ
# ============================================
select_skills() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🧩 ВЫБОР ПРОВАЙДЕРОВ НАВЫКОВ                             ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Выберите провайдеров для подключения (можно несколько):"
    echo ""
    echo -e "  ${GREEN}[ ] 1. GOOGLE${NC}        - Gmail, Календарь, Контакты, Таблицы, Диск"
    echo -e "  ${GREEN}[ ] 2. ORACLE${NC}        - Базы данных, Object Storage, Compute"
    echo -e "  ${GREEN}[ ] 3. MICROSOFT${NC}     - Outlook, Teams, OneDrive, Календарь"
    echo -e "  ${GREEN}[ ] 4. AWS${NC}           - S3, EC2, Lambda, RDS"
    echo -e "  ${GREEN}[ ] 5. GITHUB${NC}        - Репозитории, Issues, PR"
    echo -e "  ${GREEN}[ ] 6. DOCKER/K8S${NC}    - Контейнеры, Kubernetes"
    echo -e "  ${GREEN}[ ] 7. TELEGRAM${NC}      - Управление ботом"
    echo -e "  ${GREEN}[ ] 8. WEATHER/NEWS${NC}  - Погода, новости"
    echo -e "  ${GREEN}[ ] 9. CRYPTO${NC}        - Курсы валют, криптовалюты"
    echo -e "  ${GREEN}[ ]10. SMART HOME${NC}    - Умный дом"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Введите номера через пробел (например: 1 5 8): " SKILLS_CHOICE
    
    SELECTED_SKILLS=""
    for num in $SKILLS_CHOICE; do
        case $num in
            1) SELECTED_SKILLS="$SELECTED_SKILLS google" ;;
            2) SELECTED_SKILLS="$SELECTED_SKILLS oracle" ;;
            3) SELECTED_SKILLS="$SELECTED_SKILLS microsoft" ;;
            4) SELECTED_SKILLS="$SELECTED_SKILLS aws" ;;
            5) SELECTED_SKILLS="$SELECTED_SKILLS github" ;;
            6) SELECTED_SKILLS="$SELECTED_SKILLS docker" ;;
            7) SELECTED_SKILLS="$SELECTED_SKILLS telegram" ;;
            8) SELECTED_SKILLS="$SELECTED_SKILLS weather" ;;
            9) SELECTED_SKILLS="$SELECTED_SKILLS crypto" ;;
            10) SELECTED_SKILLS="$SELECTED_SKILLS smarthome" ;;
        esac
    done
    
    # Базовые навыки всегда включены
    SELECTED_SKILLS="$SELECTED_SKILLS base"
    echo "$SELECTED_SKILLS" > /tmp/selected_skills
    print_success "Выбраны навыки: $SELECTED_SKILLS"
}

# ============================================
# ВЫБОР НАВЫКОВ CLAWHUB
# ============================================
show_clawhub_skills() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🦞 НАВЫКИ CLAWHUB ДЛЯ ДЖАРВИСА                          ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) self-improving-agent  - самообучение, запоминает ошибки"
    echo -e "  ${GREEN}2${NC}) ontology              - граф знаний, связи между данными"
    echo -e "  ${GREEN}3${NC}) API Gateway           - 100+ API (Google, MS, GitHub, Slack)"
    echo -e "  ${GREEN}4${NC}) Agent Browser         - автоматизация браузера"
    echo -e "  ${GREEN}5${NC}) Obsidian              - работа с заметками Obsidian"
    echo -e "  ${GREEN}6${NC}) Word / DOCX           - создание и редактирование документов"
    echo -e "  ${GREEN}7${NC}) Excel / XLSX          - работа с таблицами Excel"
    echo -e "  ${GREEN}8${NC}) Mcporter              - управление MCP серверами"
    echo -e "  ${GREEN}9${NC}) Baidu Search          - поиск через Baidu"
    echo -e "  ${GREEN}10${NC}) Все популярные навыки (рекомендуется)"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Введите номера через пробел (например: 1 2 3): " CLAWHUB_CHOICE
    
    # Если выбран вариант 10, показываем подтверждение
    if [[ "$CLAWHUB_CHOICE" == *"10"* ]]; then
        echo ""
        echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│  📦 ВЫБРАНЫ ВСЕ ПОПУЛЯРНЫЕ НАВЫКИ CLAWHUB                       │${NC}"
        echo -e "${YELLOW}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "│                                                                 │${NC}"
        echo -e "│  Будут установлены следующие навыки:                           │${NC}"
        echo -e "│                                                                 │${NC}"
        echo -e "│  ✅ 1. self-improving-agent  - самообучение, запоминает ошибки  │${NC}"
        echo -e "│  ✅ 2. ontology              - граф знаний                      │${NC}"
        echo -e "│  ✅ 3. API Gateway           - 100+ API                         │${NC}"
        echo -e "│  ✅ 4. Agent Browser         - автоматизация браузера           │${NC}"
        echo -e "│  ✅ 5. Obsidian              - работа с заметками               │${NC}"
        echo -e "│  ✅ 6. Word / DOCX           - создание документов              │${NC}"
        echo -e "│  ✅ 7. Excel / XLSX          - работа с таблицами               │${NC}"
        echo -e "│  ✅ 8. Mcporter              - управление MCP серверами         │${NC}"
        echo -e "│  ✅ 9. Baidu Search          - поиск через Baidu                │${NC}"
        echo -e "│                                                                 │${NC}"
        echo -e "│  ⚠️  Установка всех навыков может занять 5-10 минут            │${NC}"
        echo -e "│     и потребует ~500MB дополнительного места.                   │${NC}"
        echo -e "│                                                                 │${NC}"
        echo -e "└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        read -p "👉 Подтвердить установку всех навыков? (y/N): " confirm_all
        if [[ "$confirm_all" != "y" && "$confirm_all" != "Y" ]]; then
            print_info "Установка всех навыков отменена. Выберите конкретные."
            show_clawhub_skills
            return
        fi
        CLAWHUB_CHOICE="1 2 3 4 5 6 7 8 9"
    fi
    
    echo "$CLAWHUB_CHOICE" > /tmp/clawhub_selected
}

# ============================================
# СОЗДАНИЕ БАЗОВЫХ НАВЫКОВ
# ============================================
create_base_skills() {
    mkdir -p $SKILLS_DIR
    cat > $SKILLS_DIR/base.py << 'EOF'
#!/usr/bin/env python3
import subprocess
import json
import os
import requests
import re

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
        if skills_config.get("system", True):
            command = text[1:] if text.startswith('!') else text[1:]
            return execute_shell(command, user_id)
        return "⛔ Навык 'system' отключён"
    
    if text_lower.startswith('@cat '):
        if skills_config.get("file", True):
            path = text[5:].strip()
            return read_file(path)
        return "⛔ Навык 'file' отключён"
    
    if text_lower.startswith('@write '):
        if skills_config.get("file", True):
            parts = text[7:].split('||', 1)
            if len(parts) == 2:
                path = parts[0].strip()
                content = parts[1].strip()
                return write_file(path, content)
            return "❌ Формат: @write /путь/файла || содержание"
        return "⛔ Навык 'file' отключён"
    
    if 'погода' in text_lower or 'weather' in text_lower:
        if skills_config.get("weather", True):
            city_match = re.search(r'(?:в|in)\s+([A-Za-zА-Яа-я-]+)', text)
            city = city_match.group(1) if city_match else "Moscow"
            return get_weather(city)
        return "⛔ Навык 'weather' отключён"
    
    if text_lower.startswith('найди ') or text_lower.startswith('поиск ') or text_lower.startswith('search '):
        if skills_config.get("search", True):
            query = text_lower.replace('найди ', '').replace('поиск ', '').replace('search ', '')
            return search_web(query)
        return "⛔ Навык 'search' отключён"
    
    if text_lower.startswith('напомни ') or text_lower.startswith('remind '):
        if skills_config.get("reminder", True):
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

def get_base_skills_list():
    return ["system", "file", "weather", "search", "reminder"]
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/base.py
}

# ============================================
# СОЗДАНИЕ GOOGLE НАВЫКОВ
# ============================================
create_google_skills() {
    cat > $SKILLS_DIR/google.py << 'EOF'
#!/usr/bin/env python3
import os
import pickle
import base64
import re
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/spreadsheets.readonly'
]

TOKEN_FILE = '/opt/jarvis/token.pickle'
CREDS_FILE = '/opt/jarvis/credentials.json'

def get_google_creds():
    creds = None
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        elif os.path.exists(CREDS_FILE):
            flow = InstalledAppFlow.from_client_secrets_file(CREDS_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        else:
            return None
        with open(TOKEN_FILE, 'wb') as token:
            pickle.dump(creds, token)
    return creds

def google_search_emails(query, max_results=5):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен. Поместите credentials.json в /opt/jarvis/"
    service = build('gmail', 'v1', credentials=creds)
    results = service.users().messages().list(userId='me', q=query, maxResults=max_results).execute()
    emails = []
    for msg in results.get('messages', []):
        msg_data = service.users().messages().get(userId='me', id=msg['id']).execute()
        emails.append(msg_data.get('snippet', ''))
    return '\n'.join(emails) if emails else "❌ Писем не найдено"

def google_send_email(to, subject, body):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен"
    service = build('gmail', 'v1', credentials=creds)
    message = {
        'raw': base64.urlsafe_b64encode(f"To: {to}\nSubject: {subject}\n\n{body}".encode()).decode()
    }
    service.users().messages().send(userId='me', body=message).execute()
    return f"✅ Письмо отправлено на {to}"

def google_get_calendar_events(max_results=10):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен"
    service = build('calendar', 'v3', credentials=creds)
    events = service.events().list(calendarId='primary', maxResults=max_results).execute()
    output = "📅 **Ближайшие события:**\n\n"
    for event in events.get('items', []):
        start = event['start'].get('dateTime', event['start'].get('date'))
        output += f"• {event['summary']} — {start}\n"
    return output if output != "📅 **Ближайшие события:**\n\n" else "📭 Нет ближайших событий"

def google_create_calendar_event(summary, start_time):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен"
    service = build('calendar', 'v3', credentials=creds)
    event = {
        'summary': summary,
        'start': {'dateTime': start_time, 'timeZone': 'Europe/Moscow'},
        'end': {'dateTime': start_time, 'timeZone': 'Europe/Moscow'},
    }
    event = service.events().insert(calendarId='primary', body=event).execute()
    return f"✅ Событие создано: {event.get('htmlLink')}"

def google_search_contacts(name):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен"
    service = build('people', 'v1', credentials=creds)
    results = service.people().searchContacts(query=name, readMask='names,emailAddresses,phoneNumbers').execute()
    output = f"📇 **Контакты по запросу '{name}':**\n\n"
    for person in results.get('results', []):
        names = person['person'].get('names', [{}])[0].get('displayName', '')
        emails = person['person'].get('emailAddresses', [{}])[0].get('value', '')
        phones = person['person'].get('phoneNumbers', [{}])[0].get('value', '')
        output += f"• {names}\n  📧 {emails}\n  📞 {phones}\n\n"
    return output if output != f"📇 **Контакты по запросу '{name}':**\n\n" else "❌ Контакты не найдены"

def process_google_skills(text, user_id):
    text_lower = text.lower()
    if 'почта от' in text_lower:
        query = text_lower.replace('почта от', '').strip()
        return google_search_emails(query)
    if text_lower.startswith('отправить письмо '):
        parts = text[17:].split(' тема: ', 1)
        if len(parts) == 2:
            to = parts[0].strip()
            rest = parts[1].split(' текст: ', 1)
            if len(rest) == 2:
                subject = rest[0].strip()
                body = rest[1].strip()
                return google_send_email(to, subject, body)
    if 'встреча' in text_lower:
        match = re.search(r'встреча\s+(.+?)\s+(.+)', text)
        if match:
            summary = match.group(1)
            time = match.group(2)
            return google_create_calendar_event(summary, time)
    if 'календарь' in text_lower:
        return google_get_calendar_events()
    if 'контакт' in text_lower:
        name = text_lower.replace('контакт', '').strip()
        return google_search_contacts(name)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/google.py
}

# ============================================
# СОЗДАНИЕ GITHUB НАВЫКОВ
# ============================================
create_github_skills() {
    cat > $SKILLS_DIR/github.py << 'EOF'
#!/usr/bin/env python3
import requests
import os

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN', '')

def github_request(endpoint, method='GET', data=None):
    headers = {'Authorization': f'token {GITHUB_TOKEN}'} if GITHUB_TOKEN else {}
    url = f'https://api.github.com{endpoint}'
    if method == 'GET':
        response = requests.get(url, headers=headers)
    else:
        response = requests.post(url, headers=headers, json=data)
    return response.json() if response.status_code == 200 else None

def github_list_repos(user):
    repos = github_request(f'/users/{user}/repos')
    if repos:
        output = f"📁 **Репозитории {user}:**\n\n"
        for repo in repos[:10]:
            output += f"• [{repo['name']}]({repo['html_url']}) - {repo['description'] or 'нет описания'}\n"
        return output
    return "❌ Не удалось получить репозитории"

def github_create_issue(repo, title, body):
    result = github_request(f'/repos/{repo}/issues', 'POST', {'title': title, 'body': body})
    if result and 'html_url' in result:
        return f"✅ Issue создан: {result['html_url']}"
    return "❌ Ошибка создания issue"

def process_github_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('репозитории '):
        user = text_lower.replace('репозитории ', '').strip()
        return github_list_repos(user)
    if text_lower.startswith('создать issue '):
        parts = text[14:].split(' || ', 1)
        if len(parts) == 2:
            repo = parts[0].strip()
            rest = parts[1].split(' || ', 1)
            if len(rest) == 2:
                title = rest[0].strip()
                body = rest[1].strip()
                return github_create_issue(repo, title, body)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/github.py
}

# ============================================
# СОЗДАНИЕ CRYPTO НАВЫКОВ
# ============================================
create_crypto_skills() {
    cat > $SKILLS_DIR/crypto.py << 'EOF'
#!/usr/bin/env python3
import requests

def get_crypto_price(coin='bitcoin'):
    try:
        response = requests.get(f'https://api.coingecko.com/api/v3/simple/price?ids={coin}&vs_currencies=usd,rub', timeout=10)
        if response.status_code == 200:
            data = response.json()
            price_usd = data.get(coin, {}).get('usd', 0)
            price_rub = data.get(coin, {}).get('rub', 0)
            return f"💰 {coin.upper()}: ${price_usd:,.2f} / ₽{price_rub:,.2f}"
        return "❌ Не удалось получить курс"
    except:
        return "❌ Ошибка подключения"

def get_currency_rate(currency='usd'):
    try:
        response = requests.get('https://api.exchangerate-api.com/v4/latest/USD', timeout=10)
        if response.status_code == 200:
            data = response.json()
            rate = data.get('rates', {}).get(currency.upper(), 0)
            return f"💵 USD/{currency.upper()}: {rate:.2f}"
        return "❌ Не удалось получить курс"
    except:
        return "❌ Ошибка подключения"

def process_crypto_skills(text, user_id):
    text_lower = text.lower()
    if 'биткоин' in text_lower or 'bitcoin' in text_lower or 'btc' in text_lower:
        return get_crypto_price('bitcoin')
    if 'эфир' in text_lower or 'ethereum' in text_lower or 'eth' in text_lower:
        return get_crypto_price('ethereum')
    if 'курс доллара' in text_lower or 'usd' in text_lower:
        return get_currency_rate('rub')
    if 'курс евро' in text_lower or 'eur' in text_lower:
        return get_currency_rate('rub')
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/crypto.py
}

# ============================================
# СОЗДАНИЕ WEATHER НАВЫКОВ
# ============================================
create_weather_skills() {
    cat > $SKILLS_DIR/weather.py << 'EOF'
#!/usr/bin/env python3
import requests
import re

def get_weather_forecast(city="Moscow", days=3):
    try:
        response = requests.get(f"https://wttr.in/{city}?format=%C+%t+%w&m", timeout=10)
        if response.status_code == 200:
            return f"🌤️ {city}: {response.text.strip()}"
        return f"❌ Не удалось получить погоду для {city}"
    except:
        return "❌ Ошибка подключения"

def get_news(query=None):
    try:
        url = "https://newsapi.org/v2/top-headlines?country=ru&pageSize=5"
        if query:
            url = f"https://newsapi.org/v2/everything?q={query}&pageSize=5"
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            output = f"📰 **Новости{' по запросу ' + query if query else ''}:**\n\n"
            for article in data.get('articles', []):
                output += f"• {article['title']}\n  {article['url']}\n\n"
            return output
        return "❌ Не удалось получить новости"
    except:
        return "❌ Ошибка подключения"

def process_weather_skills(text, user_id):
    text_lower = text.lower()
    if 'погода' in text_lower or 'weather' in text_lower:
        city_match = re.search(r'(?:в|in)\s+([A-Za-zА-Яа-я-]+)', text)
        city = city_match.group(1) if city_match else "Moscow"
        return get_weather_forecast(city)
    if 'новости' in text_lower or 'news' in text_lower:
        query = text_lower.replace('новости', '').replace('news', '').strip()
        return get_news(query if query else None)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/weather.py
}

# ============================================
# СОЗДАНИЕ TELEGRAM УПРАВЛЕНИЯ
# ============================================
create_telegram_skills() {
    cat > $SKILLS_DIR/telegram.py << 'EOF'
#!/usr/bin/env python3
import json
import os

CONFIG_FILE = "/opt/jarvis/config.env"

def add_telegram_user(user_id, chat_id):
    try:
        with open(CONFIG_FILE, 'r') as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            if line.startswith("ALLOWED_USERS="):
                current = line.split('=')[1].strip().strip('"')
                if user_id not in current:
                    lines[i] = f'ALLOWED_USERS="{current} {user_id}"\n'
                    with open(CONFIG_FILE, 'w') as f:
                        f.writelines(lines)
                    return f"✅ Пользователь {user_id} добавлен"
                return f"👤 Пользователь {user_id} уже в списке"
        return "❌ Не удалось обновить конфиг"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def remove_telegram_user(user_id):
    try:
        with open(CONFIG_FILE, 'r') as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            if line.startswith("ALLOWED_USERS="):
                current = line.split('=')[1].strip().strip('"')
                new = ' '.join([u for u in current.split() if u != user_id])
                lines[i] = f'ALLOWED_USERS="{new}"\n'
                with open(CONFIG_FILE, 'w') as f:
                    f.writelines(lines)
                return f"✅ Пользователь {user_id} удалён"
        return "❌ Не удалось обновить конфиг"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_telegram_skills(text, user_id, is_admin):
    if not is_admin:
        return None
    text_lower = text.lower()
    if text_lower.startswith('adduser '):
        new_user = text_lower.replace('adduser ', '').strip()
        return add_telegram_user(new_user, None)
    if text_lower.startswith('deluser '):
        del_user = text_lower.replace('deluser ', '').strip()
        return remove_telegram_user(del_user)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/telegram.py
}

# ============================================
# СОЗДАНИЕ АДАПТЕРОВ CLAWHUB
# ============================================
create_self_improving_adapter() {
    cat > $SKILLS_DIR/self_improving.py << 'EOF'
#!/usr/bin/env python3
import json
import os
import sqlite3
from datetime import datetime

DB_PATH = "/opt/jarvis/clawhub_skills/self_improving.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS learnings
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_question TEXT,
                  bot_answer TEXT,
                  user_correction TEXT,
                  improved_answer TEXT,
                  created_at TEXT)''')
    conn.commit()
    conn.close()

def save_learning(question, answer, correction, improved):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO learnings (user_question, bot_answer, user_correction, improved_answer, created_at) VALUES (?, ?, ?, ?, ?)",
              (question, answer, correction, improved, datetime.now().isoformat()))
    conn.commit()
    conn.close()

def get_improved_answer(question):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT improved_answer FROM learnings WHERE user_question LIKE ? ORDER BY created_at DESC LIMIT 1",
              (f'%{question}%',))
    row = c.fetchone()
    conn.close()
    return row[0] if row else None

def process_self_improving(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('запомни '):
        parts = text[8:].split(' || ', 1)
        if len(parts) == 2:
            question = parts[0].strip()
            answer = parts[1].strip()
            save_learning(question, "", "", answer)
            return f"✅ Запомнил: {question} -> {answer}"
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/self_improving.py
}

create_api_gateway_adapter() {
    cat > $SKILLS_DIR/api_gateway.py << 'EOF'
#!/usr/bin/env python3
import requests
import json
import os

CONFIG_FILE = "/opt/jarvis/clawhub_skills/api_config.json"

def load_api_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_api_config(config):
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)

def call_api(service, endpoint, method='GET', data=None):
    config = load_api_config()
    if service not in config:
        return f"❌ Сервис {service} не настроен. Используйте /setup_api {service}"

    base_url = config[service].get('base_url')
    api_key = config[service].get('api_key')
    
    headers = {'Authorization': f'Bearer {api_key}'} if api_key else {}
    
    try:
        if method == 'GET':
            response = requests.get(f"{base_url}{endpoint}", headers=headers, timeout=30)
        else:
            response = requests.post(f"{base_url}{endpoint}", headers=headers, json=data, timeout=30)
        return response.json() if response.status_code == 200 else f"❌ Ошибка API: {response.status_code}"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_api_gateway(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('api '):
        parts = text[4:].split(' ', 2)
        if len(parts) >= 2:
            service = parts[0]
            endpoint = parts[1]
            return call_api(service, endpoint)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/api_gateway.py
}

create_browser_adapter() {
    cat > $SKILLS_DIR/agent_browser.py << 'EOF'
#!/usr/bin/env python3
import subprocess
import json

def browser_navigate(url):
    try:
        result = subprocess.run(['curl', '-s', '-L', url], capture_output=True, text=True, timeout=30)
        if result.returncode == 0:
            content = result.stdout[:2000]
            return f"🌐 {url}\n\n{content[:1000]}..."
        return "❌ Ошибка загрузки страницы"
    except Exception as e:
        return f"❌ Ошибка браузера: {e}"

def process_browser_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('открыть '):
        url = text[8:].strip()
        if not url.startswith('http'):
            url = 'https://' + url
        return browser_navigate(url)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/agent_browser.py
}

create_excel_adapter() {
    cat > $SKILLS_DIR/excel.py << 'EOF'
#!/usr/bin/env python3
import pandas as pd
import os

def excel_read(file_path, sheet_name=0):
    try:
        if not os.path.exists(file_path):
            return f"❌ Файл {file_path} не найден"
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        return df.head(20).to_string()
    except Exception as e:
        return f"❌ Ошибка чтения Excel: {e}"

def excel_create(file_path, data):
    try:
        df = pd.DataFrame(data)
        df.to_excel(file_path, index=False)
        return f"✅ Файл {file_path} создан"
    except Exception as e:
        return f"❌ Ошибка создания Excel: {e}"

def process_excel_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('excel '):
        parts = text[6:].split(' ', 1)
        if parts[0] == 'read' and len(parts) > 1:
            return excel_read(parts[1])
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/excel.py
}

create_word_adapter() {
    cat > $SKILLS_DIR/word.py << 'EOF'
#!/usr/bin/env python3
import os
import docx

def word_read(file_path):
    try:
        if not os.path.exists(file_path):
            return f"❌ Файл {file_path} не найден"
        doc = docx.Document(file_path)
        text = []
        for para in doc.paragraphs[:50]:
            text.append(para.text)
        return '\n'.join(text) if text else "(документ пуст)"
    except Exception as e:
        return f"❌ Ошибка чтения Word: {e}"

def process_word_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('word read '):
        path = text[10:].strip()
        return word_read(path)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/word.py
}

create_obsidian_adapter() {
    cat > $SKILLS_DIR/obsidian.py << 'EOF'
#!/usr/bin/env python3
import os
from datetime import datetime

VAULT_PATH = "/opt/jarvis/clawhub_skills/obsidian_vault"

def init_vault():
    os.makedirs(VAULT_PATH, exist_ok=True)

def create_note(title, content):
    init_vault()
    filename = f"{title.replace(' ', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    filepath = os.path.join(VAULT_PATH, filename)
    with open(filepath, 'w') as f:
        f.write(f"# {title}\n\n{content}\n\nСоздано: {datetime.now()}")
    return f"✅ Заметка создана: {filepath}"

def process_obsidian_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('obsidian заметка '):
        content = text[17:].strip()
        title = content[:50]
        return create_note(title, content)
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/obsidian.py
}

# ============================================
# УСТАНОВКА CLAWHUB НАВЫКОВ
# ============================================
install_clawhub_skills() {
    show_clawhub_skills
    
    SELECTED=$(cat /tmp/clawhub_selected)
    
    # Создаём директорию для ClawHub
    mkdir -p $JARVIS_DIR/clawhub_skills
    
    for num in $SELECTED; do
        case $num in
            1) create_self_improving_adapter; print_success "  ✅ self-improving-agent установлен" ;;
            2) print_info "  ⏳ ontology (граф знаний) - требует дополнительной настройки";;
            3) create_api_gateway_adapter; print_success "  ✅ API Gateway установлен" ;;
            4) create_browser_adapter; print_success "  ✅ Agent Browser установлен" ;;
            5) create_obsidian_adapter; print_success "  ✅ Obsidian установлен" ;;
            6) create_word_adapter; print_success "  ✅ Word / DOCX установлен" ;;
            7) create_excel_adapter; print_success "  ✅ Excel / XLSX установлен" ;;
            8) print_info "  ⏳ Mcporter - требует дополнительной настройки";;
            9) print_info "  ⏳ Baidu Search - требует API ключ";;
        esac
    done
    
    # Установка Python зависимостей для навыков
    if [[ "$SELECTED" == *"6"* ]] || [[ "$SELECTED" == *"7"* ]]; then
        print_info "Установка дополнительных Python библиотек..."
        sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install --quiet pandas openpyxl python-docx
    fi
    
    print_success "Навыки ClawHub установлены!"
    pause
}

# ============================================
# СОЗДАНИЕ ОСНОВНОГО БОТА
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
import importlib
import importlib.util
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

CONFIG_FILE = "/opt/jarvis/config.env"
SKILLS_DIR = "/opt/jarvis/skills"

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

# Загрузка всех навыков
skills_modules = {}
skills_config = {"system": True, "file": True, "weather": True, "search": True, "reminder": True}

if os.path.exists(SKILLS_DIR):
    for f in os.listdir(SKILLS_DIR):
        if f.endswith('.py') and f != '__init__.py':
            module_name = f[:-3]
            try:
                spec = importlib.util.spec_from_file_location(f"skills.{module_name}", os.path.join(SKILLS_DIR, f))
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                skills_modules[module_name] = module
            except Exception as e:
                print(f"Ошибка загрузки {module_name}: {e}")

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
    await update.message.reply_text(
        "📦 **Навыки Джарвиса:**\n\n"
        "| Команда | Описание |\n"
        "|---------|----------|\n"
        "| `!команда` | Выполнить shell команду |\n"
        "| `@cat /путь` | Показать содержимое файла |\n"
        "| `@write /путь || текст` | Записать текст в файл |\n"
        "| `погода в Москве` | Показать погоду |\n"
        "| `найди что-то` | Поиск в интернете |\n"
        "| `напомни текст через 5 мин` | Напоминание |\n\n"
        "**Управление:** `/skills` — список навыков\n"
        "`/skill on/off название` — включить/выключить навык",
        parse_mode="Markdown"
    )

async def skills_list(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if user_id not in ALLOWED_USERS:
        return
    output = "📦 **Доступные навыки:**\n\n"
    for module_name, module in skills_modules.items():
        if hasattr(module, 'get_base_skills_list'):
            for skill in module.get_base_skills_list():
                output += f"• {skill}\n"
    await update.message.reply_text(output, parse_mode="Markdown")

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
        skills_config[skill_name] = True
        await update.message.reply_text(f"✅ Навык '{skill_name}' включён")
    elif action == "off":
        skills_config[skill_name] = False
        await update.message.reply_text(f"✅ Навык '{skill_name}' отключён")
    else:
        await update.message.reply_text("❌ Используйте on или off")

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
    is_admin = user_id == ALLOWED_USERS[0] if ALLOWED_USERS else False
    
    # Проверка навыков
    for module_name, module in skills_modules.items():
        if hasattr(module, 'process_skills'):
            result = module.process_skills(user_text, user_id, skills_config)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_google_skills'):
            result = module.process_google_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_github_skills'):
            result = module.process_github_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_crypto_skills'):
            result = module.process_crypto_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_weather_skills'):
            result = module.process_weather_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_telegram_skills'):
            result = module.process_telegram_skills(user_text, user_id, is_admin)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_self_improving'):
            result = module.process_self_improving(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_api_gateway'):
            result = module.process_api_gateway(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_browser_skills'):
            result = module.process_browser_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_excel_skills'):
            result = module.process_excel_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_word_skills'):
            result = module.process_word_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
        if hasattr(module, 'process_obsidian_skills'):
            result = module.process_obsidian_skills(user_text, user_id)
            if result:
                await update.message.reply_text(result)
                return
    
    # Обычный диалог с ИИ
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
    app.add_handler(CommandHandler("skills", skills_list))
    app.add_handler(CommandHandler("skill", skill_toggle))
    app.add_handler(CommandHandler("status", status_cmd))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.VOICE, handle_voice))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print(f"🦞 Джарвис запущен! Модель: {MODEL}")
    print(f"📦 Загружено модулей навыков: {len(skills_modules)}")
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
# УСТАНОВКА
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

    # НАСТРОЙКА ВРЕМЕНИ
    configure_time

    # Выбор провайдеров навыков
    select_skills
    
    # ClawHub навыки
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🦞 CLAWHUB НАВЫКИ                        │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│ Навыки из ClawHub — готовые расширения для ИИ:                     │"
    echo -e "│ - самообучение, граф знаний, 100+ API, браузер, Excel, Word и др. │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Установить навыки из ClawHub? (y/N): " install_clawhub
    if [[ "$install_clawhub" == "y" || "$install_clawhub" == "Y" ]]; then
        install_clawhub_skills
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
    echo -e "📦 Выбранные навыки: ${GREEN}$(cat /tmp/selected_skills)${NC}"
    echo -e "🕐 Часовой пояс: ${GREEN}$(cat /etc/timezone 2>/dev/null || echo "не задан")${NC}"
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
    mkdir -p $JARVIS_DIR $SKILLS_DIR $JARVIS_DIR/clawhub_skills
    chown $JARVIS_USER:$JARVIS_USER $JARVIS_DIR $SKILLS_DIR $JARVIS_DIR/clawhub_skills

    # Создание конфига
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

    # Создание навыков
    print_info "Создание навыков..."
    create_base_skills
    
    SELECTED=$(cat /tmp/selected_skills)
    for skill in $SELECTED; do
        case $skill in
            google) create_google_skills; print_info "  ✅ Google навыки" ;;
            github) create_github_skills; print_info "  ✅ GitHub навыки" ;;
            crypto) create_crypto_skills; print_info "  ✅ Crypto навыки" ;;
            weather) create_weather_skills; print_info "  ✅ Weather навыки" ;;
            telegram) create_telegram_skills; print_info "  ✅ Telegram навыки" ;;
        esac
    done

    # Создание бота
    create_bot_script
    chmod +x $BOT_SCRIPT
    chown -R $JARVIS_USER:$JARVIS_USER $JARVIS_DIR

    # Виртуальное окружение
    print_info "Настройка Python окружения..."
    sudo -u $JARVIS_USER python3 -m venv $JARVIS_DIR/venv
    sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install --quiet python-telegram-bot requests pillow pandas openpyxl python-docx google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client

    # Systemd сервис
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
    echo -e "  ${MAGENTA}13)${NC}  📦 Установить навыки из ClawHub"
    echo -e "  ${MAGENTA}14)${NC}  🕐 Настройка времени и NTP"
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
        13) install_clawhub_skills ;;
        14) configure_time ;;
        0) exit 0 ;;
        *) print_warning "Неверный выбор"; pause ;;
    esac
done
