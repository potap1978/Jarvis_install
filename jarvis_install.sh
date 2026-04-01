#!/bin/bash

# ============================================
# Джарвис - универсальный установщик Telegram бота
# Версия: 4.0 - с поддержкой Grok, голосового ввода/вывода, ClawHub
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
        35) echo "grok-2:latest" ;;
        36) echo "grok-3-api" ;;
        37) echo "grok-3-lib" ;;
        *) echo "qwen2.5:1.5b" ;;
    esac
}

# ============================================
# ПОКАЗ ВСЕХ МОДЕЛЕЙ
# ============================================
show_all_models() {
    clear
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                              📦 ДОСТУПНЫЕ МОДЕЛИ (44+ варианта)                           ${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}🧠 REASONING:${NC} 1.deepseek-r1:7b  2.deepseek-r1:8b  3.qwq:32b"
    echo -e "  ${YELLOW}🏆 ТОПОВЫЕ:${NC}     4.qwen3:8b       5.qwen3:14b      6.qwen2.5:7b"
    echo -e "  ${YELLOW}💻 КОД:${NC}         10.deepseek-coder:6.7b  11.qwen2.5-coder:7b"
    echo -e "  ${YELLOW}⚡ ЛЁГКИЕ:${NC}      12.qwen2.5:1.5b  13.llama3.2:3b   14.phi3:3.8b"
    echo -e "  ${YELLOW}🎨 МУЛЬТИМОДАЛЬНЫЕ:${NC} 15.llava:7b  16.llava-phi3:3.8b  17.moondream:1.8b  18.qwen3-vl:8b"
    echo -e "  ${YELLOW}🎵 АУДИО:${NC}       28.whisper:tiny  29.whisper:small  30.whisper:medium  31.whisper:large"
    echo -e "  ${YELLOW}🎥 ВИДЕО:${NC}       32.video-llava:7b  33.internvl2:8b  34.llava-next:7b"
    echo -e "  ${YELLOW}🤖 GROK (xAI):${NC}"
    echo -e "    35. grok-2:latest     - 164GB (локально, требуется 128GB RAM)"
    echo -e "    36. grok-3 (API)      - через API xAI (платно, есть бесплатный кредит)"
    echo -e "    37. grok-3 (grok3api) - через библиотеку grok3api (бесплатно, без ключа)"
    echo -e "  ${YELLOW}🤖 CHATGPT:${NC}     38.ChatGPT(API)  39.ChatMock  40.GPT-OSS"
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

    echo -e "${YELLOW}Текущее время на сервере:${NC} $(date)"
    echo -e "${YELLOW}Текущий часовой пояс:${NC} $(cat /etc/timezone 2>/dev/null || echo "не задан")"
    echo ""

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
    echo -e "  ${GREEN}9${NC}) Свой часовой пояс"
    echo -e "  ${GREEN}0${NC}) Пропустить"
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
        9) read -p "👉 Введите часовой пояс: " TIMEZONE ;;
        0) TIMEZONE="" ;;
        *) TIMEZONE="Europe/Moscow" ;;
    esac

    if [ -n "$TIMEZONE" ]; then
        print_info "Установка часового пояса: $TIMEZONE"
        timedatectl set-timezone $TIMEZONE 2>/dev/null || {
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

    echo -e "${BLUE}Доступные NTP-серверы:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) pool.ntp.org           (стандартные)"
    echo -e "  ${GREEN}2${NC}) ru.pool.ntp.org        (российские)"
    echo -e "  ${GREEN}3${NC}) europe.pool.ntp.org    (европейские)"
    echo -e "  ${GREEN}4${NC}) time.google.com        (Google)"
    echo -e "  ${GREEN}5${NC}) time.cloudflare.com    (Cloudflare)"
    echo -e "  ${GREEN}6${NC}) Свои серверы"
    echo -e "  ${GREEN}0${NC}) Пропустить"
    echo ""
    read -p "👉 Выберите [0-6]: " ntp_choice

    NTP_SERVERS=""
    case $ntp_choice in
        1) NTP_SERVERS="pool.ntp.org" ;;
        2) NTP_SERVERS="ru.pool.ntp.org" ;;
        3) NTP_SERVERS="europe.pool.ntp.org" ;;
        4) NTP_SERVERS="time.google.com" ;;
        5) NTP_SERVERS="time.cloudflare.com" ;;
        6) read -p "👉 Введите NTP-серверы: " NTP_SERVERS ;;
        0) ;;
        *) NTP_SERVERS="pool.ntp.org" ;;
    esac

    if [ -n "$NTP_SERVERS" ]; then
        print_info "Настройка синхронизации с $NTP_SERVERS..."
        if ! command -v chronyc &> /dev/null; then
            apt install -y chrony
        fi
        cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak 2>/dev/null
        sed -i '/^server /d' /etc/chrony/chrony.conf 2>/dev/null
        for server in $NTP_SERVERS; do
            echo "server $server iburst" >> /etc/chrony/chrony.conf
        done
        systemctl restart chrony
        print_success "Синхронизация настроена"
    fi

    echo ""
    print_success "Настройка времени завершена!"
    echo -e "${YELLOW}Текущее время:${NC} $(date)"
    pause
}

# ============================================
# ВЫБОР TTS ДВИЖКА И ГОЛОСА
# ============================================
select_tts_engine() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🎤 НАСТРОЙКА ГОЛОСОВОГО ОТВЕТА                         ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Выберите движок для голосового ответа (TTS):${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) Edge TTS      - через интернет, качественные голоса Microsoft (рекомендуется)"
    echo -e "  ${GREEN}2${NC}) Silero TTS     - локально, без интернета (требует ~500MB)"
    echo -e "  ${GREEN}0${NC}) Отключить голосовые ответы"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Выберите [0-2]: " tts_choice
    
    case $tts_choice in
        1) 
            TTS_ENGINE="edge"
            print_info "Будет использован Edge TTS"
            select_edge_voice
            ;;
        2) 
            TTS_ENGINE="silero"
            print_info "Будет использован Silero TTS (локальный)"
            select_silero_voice
            ;;
        *) 
            TTS_ENGINE="none"
            print_info "Голосовые ответы отключены"
            echo "TTS_ENGINE=\"none\"" >> $CONFIG_FILE
            ;;
    esac
}

select_edge_voice() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🎤 ВЫБОР ГОЛОСА (EDGE TTS)                            ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Выберите голос для ответов:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) ru-RU-DariyaNeural     (Дарья, женский, рекомендуемый)"
    echo -e "  ${GREEN}2${NC}) ru-RU-SvetlanaNeural   (Светлана, женский)"
    echo -e "  ${GREEN}3${NC}) ru-RU-DmitryNeural     (Дмитрий, мужской)"
    echo -e "  ${GREEN}4${NC}) ru-RU-MarinaNeural     (Марина, женский)"
    echo -e "  ${GREEN}5${NC}) ru-RU-ArinaNeural      (Арина, женский)"
    echo -e "  ${GREEN}6${NC}) ru-RU-AntonNeural      (Антон, мужской)"
    echo -e "  ${GREEN}7${NC}) en-US-JennyNeural      (Дженни, английский, женский)"
    echo -e "  ${GREEN}8${NC}) Свой голос (введите название)"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Выберите [1-8]: " voice_choice
    
    case $voice_choice in
        1) TTS_VOICE="ru-RU-DariyaNeural" ;;
        2) TTS_VOICE="ru-RU-SvetlanaNeural" ;;
        3) TTS_VOICE="ru-RU-DmitryNeural" ;;
        4) TTS_VOICE="ru-RU-MarinaNeural" ;;
        5) TTS_VOICE="ru-RU-ArinaNeural" ;;
        6) TTS_VOICE="ru-RU-AntonNeural" ;;
        7) TTS_VOICE="en-US-JennyNeural" ;;
        8) read -p "👉 Введите название голоса: " TTS_VOICE ;;
        *) TTS_VOICE="ru-RU-DariyaNeural" ;;
    esac
    
    echo "TTS_ENGINE=\"edge\"" >> $CONFIG_FILE
    echo "TTS_VOICE=\"$TTS_VOICE\"" >> $CONFIG_FILE
    print_success "Выбран голос: $TTS_VOICE"
}

select_silero_voice() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}                         🎤 ВЫБОР ГОЛОСА (SILERO TTS)                          ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Выберите голос для ответов:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) xenia      (женский, рекомендуемый)"
    echo -e "  ${GREEN}2${NC}) eugene     (мужской)"
    echo -e "  ${GREEN}3${NC}) aidar      (мужской)"
    echo -e "  ${GREEN}4${NC}) baya       (женский)"
    echo -e "  ${GREEN}5${NC}) kseniya    (женский)"
    echo -e "  ${GREEN}6${NC}) random     (случайный)"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Выберите [1-6]: " voice_choice
    
    case $voice_choice in
        1) TTS_VOICE="xenia" ;;
        2) TTS_VOICE="eugene" ;;
        3) TTS_VOICE="aidar" ;;
        4) TTS_VOICE="baya" ;;
        5) TTS_VOICE="kseniya" ;;
        6) TTS_VOICE="random" ;;
        *) TTS_VOICE="xenia" ;;
    esac
    
    echo "TTS_ENGINE=\"silero\"" >> $CONFIG_FILE
    echo "TTS_VOICE=\"$TTS_VOICE\"" >> $CONFIG_FILE
    print_success "Выбран голос: $TTS_VOICE"
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
    echo -e "Выберите провайдеров (можно несколько):"
    echo ""
    echo -e "  ${GREEN}[ ] 1. GOOGLE${NC}        - Gmail, Календарь, Контакты"
    echo -e "  ${GREEN}[ ] 2. GITHUB${NC}        - Репозитории, Issues, PR"
    echo -e "  ${GREEN}[ ] 3. CRYPTO${NC}        - Курсы валют, биткоин, эфир"
    echo -e "  ${GREEN}[ ] 4. WEATHER/NEWS${NC}  - Погода, новости"
    echo -e "  ${GREEN}[ ] 5. TELEGRAM${NC}      - Управление ботом"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Введите номера через пробел: " SKILLS_CHOICE
    
    SELECTED_SKILLS="base"
    for num in $SKILLS_CHOICE; do
        case $num in
            1) SELECTED_SKILLS="$SELECTED_SKILLS google" ;;
            2) SELECTED_SKILLS="$SELECTED_SKILLS github" ;;
            3) SELECTED_SKILLS="$SELECTED_SKILLS crypto" ;;
            4) SELECTED_SKILLS="$SELECTED_SKILLS weather" ;;
            5) SELECTED_SKILLS="$SELECTED_SKILLS telegram" ;;
        esac
    done
    
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
    echo -e "  ${GREEN}2${NC}) API Gateway           - 100+ API (Google, GitHub, Slack)"
    echo -e "  ${GREEN}3${NC}) Agent Browser         - автоматизация браузера"
    echo -e "  ${GREEN}4${NC}) Obsidian              - работа с заметками"
    echo -e "  ${GREEN}5${NC}) Word / DOCX           - создание документов"
    echo -e "  ${GREEN}6${NC}) Excel / XLSX          - работа с таблицами"
    echo -e "  ${GREEN}7${NC}) Все популярные навыки"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "👉 Введите номера через пробел: " CLAWHUB_CHOICE
    
    if [[ "$CLAWHUB_CHOICE" == *"7"* ]]; then
        echo ""
        echo -e "${YELLOW}Будут установлены все навыки (self-improving, API Gateway, Agent Browser, Obsidian, Word, Excel)${NC}"
        read -p "👉 Подтвердить? (y/N): " confirm_all
        if [[ "$confirm_all" == "y" || "$confirm_all" == "Y" ]]; then
            CLAWHUB_CHOICE="1 2 3 4 5 6"
        fi
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
        return output if output else "✅ Команда выполнена"
    except subprocess.TimeoutExpired:
        return "⏰ Команда выполнялась >30 сек"
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
        return f"❌ Не удалось получить погоду"
    except:
        return "❌ Ошибка подключения"

def search_web(query):
    try:
        response = requests.get(f"https://html.duckduckgo.com/html/?q={query}", headers={"User-Agent": "Mozilla/5.0"}, timeout=10)
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
    return f"✅ Напоминание на {seconds} сек: {text}"

def process_skills(text, user_id, skills_config, send_callback=None):
    text_lower = text.lower()
    
    if text_lower.startswith('!') or text_lower.startswith('$'):
        if skills_config.get("system", True):
            command = text[1:] if text.startswith('!') else text[1:]
            return execute_shell(command, user_id)
        return "⛔ Навык 'system' отключён"
    
    if text_lower.startswith('@cat '):
        if skills_config.get("file", True):
            return read_file(text[5:].strip())
        return "⛔ Навык 'file' отключён"
    
    if text_lower.startswith('@write '):
        if skills_config.get("file", True):
            parts = text[7:].split('||', 1)
            if len(parts) == 2:
                return write_file(parts[0].strip(), parts[1].strip())
            return "❌ Формат: @write /путь || содержание"
        return "⛔ Навык 'file' отключён"
    
    if 'погода' in text_lower:
        if skills_config.get("weather", True):
            city_match = re.search(r'(?:в|in)\s+([A-Za-zА-Яа-я-]+)', text)
            city = city_match.group(1) if city_match else "Moscow"
            return get_weather(city)
        return "⛔ Навык 'weather' отключён"
    
    if text_lower.startswith('найди ') or text_lower.startswith('поиск '):
        if skills_config.get("search", True):
            query = text_lower.replace('найди ', '').replace('поиск ', '')
            return search_web(query)
        return "⛔ Навык 'search' отключён"
    
    if text_lower.startswith('напомни '):
        if skills_config.get("reminder", True):
            parts = text_lower.replace('напомни ', '').split(' через ', 1)
            if len(parts) == 2:
                seconds = 60
                if 'мин' in parts[1]:
                    seconds = int(re.search(r'\d+', parts[1]).group()) * 60
                elif 'сек' in parts[1]:
                    seconds = int(re.search(r'\d+', parts[1]).group())
                return add_reminder(user_id, parts[0], seconds)
            return "❌ Формат: напомни текст через 5 мин"
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

SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.send', 'https://www.googleapis.com/auth/calendar', 'https://www.googleapis.com/auth/contacts.readonly']
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

def google_search_emails(query):
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен. Поместите credentials.json в /opt/jarvis/"
    service = build('gmail', 'v1', credentials=creds)
    results = service.users().messages().list(userId='me', q=query, maxResults=5).execute()
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
    message = {'raw': base64.urlsafe_b64encode(f"To: {to}\nSubject: {subject}\n\n{body}".encode()).decode()}
    service.users().messages().send(userId='me', body=message).execute()
    return f"✅ Письмо отправлено на {to}"

def google_get_calendar_events():
    creds = get_google_creds()
    if not creds:
        return "❌ Google не настроен"
    service = build('calendar', 'v3', credentials=creds)
    events = service.events().list(calendarId='primary', maxResults=10).execute()
    output = "📅 **Ближайшие события:**\n\n"
    for event in events.get('items', []):
        start = event['start'].get('dateTime', event['start'].get('date'))
        output += f"• {event['summary']} — {start}\n"
    return output if output != "📅 **Ближайшие события:**\n\n" else "📭 Нет событий"

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
        return google_search_emails(text_lower.replace('почта от', '').strip())
    if text_lower.startswith('отправить письмо '):
        parts = text[17:].split(' тема: ', 1)
        if len(parts) == 2:
            to = parts[0].strip()
            rest = parts[1].split(' текст: ', 1)
            if len(rest) == 2:
                return google_send_email(to, rest[0].strip(), rest[1].strip())
    if 'встреча' in text_lower:
        match = re.search(r'встреча\s+(.+?)\s+(.+)', text)
        if match:
            return google_create_calendar_event(match.group(1), match.group(2))
    if 'календарь' in text_lower:
        return google_get_calendar_events()
    if 'контакт' in text_lower:
        return google_search_contacts(text_lower.replace('контакт', '').strip())
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
    response = requests.get(f'https://api.github.com{endpoint}', headers=headers) if method == 'GET' else requests.post(f'https://api.github.com{endpoint}', headers=headers, json=data)
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
    return f"✅ Issue создан: {result['html_url']}" if result and 'html_url' in result else "❌ Ошибка создания issue"

def process_github_skills(text, user_id):
    text_lower = text.lower()
    if text_lower.startswith('репозитории '):
        return github_list_repos(text_lower.replace('репозитории ', '').strip())
    if text_lower.startswith('создать issue '):
        parts = text[14:].split(' || ', 1)
        if len(parts) == 2:
            repo = parts[0].strip()
            rest = parts[1].split(' || ', 1)
            if len(rest) == 2:
                return github_create_issue(repo, rest[0].strip(), rest[1].strip())
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
            return f"💰 {coin.upper()}: ${data.get(coin, {}).get('usd', 0):,.2f} / ₽{data.get(coin, {}).get('rub', 0):,.2f}"
        return "❌ Не удалось получить курс"
    except:
        return "❌ Ошибка подключения"

def get_currency_rate(currency='rub'):
    try:
        response = requests.get('https://api.exchangerate-api.com/v4/latest/USD', timeout=10)
        if response.status_code == 200:
            rate = response.json().get('rates', {}).get(currency.upper(), 0)
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
    if 'курс доллара' in text_lower:
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

def get_weather_forecast(city="Moscow"):
    try:
        response = requests.get(f"https://wttr.in/{city}?format=%C+%t+%w&m", timeout=10)
        return f"🌤️ {city}: {response.text.strip()}" if response.status_code == 200 else f"❌ Не удалось получить погоду"
    except:
        return "❌ Ошибка подключения"

def process_weather_skills(text, user_id):
    text_lower = text.lower()
    if 'погода' in text_lower:
        city_match = re.search(r'(?:в|in)\s+([A-Za-zА-Яа-я-]+)', text)
        return get_weather_forecast(city_match.group(1) if city_match else "Moscow")
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
import os

CONFIG_FILE = "/opt/jarvis/config.env"

def add_telegram_user(user_id):
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
        return add_telegram_user(text_lower.replace('adduser ', '').strip())
    if text_lower.startswith('deluser '):
        return remove_telegram_user(text_lower.replace('deluser ', '').strip())
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/telegram.py
}

# ============================================
# АДАПТЕРЫ CLAWHUB
# ============================================
create_self_improving_adapter() {
    cat > $SKILLS_DIR/self_improving.py << 'EOF'
#!/usr/bin/env python3
import sqlite3
from datetime import datetime

DB_PATH = "/opt/jarvis/clawhub_skills/self_improving.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS learnings (id INTEGER PRIMARY KEY AUTOINCREMENT, user_question TEXT, improved_answer TEXT, created_at TEXT)''')
    conn.commit()
    conn.close()

def save_learning(question, answer):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO learnings (user_question, improved_answer, created_at) VALUES (?, ?, ?)", (question, answer, datetime.now().isoformat()))
    conn.commit()
    conn.close()

def get_improved_answer(question):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT improved_answer FROM learnings WHERE user_question LIKE ? ORDER BY created_at DESC LIMIT 1", (f'%{question}%',))
    row = c.fetchone()
    conn.close()
    return row[0] if row else None

def process_self_improving(text, user_id):
    if text.lower().startswith('запомни '):
        parts = text[8:].split(' || ', 1)
        if len(parts) == 2:
            save_learning(parts[0].strip(), parts[1].strip())
            return f"✅ Запомнил: {parts[0]} -> {parts[1]}"
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

def call_api(service, endpoint):
    config = {}
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
    if service not in config:
        return f"❌ Сервис {service} не настроен"
    try:
        response = requests.get(f"{config[service].get('base_url')}{endpoint}", headers={'Authorization': f"Bearer {config[service].get('api_key')}"}, timeout=30)
        return response.json() if response.status_code == 200 else f"❌ Ошибка API: {response.status_code}"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_api_gateway(text, user_id):
    if text.lower().startswith('api '):
        parts = text[4:].split(' ', 1)
        if len(parts) == 2:
            return call_api(parts[0], parts[1])
    return None
EOF
    chown $JARVIS_USER:$JARVIS_USER $SKILLS_DIR/api_gateway.py
}

create_browser_adapter() {
    cat > $SKILLS_DIR/agent_browser.py << 'EOF'
#!/usr/bin/env python3
import subprocess

def browser_navigate(url):
    try:
        result = subprocess.run(['curl', '-s', '-L', url], capture_output=True, text=True, timeout=30)
        return f"🌐 {url}\n\n{result.stdout[:1000]}..." if result.returncode == 0 else "❌ Ошибка загрузки"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_browser_skills(text, user_id):
    if text.lower().startswith('открыть '):
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

def excel_read(file_path):
    if not os.path.exists(file_path):
        return f"❌ Файл {file_path} не найден"
    try:
        return pd.read_excel(file_path).head(20).to_string()
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_excel_skills(text, user_id):
    if text.lower().startswith('excel read '):
        return excel_read(text[10:].strip())
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
    if not os.path.exists(file_path):
        return f"❌ Файл {file_path} не найден"
    try:
        doc = docx.Document(file_path)
        return '\n'.join([p.text for p in doc.paragraphs[:50]]) or "(документ пуст)"
    except Exception as e:
        return f"❌ Ошибка: {e}"

def process_word_skills(text, user_id):
    if text.lower().startswith('word read '):
        return word_read(text[10:].strip())
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

def create_note(content):
    os.makedirs(VAULT_PATH, exist_ok=True)
    filename = f"note_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    with open(os.path.join(VAULT_PATH, filename), 'w') as f:
        f.write(f"# {content[:50]}\n\n{content}\n\nСоздано: {datetime.now()}")
    return f"✅ Заметка создана: {filename}"

def process_obsidian_skills(text, user_id):
    if text.lower().startswith('obsidian заметка '):
        return create_note(text[17:].strip())
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
    
    mkdir -p $JARVIS_DIR/clawhub_skills
    
    for num in $SELECTED; do
        case $num in
            1) create_self_improving_adapter; print_success "  ✅ self-improving-agent установлен" ;;
            2) create_api_gateway_adapter; print_success "  ✅ API Gateway установлен" ;;
            3) create_browser_adapter; print_success "  ✅ Agent Browser установлен" ;;
            4) create_obsidian_adapter; print_success "  ✅ Obsidian установлен" ;;
            5) create_word_adapter; print_success "  ✅ Word / DOCX установлен" ;;
            6) create_excel_adapter; print_success "  ✅ Excel / XLSX установлен" ;;
        esac
    done
    
    if [[ "$SELECTED" == *"5"* ]] || [[ "$SELECTED" == *"6"* ]]; then
        print_info "Установка дополнительных библиотек..."
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
USE_XAI = config.get("USE_XAI", "false") == "true"
XAI_API_KEY = config.get("XAI_API_KEY", "")
USE_GROK3API = config.get("USE_GROK3API", "false") == "true"
TTS_ENGINE = config.get("TTS_ENGINE", "none")
TTS_VOICE = config.get("TTS_VOICE", "ru-RU-DariyaNeural")

# Загрузка навыков
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
        "🎤 **Отправьте голосовое** — распознаю речь и отвечу голосом\n"
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
        "🎤 **Голосовое общение:**\n"
        "| `отправьте голосовое` | Джарвис ответит голосом |\n\n"
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
            await update.message.reply_text(response.json().get("response", "Не могу описать"))
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
        # 1. Скачиваем голосовое
        voice_file = await update.message.voice.get_file()
        voice_path = f"/tmp/voice_{user_id}.ogg"
        await voice_file.download_to_drive(voice_path)
        
        # 2. Конвертируем в WAV
        wav_path = f"/tmp/voice_{user_id}.wav"
        subprocess.run(["ffmpeg", "-i", voice_path, "-ar", "16000", "-ac", "1", wav_path, "-y"], 
                      capture_output=True)
        
        # 3. Распознаём речь через whisper (Python библиотека)
        recognized_text = ""
        try:
            import whisper
            model = whisper.load_model("tiny")
            result = model.transcribe(wav_path, language="ru")
            recognized_text = result["text"]
        except ImportError:
            # Если whisper не установлен, пробуем через Ollama
            try:
                whisper_response = requests.post("http://127.0.0.1:11434/api/generate", json={
                    "model": "whisper",
                    "prompt": "",
                    "file": wav_path,
                    "stream": False
                }, timeout=60)
                recognized_text = whisper_response.json().get("response", "") if whisper_response.status_code == 200 else ""
            except:
                recognized_text = ""
        except Exception as e:
            print(f"Whisper error: {e}")
            recognized_text = ""
        
        if not recognized_text:
            await update.message.reply_text("🎤 Не удалось распознать речь")
            return
        
        # 4. Отправляем распознанный текст
        await update.message.reply_text(f"🎤 Вы сказали: {recognized_text}")
        
        # 5. Получаем ответ от модели
        await update.message.reply_chat_action("typing")
        response = await get_ai_response(recognized_text)
        
        if not response:
            await update.message.reply_text("❌ Не удалось получить ответ от модели")
            return
        
        # 6. Отправляем текстовый ответ
        await update.message.reply_text(response)
        
        # 7. Если включён TTS — отправляем голосом
        if TTS_ENGINE == "edge":
            await send_voice_edge(update, response)
        elif TTS_ENGINE == "silero":
            await send_voice_silero(update, response)
            
    except Exception as e:
        await update.message.reply_text(f"❌ Ошибка: {str(e)[:100]}")
    finally:
        for path in [voice_path, wav_path]:
            if os.path.exists(path):
                os.remove(path)

async def send_voice_edge(update: Update, text):
    """Отправка голосового сообщения через Edge TTS"""
    try:
        import edge_tts
        
        output_path = f"/tmp/jarvis_response_{update.effective_user.id}.mp3"
        
        # Синтез речи
        communicate = edge_tts.Communicate(text, TTS_VOICE)
        await communicate.save(output_path)
        
        # Отправка голосового
        with open(output_path, 'rb') as f:
            await update.message.reply_voice(voice=f)
        
        os.remove(output_path)
    except Exception as e:
        print(f"Edge TTS Error: {e}")
        await update.message.reply_text("⚠️ Не удалось синтезировать голос")

async def send_voice_silero(update: Update, text):
    """Отправка голосового сообщения через Silero TTS (локально)"""
    try:
        import torch
        import soundfile as sf
        import random
        
        output_path = f"/tmp/jarvis_response_{update.effective_user.id}.wav"
        
        # Загрузка модели (один раз)
        if not hasattr(send_voice_silero, "model"):
            device = torch.device('cpu')
            send_voice_silero.model, _ = torch.hub.load(
                repo_or_dir='snakers4/silero-models',
                model='silero_tts',
                language='ru',
                speaker='v3_1'
            )
            send_voice_silero.model.to(device)
        
        # Выбор голоса
        if TTS_VOICE == "random":
            voices = ["xenia", "eugene", "aidar", "baya", "kseniya"]
            speaker = random.choice(voices)
        else:
            speaker = TTS_VOICE
        
        # Синтез речи
        audio = send_voice_silero.model.apply_tts(text, speaker=speaker, sample_rate=48000)
        sf.write(output_path, audio, 48000)
        
        # Конвертируем в MP3 для Telegram
        mp3_path = output_path.replace('.wav', '.mp3')
        subprocess.run(["ffmpeg", "-i", output_path, "-y", mp3_path], capture_output=True)
        
        # Отправка
        with open(mp3_path, 'rb') as f:
            await update.message.reply_voice(voice=f)
        
        os.remove(output_path)
        os.remove(mp3_path)
    except Exception as e:
        print(f"Silero TTS Error: {e}")
        await update.message.reply_text("⚠️ Не удалось синтезировать голос")

async def get_ai_response(prompt):
    """Получение ответа от выбранной модели"""
    try:
        if USE_XAI and XAI_API_KEY:
            response = requests.post(
                "https://api.x.ai/v1/chat/completions",
                headers={"Authorization": f"Bearer {XAI_API_KEY}", "Content-Type": "application/json"},
                json={"model": "grok-3", "messages": [{"role": "user", "content": prompt}]},
                timeout=60
            )
            if response.status_code == 200:
                return response.json().get("choices", [{}])[0].get("message", {}).get("content", "")
        
        elif USE_GROK3API:
            from grok3api.client import GrokClient
            client = GrokClient()
            result = client.ask(prompt)
            return result.modelResponse.message
        
        elif USE_OPENAI and OPENAI_KEY:
            import openai
            openai.api_key = OPENAI_KEY
            response = openai.ChatCompletion.create(
                model=OPENAI_MODEL,
                messages=[{"role": "user", "content": prompt}],
                timeout=60
            )
            return response.choices[0].message.content
        
        else:
            response = requests.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": f"Ты Джарвис. Отвечай кратко и по делу. Пользователь: {prompt}",
                "stream": False
            }, timeout=120)
            if response.status_code == 200:
                return response.json().get("response", "")
        
        return None
    except Exception as e:
        print(f"AI Response Error: {e}")
        return None

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
    response = await get_ai_response(user_text)
    if response:
        await update.message.reply_text(response)
    else:
        await update.message.reply_text("⚠️ Ошибка модели")

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
        f"🎤 Голосовой ответ: `{TTS_ENGINE}`\n"
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
    print(f"🎤 TTS движок: {TTS_ENGINE}, голос: {TTS_VOICE}")
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
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🤖 GROK (xAI)                            │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│  ${GREEN}9${NC}) grok-2:latest     - локально (164GB, требует 128GB RAM) │"
    echo -e "│  ${GREEN}10${NC}) grok-3 (API)      - через API xAI (платно)            │"
    echo -e "│  ${GREEN}11${NC}) grok-3 (grok3api) - через библиотеку (бесплатно)      │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    FREE_RAM=$(free -g | awk '/^Mem:/{print $7}')
    echo -e "${BLUE}💾 Ваш сервер:${NC} ${TOTAL_RAM}GB RAM (свободно ~${FREE_RAM}GB)"
    echo ""
    
    read -p "👉 Выберите [1-11]: " MODEL_CHOICE
    
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
        9) MODEL="grok-2:latest" ;;
        10) MODEL="grok-3-api" ;;
        11) MODEL="grok-3-lib" ;;
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
    echo -e "│ Модели: gpt-4o-mini (~$0.15/1M токенов) или gpt-4o (~$2.50/1M)  │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Использовать ChatGPT API? (y/N): " use_openai
    if [[ "$use_openai" == "y" || "$use_openai" == "Y" ]]; then
        read -p "👉 Введите OpenAI API ключ: " OPENAI_KEY
        read -p "👉 Модель (gpt-4o-mini / gpt-4o): " OPENAI_MODEL
        USE_OPENAI="true"
    else
        USE_OPENAI="false"
    fi

    # ============================================
    # СОЗДАЁМ ДИРЕКТОРИЮ И КОНФИГ ДО НАСТРОЕК
    # ============================================
    mkdir -p $JARVIS_DIR
    chown $JARVIS_USER:$JARVIS_USER $JARVIS_DIR 2>/dev/null || true
    touch $CONFIG_FILE
    chown $JARVIS_USER:$JARVIS_USER $CONFIG_FILE 2>/dev/null || true

    # НАСТРОЙКА ВРЕМЕНИ
    configure_time

    # Выбор TTS
    select_tts_engine

    # Выбор провайдеров навыков
    select_skills
    
    # ClawHub навыки
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                    🦞 CLAWHUB НАВЫКИ                        │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "│ Навыки из ClawHub — самообучение, API, браузер, Excel, Word и др. │"
    echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    read -p "👉 Установить навыки из ClawHub? (y/N): " install_clawhub
    if [[ "$install_clawhub" == "y" || "$install_clawhub" == "Y" ]]; then
        install_clawhub_skills
    fi

    # ============================================
    # УСТАНОВКА GROK
    # ============================================
    if [[ "$MODEL" == "grok-2:latest" ]]; then
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                    🦞 УСТАНОВКА GROK 2                      │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${NC}"
        echo -e "│  ⚠️  ВНИМАНИЕ! Модель весит 164GB и требует 128GB RAM           │${NC}"
        echo -e "│  🔧 Требования: RAM: 128GB+, Диск: 200GB+, CPU: 8+ ядер        │${NC}"
        echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        FREE_DISK=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
        
        if [ "$TOTAL_RAM" -lt 120 ]; then
            print_warning "У вас всего ${TOTAL_RAM}GB RAM, а требуется 128GB+"
            read -p "Продолжить установку? (y/N): " continue_grok
            if [[ "$continue_grok" != "y" && "$continue_grok" != "Y" ]]; then
                print_info "Установка отменена. Выберите другой вариант."
                exit 1
            fi
        fi
        
        if [ "$FREE_DISK" -lt 200 ]; then
            print_warning "У вас всего ${FREE_DISK}GB свободного диска, а требуется 200GB+"
            read -p "Продолжить установку? (y/N): " continue_grok
            if [[ "$continue_grok" != "y" && "$continue_grok" != "Y" ]]; then
                print_info "Установка отменена. Выберите другой вариант."
                exit 1
            fi
        fi
        
        print_info "Скачивание Grok 2 (это займёт много времени и места)..."
        ollama pull MichelRosselli/grok-2:Q4_K_M
        
    elif [[ "$MODEL" == "grok-3-api" ]]; then
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                    🦞 GROK 3 (API xAI)                      │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${NC}"
        echo -e "│  🔑 ДЛЯ ПОДКЛЮЧЕНИЯ НУЖЕН API-КЛЮЧ xAI:                         │${NC}"
        echo -e "│                                                             │${NC}"
        echo -e "│  1. Перейдите на https://console.x.ai                       │${NC}"
        echo -e "│  2. Зарегистрируйтесь / войдите                             │${NC}"
        echo -e "│  3. Создайте новый API-ключ                                 │${NC}"
        echo -e "│  4. Скопируйте ключ (начинается с xai-...)                  │${NC}"
        echo -e "│                                                             │${NC}"
        echo -e "│  💰 Стоимость: Grok 3: $3 за 1M токенов, $5 кредит при рег.│${NC}"
        echo -e "│  🌐 Подробнее: https://docs.x.ai/api                        │${NC}"
        echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        read -p "👉 Введите API-ключ xAI: " XAI_KEY
        
        if [ -n "$XAI_KEY" ]; then
            echo "USE_XAI=true" >> $CONFIG_FILE
            echo "XAI_API_KEY=\"$XAI_KEY\"" >> $CONFIG_FILE
            print_success "API-ключ xAI сохранён"
        else
            print_warning "API-ключ не введён, Grok 3 API не будет использоваться"
        fi
        
    elif [[ "$MODEL" == "grok-3-lib" ]]; then
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                    🦞 GROK 3 (grok3api)                     │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${NC}"
        echo -e "│  🔧 ДЛЯ ПОДКЛЮЧЕНИЯ НУЖЕН БРАУЗЕР GOOGLE CHROME:                │${NC}"
        echo -e "│  📌 Библиотека grok3api автоматически получает cookies          │${NC}"
        echo -e "│  ⚙️  Требования: Google Chrome, активная сессия в x.ai          │${NC}"
        echo -e "│  ✅ Плюсы: полностью бесплатно, поддержка генерации изображений │${NC}"
        echo -e "│  ⚠️  Минусы: требуется Google Chrome, может быть нестабильно    │${NC}"
        echo -e "└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "👉 Установить Google Chrome и grok3api? (y/N): " install_grok_lib
        if [[ "$install_grok_lib" == "y" || "$install_grok_lib" == "Y" ]]; then
            print_info "Установка Google Chrome..."
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
            apt update
            apt install -y google-chrome-stable
            
            print_info "Установка grok3api..."
            sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install grok3api
            
            echo "USE_GROK3API=true" >> $CONFIG_FILE
            print_success "grok3api установлен"
            
            echo ""
            echo -e "${YELLOW}👉 Первый запуск:${NC}"
            echo "   Для авторизации выполните:"
            echo "   sudo -u $JARVIS_USER python3 -c 'from grok3api.client import GrokClient; GrokClient()'"
            echo "   Откроется браузер, войдите в свой аккаунт x.ai"
        else
            print_warning "Установка grok3api пропущена"
        fi
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
    echo -e "🎤 TTS движок: ${GREEN}$TTS_ENGINE${NC}"
    if [[ "$TTS_ENGINE" != "none" ]]; then
        echo -e "🎤 TTS голос: ${GREEN}$TTS_VOICE${NC}"
    fi
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

    # Скачиваем модель только если это не Grok API варианты
    if [[ "$MODEL" != "grok-3-api" && "$MODEL" != "grok-3-lib" ]]; then
        print_info "Загрузка модели $MODEL..."
        ollama pull $MODEL
    fi

    # Устанавливаем whisper через pip (для распознавания речи)
    print_info "Установка Whisper для распознавания речи..."
    sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install openai-whisper

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
TTS_ENGINE="$TTS_ENGINE"
TTS_VOICE="$TTS_VOICE"
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

    # Установка TTS зависимостей
    if [[ "$TTS_ENGINE" == "edge" ]]; then
        print_info "Установка Edge TTS..."
        sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install edge-tts
    elif [[ "$TTS_ENGINE" == "silero" ]]; then
        print_info "Установка Silero TTS..."
        sudo -u $JARVIS_USER $JARVIS_DIR/venv/bin/pip install torch soundfile
    fi

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
    echo -e "  ${MAGENTA}15)${NC}  🎤 Настройка голосового ответа (TTS)"
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
        15) 
            echo ""
            read -p "👉 Выбрать TTS движок заново? (y/N): " reset_tts
            if [[ "$reset_tts" == "y" || "$reset_tts" == "Y" ]]; then
                select_tts_engine
                sed -i "s/TTS_ENGINE=.*/TTS_ENGINE=\"$TTS_ENGINE\"/" $CONFIG_FILE
                sed -i "s/TTS_VOICE=.*/TTS_VOICE=\"$TTS_VOICE\"/" $CONFIG_FILE
                systemctl restart jarvis-bot
                print_success "Настройки TTS обновлены"
            fi
            pause
            ;;
        0) exit 0 ;;
        *) print_warning "Неверный выбор"; pause ;;
    esac
done
