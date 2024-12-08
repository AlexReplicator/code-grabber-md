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

# Функция для поиска корня проекта (директории, содержащей .gitignore, но не в той же папке, что и скрипт)
find_project_root() {
    dir="$1"
    script_dir="$2"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.gitignore" ] && [ "$dir" != "$script_dir" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    # Если .gitignore не найден, возвращаем оригинальную директорию
    echo "$1"
}

# Находим корень проекта, игнорируя .gitignore в директории скрипта
PROJECT_ROOT=$(find_project_root "$DIRECTORY" "$SCRIPT_DIR")

# Путь к exclude.conf
EXCLUDE_CONF="$PROJECT_ROOT/exclude.conf"

# Проверяем наличие exclude.conf
if [ -f "$EXCLUDE_CONF" ]; then
    echo "Используем exclude.conf для исключений."
    EXCLUSION_FILE="$EXCLUDE_CONF"
else
    echo "exclude.conf не найден. Используем .gitignore для исключений."
    EXCLUSION_FILE="$PROJECT_ROOT/.gitignore"
fi

# Определяем относительный путь директории скрипта относительно корня проекта
RELATIVE_SCRIPT_DIR=$(realpath --relative-to="$PROJECT_ROOT" "$SCRIPT_DIR")

# Проверяем, находится ли директория скрипта внутри корня проекта
IGNORE_DIR_PATTERN=""
if [[ "$RELATIVE_SCRIPT_DIR" != "." && "$RELATIVE_SCRIPT_DIR" != /* && "$RELATIVE_SCRIPT_DIR" != ".." ]]; then
    # Формируем паттерн для игнорирования директории скрипта
    IGNORE_DIR_PATTERN="$RELATIVE_SCRIPT_DIR/**"
    echo "Исключаем директорию скрипта: $IGNORE_DIR_PATTERN"
fi

# Добавляем структуру каталога в начало файла
echo "### Структура каталога относительно '$DIRECTORY'" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "```" >> "$OUTPUT"
tree "$DIRECTORY" >> "$OUTPUT"
echo "```" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Формируем команду rg
if [ -n "$IGNORE_DIR_PATTERN" ]; then
    RG_CMD=(rg --files "$PROJECT_ROOT" --ignore-file "$EXCLUSION_FILE" --ignore "$IGNORE_DIR_PATTERN")
else
    RG_CMD=(rg --files "$PROJECT_ROOT" --ignore-file "$EXCLUSION_FILE")
fi

# Выполняем rg и обрабатываем файлы
"${RG_CMD[@]}" | while IFS= read -r FILE; do
    # Пропускаем сам скрипт и файл вывода
    if [ "$FILE" = "$SCRIPT_PATH" ] || [ "$FILE" = "$OUTPUT_PATH" ]; then
        continue
    fi

    # Проверяем, находится ли файл внутри DIRECTORY или PROJECT_ROOT
    if [[ "$DIRECTORY" != "$PROJECT_ROOT" && "$FILE" != "$DIRECTORY/"* ]]; then
        continue
    fi

    # Проверяем, является ли файл текстовым
    if file "$FILE" | grep -qE 'text|empty'; then
        # Относительный путь файла от указанной директории
        RELATIVE_FILE=${FILE#"$DIRECTORY/"}

        echo "#### Файл: *$RELATIVE_FILE*" >> "$OUTPUT"
        echo "```" >> "$OUTPUT"
        # Добавляем четыре пробела перед каждой строкой содержимого файла
        awk '{print "    " $0}' "$FILE" >> "$OUTPUT"
        echo "```" >> "$OUTPUT"
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