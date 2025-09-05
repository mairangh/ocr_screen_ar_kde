#!/bin/bash
# OCR Screenshot Installer

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка зависимостей
check_dependencies() {
    local deps=("spectacle" "tesseract" "wl-copy" "wl-paste" "notify-send")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}Необходимо установить отсутствующие зависимости:${NC} ${missing[*]}"
        return 1
    fi
    return 0
}

# Установка для Debian/Ubuntu
install_debian() {
    sudo apt update
    sudo apt install -y spectacle tesseract-ocr tesseract-ocr-rus wl-clipboard libnotify-bin
}

# Установка для Arch Linux
install_arch() {
    sudo pacman -S --needed spectacle tesseract tesseract-data-rus wl-clipboard libnotify
}

# Основная установка
install_ocr_tool() {
    # Определяем дистрибутив
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            debian|ubuntu|pop)
                install_debian
                ;;
            arch|endeavouros)
                install_arch
                ;;
            *)
                echo -e "${RED}Дистрибутив не поддерживается. Установите зависимости вручную.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${RED}Не удалось определить дистрибутив. Установите зависимости вручную.${NC}"
        exit 1
    fi
}

# Копирование скрипта
copy_script() {
    local script_dir="$HOME/.local/bin"
    local script_path="$script_dir/ocr_screen.sh"

    mkdir -p "$script_dir"
    cp "$0" "$script_path" && chmod +x "$script_path"
    
    # Добавляем в PATH если нужно
    if ! grep -q "$script_dir" "$HOME/.bashrc"; then
        echo "export PATH=\"\$PATH:$script_dir\"" >> "$HOME/.bashrc"
        echo -e "${YELLOW}Добавлен $script_dir в PATH. Выполните 'source ~/.bashrc'${NC}"
    fi
}

# Создание ярлыка для KDE
create_shortcut() {
    local shortcut_dir="$HOME/.local/share/khotkeys"
    local shortcut_file="$shortcut_dir/ocr_screen.khotkeys"

    mkdir -p "$shortcut_dir"
    cat > "$shortcut_file" << EOF
[Data]
DataCount=1

[Data_1]
Comment=OCR Screenshot
Enabled=true
Name=OCR Screenshot
Type=ACTION_DATA

[Data_1Actions]
ActionsCount=1

[Data_1Actions0]
CommandURL=$HOME/.local/bin/ocr_screen.sh
Type=COMMAND_URL

[Data_1Conditions]
ConditionsCount=0

[Data_1Triggers]
TriggersCount=1

[Data_1Triggers0]
Key=Alt+Shift+D
Type=SHORTCUT
Uuid={$(uuidgen)}
EOF

    echo -e "${GREEN}Ярлык создан. Для активации:${NC}"
    echo "1. Перейдите в System Settings > Shortcuts > Custom Shortcuts"
    echo "2. Нажмите 'Edit' > 'Import' и выбете файл:"
    echo "   $shortcut_file"
    echo "3. Нажмите 'Apply'"
}

main() {
    echo -e "${GREEN}Установка OCR Screenshot Tool...${NC}"

    # Проверяем и устанавливаем зависимости
    if ! check_dependencies; then
        install_ocr_tool
    fi

    # Копируем скрипт
    copy_script

    # Создаём ярлык для KDE
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        create_shortcut
    else
        echo -e "${YELLOW}Автоматическая настройка горячих клавиш доступна только для KDE Plasma.${NC}"
        echo "Для других DE настройте горячие клавиши вручную для команды:"
        echo "$HOME/.local/bin/ocr_screen.sh"
    fi

    echo -e "${GREEN}Установка завершена!${NC}"
    echo "Перезагрузите сессию или выполните: source ~/.bashrc"
}

main "$@"
