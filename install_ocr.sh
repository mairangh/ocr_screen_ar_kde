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
    sudo apt install -y spectacle tesseract-ocr tesseract-ocr-rus esseract-ocr-eng wl-clipboard libnotify-bin
}

# Установка для Arch Linux
install_arch() {
    sudo pacman -S --needed spectacle tesseract tesseract-data-rus esseract-ocr-eng wl-clipboard libnotify
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
    local current_dir="$(dirname "$(realpath "$0")")"  # Получаем абсолютный путь к директории install_ocr.sh
    local source_script="$current_dir/ocr_screen.sh"   # Полный путь к ocr_screen.sh

    # Проверяем существование исходного скрипта
    if [[ ! -f "$source_script" ]]; then
        echo -e "${RED}Ошибка: $source_script не найден!${NC}"
        exit 1
    fi

    mkdir -p "$script_dir"
    cp "$source_script" "$script_path" && chmod +x "$script_path"  # Копируем ocr_screen.sh, а не текущий скрипт
    echo -e "${GREEN}Скрипт ocr_screen.sh скопирован в $script_path${NC}"

    # Добавляем в PATH если нужно
    if ! grep -q "$script_dir" "$HOME/.bashrc"; then
        echo "export PATH=\"\$PATH:$script_dir\"" >> "$HOME/.bashrc"
        echo -e "${YELLOW}Добавлен $script_dir в PATH. Выполните 'source ~/.bashrc'${NC}"
    fi
}

# Создание ярлыка для KDE
# Создание ярлыка для KDE и автоматическая настройка горячей клавиши
set_hotkey() {

}


main() {
    echo -e "${GREEN}Установка OCR Screenshot Tool...${NC}"

    # Проверяем и устанавливаем зависимости
    if ! check_dependencies; then
        install_ocr_tool
    fi

    # Копируем скрипт
    copy_script

    #
#     if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
#         set_hotkey
#     else
        echo "Настройте в ручную горячие клавиши на файл"
        echo "$HOME/.local/bin/ocr_screen.sh"
#     fi

    echo -e "${GREEN}Установка завершена!${NC}"
}

main "$@"
