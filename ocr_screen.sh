#!/bin/bash

detect_display_server() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        echo "wayland"
    elif [ -n "$DISPLAY" ]; then
        echo "x11"
    else
        echo "unknown"
    fi
}

OCR_TEXT() {
    local TEMP_IMG="$1"
    TEXT=$(tesseract "$TEMP_IMG" stdout -l eng+rus 2>/dev/null)
    # Удаляем завершающий перевод строки
    if [ "${TEXT: -1}" = $'\n' ]; then
        TEXT="${TEXT%$'\n'}"
    fi
    printf '%s' "$TEXT"
}

DISPLAY_SERVER=$(detect_display_server)
TEMP_IMG=$(mktemp --suffix=.png)

echo "Определена графическая среда: $DISPLAY_SERVER"

case "$DISPLAY_SERVER" in
    "x11")
        rm -f "$TEMP_IMG"
        scrot -s "$TEMP_IMG" 2>/dev/null

        if [ -s "$TEMP_IMG" ]; then
            TEXT=$(tesseract "$TEMP_IMG" stdout -l eng+rus 2>/dev/null)
            TEXT="${TEXT%$'\n'}"

            if [ "$SESSION_TYPE" = "wayland" ]; then
                printf '%s' "$TEXT" | wl-copy
            else
                printf '%s' "$TEXT" | xclip -selection clipboard
            fi

            notify-send "OCR" "Текст скопирован в буфер!"
        else
            notify-send "OCR Error" "Не удалось получить изображение"
        fi
        ;;

    "wayland")
        # Очистить буфер
        echo -n "" | wl-copy
        sleep 0.01
        # Сделать скриншот в буфер
        spectacle -b -r -n
        # Ждать пока пользователь сделает выделение и spectacle завершит работу
        sleep 0.01
        # Попытаться извлечь изображение (до 5 попыток)
        for i in {1..5}; do
            echo "Попытка $i извлечь изображение..."
            if wl-paste --list-types | grep -q "image/"; then
                # Извлечь с правильным типом
                wl-paste --type image/png > "$TEMP_IMG" 2>/dev/null || \
                wl-paste --type "$(wl-paste --list-types | grep image/ | head -1)" > "$TEMP_IMG"
                if [ -s "$TEMP_IMG" ]; then
                    echo "Изображение получено, размер: $(stat -c%s "$TEMP_IMG")"
                    break
                fi
            fi
            sleep 0.3
        done

        # Проверить результат
        if [ -s "$TEMP_IMG" ]; then
            TEXT=$(OCR_TEXT "$TEMP_IMG")
            printf '%s' "$TEXT" | wl-copy
            notify-send "OCR" "Текст скопирован в буфер!"
        else
            notify-send "OCR Error" "Не удалось получить изображение"
        fi
        ;;

    *)
        echo "Ошибка: Не удалось определить графическую среду"
        echo "Убедитесь, что вы находитесь в сессии X11 или Wayland"
        rm "$TEMP_IMG"
        exit 1
        ;;
esac

rm "$TEMP_IMG"
