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
EXCLUDE_CONF="$SCRIPT_DIR/exclude.conf"

# Проверяем наличие exclude.conf
if [ ! -f "$EXCLUDE_CONF" ]; then
    echo "Ошибка: файл исключений exclude.conf не найден в директории скрипта."
    exit 1
fi

# Определяем относительный путь директории скрипта относительно корня проекта
RELATIVE_SCRIPT_DIR=$(realpath --relative-to="$PROJECT_ROOT" "$SCRIPT_DIR")

# Проверяем, находится ли директория скрипта внутри корня проекта
if [[ "$RELATIVE_SCRIPT_DIR" == "$PROJECT_ROOT" || "$RELATIVE_SCRIPT_DIR" == /* ]]; then
    echo "Ошибка: не удалось определить относительный путь директории скрипта относительно корня проекта."
    exit 1
fi

# Если скрипт находится внутри корня проекта, добавляем его директорию в список игнорируемых
IGNORE_DIR_OPTION=""
if [ "$RELATIVE_SCRIPT_DIR" != "." ]; then
    IGNORE_DIR_OPTION="--ignore-dir=$RELATIVE_SCRIPT_DIR"
else
    # Если скрипт находится в корне проекта, нельзя игнорировать '.', поэтому будем игнорировать только файлы и поддиректории
    echo "Скрипт находится в корне проекта. Все файлы и директории рядом с ним будут автоматически игнорироваться."
    IGNORE_DIR_OPTION=""
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

# Используем rg для получения списка файлов с учётом exclude.conf из PROJECT_ROOT и исключаем директорию скрипта
if [ -n "$IGNORE_DIR_OPTION" ]; then
    rg_cmd=(rg --files "$PROJECT_ROOT" --ignore-file "$EXCLUDE_CONF" "$IGNORE_DIR_OPTION")
else
    rg_cmd=(rg --files "$PROJECT_ROOT" --ignore-file "$EXCLUDE_CONF")
fi

"${rg_cmd[@]}" | while IFS= read -r FILE; do
    # Проверяем, находится ли файл в указанной директории
    if [[ "$FILE" != "$PROJECT_ROOT/"* ]]; then
        continue
    fi

    # Приводим файл к относительному пути от PROJECT_ROOT
    RELATIVE_FILE=${FILE#"$PROJECT_ROOT/"}

    # Проверяем, находится ли файл в DIRECTORY или его поддиректориях
    if [[ "$RELATIVE_FILE" != "${DIRECTORY#$PROJECT_ROOT}/"* && "$PROJECT_ROOT" != "$DIRECTORY" ]]; then
        continue
    fi

    # Пропускаем сам скрипт и файл вывода
    if [ "$FILE" = "$SCRIPT_PATH" ] || [ "$FILE" = "$OUTPUT_PATH" ]; then
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