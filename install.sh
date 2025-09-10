#!/bin/bash
# OCR Screenshot Installer
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

install_deps() {
    source /etc/os-release
    case $ID in
        debian|ubuntu|pop)
            sudo apt update
            sudo apt install -y spectacle tesseract-ocr tesseract-ocr-rus tesseract-ocr-eng wl-clipboard libnotify-bin
            ;;
        arch|endeavouros)
            sudo pacman -S --needed spectacle tesseract tesseract-data-rus tesseract-data-eng wl-clipboard libnotify
            ;;
        *)
            echo -e "${RED}Неподдерживаемая ОС. Установите зависимости вручную.${NC}"
            exit 1
            ;;
    esac
}

install_script() {
    local install_dir="$HOME/.local/bin"
    local script_name="ocr_screen.sh"
    # ИСПРАВЛЕНО: правильный URL твоего репозитория
    local repo_url="https://raw.githubusercontent.com/mairangh/ocr_screen_ar_kde/main"
    
    mkdir -p "$install_dir"
    
    echo -e "${YELLOW}Скачиваем скрипт из $repo_url/$script_name${NC}"
    
    # Проверяем существует ли файл
    if curl --output /dev/null --silent --head --fail "$repo_url/$script_name"; then
        curl -sSL "$repo_url/$script_name" -o "$install_dir/$script_name"
        chmod +x "$install_dir/$script_name"
        echo -e "${GREEN}Скрипт успешно скачан${NC}"
    else
        echo -e "${RED}Ошибка: Не могу скачать скрипт с $repo_url/$script_name${NC}"
        echo -e "${YELLOW}Проверьте существует ли файл в репозитории${NC}"
        exit 1
    fi
    
    # Добавляем в PATH если нужно
    if ! grep -q "$install_dir" "$HOME/.bashrc"; then
        echo "export PATH=\"\$PATH:$install_dir\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}Добавили $install_dir в PATH${NC}"
    fi
}

# Создание ярлыка для KDE и автоматическая настройка горячей клавиши
set_hotkey() {
    echo -e "${YELLOW}Настройка горячих клавиш пока не реализована${NC}"
}

main() {
    echo -e "${GREEN}Устанавливаем OCR Screenshot Tool...${NC}"
    
    install_deps
    install_script
    #     if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    #         set_hotkey
    #     else
    echo -e "${GREEN}Установка завершена!${NC}"
    echo -e "${YELLOW}Добавьте горячую клавишу для: $HOME/.local/bin/ocr_screen.sh${NC}"
}

main "$@"
