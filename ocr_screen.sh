#!/bin/bash

TEMP_IMG=$(mktemp --suffix=.png)

# Очистить буфер
echo -n "" | wl-copy
sleep 0.1

# Сделать скриншот в буфер
spectacle -b -r -n

# Ждать пока пользователь сделает выделение и spectacle завершит работу
sleep 0.1

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
    TEXT=$(tesseract "$TEMP_IMG" stdout -l eng+rus 2>/dev/null)
    if [ "${TEXT: -1}" = $'\n' ]; then
        TEXT="${TEXT%$'\n'}"
    fi
    printf '%s' "$TEXT" | wl-copy
    notify-send "OCR" "Текст скопирован в буфер!"
else
    notify-send "OCR Error" "Не удалось получить изображение"
fi

rm "$TEMP_IMG"
