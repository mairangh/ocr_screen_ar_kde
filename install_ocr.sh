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
            sudo apt install -y spectacle tesseract-ocr tesseract-data-rus esseract-ocr-eng wl-clipboard libnotify-bin
            ;;
        arch|endeavouros)
            sudo pacman -S --needed spectacle tesseract tesseract-data-rus esseract-ocr-eng wl-clipboard libnotify
            ;;
        *)
            echo -e "${RED}Unsupported OS. Install dependencies manually.${NC}"
            exit 1
            ;;
    esac
}

install_script() {
    local install_dir="$HOME/.local/bin"
    local script_name="ocr_screen.sh"
    local repo_url="https://raw.githubusercontent.com/mairangh/ocr_screen_ar_kde/main"

    mkdir -p "$install_dir"
    curl -sSL "$repo_url/$script_name" -o "$install_dir/$script_name"
    chmod +x "$install_dir/$script_name"

    # Добавляем в PATH если нужно
    grep -q "$install_dir" "$HOME/.bashrc" || echo "export PATH=\"\$PATH:$install_dir\"" >> "$HOME/.bashrc"
}

# Создание ярлыка для KDE
# Создание ярлыка для KDE и автоматическая настройка горячей клавиши
set_hotkey() {

}


main() {
    echo -e "${GREEN}Installing OCR Screenshot Tool...${NC}"
    install_deps
    install_script
    echo -e "${GREEN}Installation complete!${NC}"
#     if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
#         set_hotkey
#     else
    echo -e "Add hotkey for: $HOME/.local/bin/ocr_screen.sh"

#     fi
}

main "$@"
