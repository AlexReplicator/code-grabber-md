# Code Grabber MD

[![Version](https://img.shields.io/badge/version-1.0-blue)](https://github.com/AlexReplicator/code-grabber-md)[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/AlexReplicator/code-grabber-md/blob/main/LICENSE)
## Оглавление

- [Описание](#%D0%BE%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5)
- [Подготовительный этап](#%D0%BF%D0%BE%D0%B4%D0%B3%D0%BE%D1%82%D0%BE%D0%B2%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9-%D1%8D%D1%82%D0%B0%D0%BF)
    - [Создание нового проекта](#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BD%D0%BE%D0%B2%D0%BE%D0%B3%D0%BE-%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%B0)
    - [Использование существующего проекта](#%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-%D1%81%D1%83%D1%89%D0%B5%D1%81%D1%82%D0%B2%D1%83%D1%8E%D1%89%D0%B5%D0%B3%D0%BE-%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%B0)
- [Установка](#%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0)
    - [Настройка Git для автоматического преобразования перевода строки](#%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-git-%D0%B4%D0%BB%D1%8F-%D0%B0%D0%B2%D1%82%D0%BE%D0%BC%D0%B0%D1%82%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B3%D0%BE-%D0%BF%D1%80%D0%B5%D0%BE%D0%B1%D1%80%D0%B0%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D0%B0-%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B8)
    - [Добавление в качестве подмодуля Git](#%D0%B4%D0%BE%D0%B1%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%B5-%D0%BF%D0%BE%D0%B4%D0%BC%D0%BE%D0%B4%D1%83%D0%BB%D1%8F-git)
    - [Запуск и конвертирование](#%D0%B7%D0%B0%D0%BF%D1%83%D1%81%D0%BA-%D0%B8-%D0%BA%D0%BE%D0%BD%D0%B2%D0%B5%D1%80%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5)
- [Использование](#%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5)
    - [Запуск скрипта](#%D0%B7%D0%B0%D0%BF%D1%83%D1%81%D0%BA-%D1%81%D0%BA%D1%80%D0%B8%D0%BF%D1%82%D0%B0)
    - [Пример использования](#%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F)
- [Удаление и обновление](#%D1%83%D0%B4%D0%B0%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B8-%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5)
    - [Удаление пакетов](#%D1%83%D0%B4%D0%B0%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D0%B0%D0%BA%D0%B5%D1%82%D0%BE%D0%B2)
    - [Обновление подмодуля](#%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D0%BE%D0%B4%D0%BC%D0%BE%D0%B4%D1%83%D0%BB%D1%8F)
- [Сценарии использования](#%D1%81%D1%86%D0%B5%D0%BD%D0%B0%D1%80%D0%B8%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F)
- [Лицензия](#%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F)

## Описание

**Code Grabber MD** — это Bash-скрипт, который сканирует указанный каталог, собирает содержимое всех текстовых файлов и сохраняет их в файл `output.md`. При этом учитываются правила из файла `exclude.conf` или `.gitignore` корневого каталога проекта. Это удобно для документирования, анализа кода или создания сводных файлов с исходным кодом.

## Подготовительный этап

### Создание нового проекта

Если ваш проект еще не создан и не подключен к Git:

```
mkdir -p /path/to/your/project/
git init
```

### Использование существующего проекта

Если проект уже создан и подключен к Git:

`cd /path/to/your/project/`

### Настройка Git для автоматического преобразования перевода строки

Создайте файл `.gitattributes` в корневой директории проекта с следующим содержимым:

`* text=auto`

## Установка

Сначала надо создать файл `excude.conf` в корневой директории проекта. Этот файл будет содержать список исключений, которые не будут включены в выходной файл.

**Пример файла  `excude.conf`:**

```
# Исключить директорию node_modules
node_modules

# Исключить файл text.txt
text.txt
```


Рекомендуется разместить скрипт в директории `./scripts/` вашего проекта:

```
mkdir -p scripts
```

### Добавление в качестве подмодуля Git

Чтобы добавить **Code Grabber MD** в свой проект в качестве подмодуля, выполните:

```
git submodule add https://github.com/AlexReplicator/code-grabber-md.git scripts/code-grabber-md
```

### Запуск и конвертирование

Нужно установить `dos2unix` и преобразовать файл. Это можно сделать так:

```
sudo apt install dos2unix
dos2unix scripts/code-grabber-md/grabber.sh
```


Сделайте файл скрипта исполняемым:

`chmod +x scripts/code-grabber-md/grabber.sh`

## Использование

### Запуск скрипта

Запустите скрипт:

`./scripts/code-grabber-md/grabber.sh`

> **Примечание:** Для установки необходимых пакетов может потребоваться ввод пароля суперпользователя.

При первом запуске скрипт установит пакеты `tree` и `ripgrep`, которые необходимы для его работы:

- **ripgrep**: Используется для эффективного поиска файлов с учетом правил `.gitignore`.
- **tree**: Используется для отображения структуры каталогов.

### Пример использования

Скрипт будет сканировать каталог `/path/to/your/project/` и собирать содержимое всех текстовых файлов в `output.md`.


## Удаление и обновление

### Удаление пакетов

Если необходимо удалить установленные пакеты `tree` и `ripgrep`, выполните:

`sudo apt purge tree ripgrep && sudo apt autoremove`

### Полное удаление подмодуля

Сначала переходим в основную папку проекта

```
git config -f .gitmodules --remove-section submodule.scripts/code-grabber-md
git config -f .git/config --remove-section submodule.scripts/code-grabber-md
git rm --cached scripts/code-grabber-md
rm -rf scripts/code-grabber-md
rm -rf .git/modules/scripts/code-grabber-md
```

### Обновление подмодуля

#### Все подмодули

Для обновления всех подмодулей до последней версии:

```
git submodule update --init --recursive --force
git submodule update --init --recursive
```

#### Только этот подмодуль

Для обновления только этого подмодуля:

```
git submodule update --init --recursive scripts/code-grabber-md 
git submodule status scripts/code-grabber-md 
cd scripts/code-grabber-md 
git pull origin main
cd ../../
dos2unix scripts/code-grabber-md/grabber.sh
chmod +x scripts/code-grabber-md/grabber.sh
./scripts/code-grabber-md/grabber.sh
```

## Сценарии использования

- **Документирование проекта:** Создание единого файла с исходным кодом для обзора или презентации.
- **Анализ кода:** Объединение всех текстовых файлов для статического анализа или проверки качества кода.
- **Архивирование:** Сохранение резервной копии исходного кода в удобочитаемом формате.