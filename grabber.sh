#!/usr/bin/env bash

# Функция для проверки наличия команды
check_command() {
    COMMAND_NAME=$1
    if ! command -v "$COMMAND_NAME" &> /dev/null; then
        return 1
    fi
    return 0
}

# Массив для хранения отсутствующих пакетов
MISSING_PACKAGES=()

# Проверяем наличие необходимых команд и добавляем отсутствующие пакеты в массив
if ! check_command "rg"; then
    MISSING_PACKAGES+=("ripgrep")
fi

if ! check_command "tree"; then
    MISSING_PACKAGES+=("tree")
fi

if ! check_command "realpath"; then
    MISSING_PACKAGES+=("realpath")
fi

# Если есть отсутствующие пакеты, пытаемся установить их
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "Необходимые пакеты не найдены: ${MISSING_PACKAGES[@]}"
    echo "Пытаюсь установить отсутствующие пакеты..."
    if ! sudo apt-get update; then
        echo "Ошибка: не удалось обновить список пакетов."
        exit 1
    fi
    if ! sudo apt-get install -y "${MISSING_PACKAGES[@]}"; then
        echo "Ошибка: не удалось установить пакеты: ${MISSING_PACKAGES[@]}"
        exit 1
    fi

    # Проверяем снова наличие команд после установки
    for PACKAGE in "${MISSING_PACKAGES[@]}"; do
        case $PACKAGE in
            ripgrep)
                COMMAND_NAME="rg"
                ;;
            tree)
                COMMAND_NAME="tree"
                ;;
            realpath)
                COMMAND_NAME="realpath"
                ;;
            *)
                COMMAND_NAME="$PACKAGE"
                ;;
        esac
        if ! check_command "$COMMAND_NAME"; then
            echo "Ошибка: команда $COMMAND_NAME не найдена после установки $PACKAGE."
            exit 1
        fi
    done
fi

# Директория для обработки (по умолчанию текущая директория)
DIRECTORY=${1:-.}

# Приводим DIRECTORY к абсолютному пути
DIRECTORY=$(realpath "$DIRECTORY")

# Получаем путь до текущего скрипта
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# Файл вывода
OUTPUT="output.md"
OUTPUT_PATH=$(realpath "$OUTPUT")

# Очистим файл вывода перед началом
> "$OUTPUT"

# Функция для поиска корня проекта
find_project_root() {
    dir="$1"
    script_dir="$2"
    while [ "$dir" != "/" ]; do
        # Сначала проверяем наличие exclude.conf
        if [ -f "$dir/exclude.conf" ] && [ "$dir" != "$script_dir" ]; then
            echo "$dir"
            return
        fi
        # Затем проверяем наличие .gitignore
        if [ -f "$dir/.gitignore" ] && [ "$dir" != "$script_dir" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    # Если ни exclude.conf, ни .gitignore не найдены, возвращаем исходную директорию
    echo "$1"
}

# Находим корень проекта
PROJECT_ROOT=$(find_project_root "$DIRECTORY" "$SCRIPT_DIR")

# Определяем файл исключений
if [ -f "$PROJECT_ROOT/exclude.conf" ]; then
    EXCLUDE_FILE="$PROJECT_ROOT/exclude.conf"
    USE_EXCLUDE_CONF=true
elif [ -f "$PROJECT_ROOT/.gitignore" ]; then
    EXCLUDE_FILE="$PROJECT_ROOT/.gitignore"
    USE_EXCLUDE_CONF=false
else
    EXCLUDE_FILE=""
fi

# Добавляем структуру каталога в начало файла
echo "### Структура каталога относительно '$DIRECTORY'" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "\`\`\`" >> "$OUTPUT"
tree "$DIRECTORY" >> "$OUTPUT"
echo "\`\`\`" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Формируем опции для ripgrep
RG_OPTIONS=("--files")

# Добавляем --ignore-file, если есть файл исключений
if [ -n "$EXCLUDE_FILE" ]; then
    RG_OPTIONS+=("--ignore-file" "$EXCLUDE_FILE")
fi

# Исключаем директорию скрипта
REL_SCRIPT_DIR=${SCRIPT_DIR#"$PROJECT_ROOT/"}
if [ -n "$REL_SCRIPT_DIR" ] && [ "$REL_SCRIPT_DIR" != "$PROJECT_ROOT" ]; then
    RG_OPTIONS+=("--glob" "!$REL_SCRIPT_DIR/**")
fi

# Используем rg для получения списка файлов с учетом исключений
rg "${RG_OPTIONS[@]}" "$DIRECTORY" | while IFS= read -r FILE; do
    # Пропускаем сам скрипт и файл вывода
    if [ "$FILE" = "$SCRIPT_PATH" ] || [ "$FILE" = "$OUTPUT_PATH" ] || [ "$FILE" = "$EXCLUDE_FILE" ]; then
         continue
    fi

    # Проверяем, является ли файл текстовым
    if file "$FILE" | grep -qE 'text|empty'; then
        # Относительный путь файла от указанной директории
        RELATIVE_FILE=${FILE#"$DIRECTORY/"}

        echo "#### Файл: *$RELATIVE_FILE*" >> "$OUTPUT"
        echo "\`\`\`" >> "$OUTPUT"
        # Добавляем четыре пробела перед каждой строкой содержимого файла
        awk '{print "    " $0}' "$FILE" >> "$OUTPUT"
        echo "\`\`\`" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "---" >> "$OUTPUT"
    else
        echo "Пропущен бинарный файл: $FILE"
    fi
done

# Подсчитываем количество символов
TOTAL_CHARS=$(wc -m < "$OUTPUT")
TOTAL_CHARS_NO_SPACES=$(tr -d '[:space:]' < "$OUTPUT" | wc -c)

# Добавляем информацию в конец файла
echo "" >> "$OUTPUT"
echo "#### Статистика" >> "$OUTPUT"
echo "Количество символов в итоговом файле: $TOTAL_CHARS знаков." >> "$OUTPUT"
echo "Символов без пробелов: $TOTAL_CHARS_NO_SPACES знаков." >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "Содержимое всех файлов сохранено в $OUTPUT"