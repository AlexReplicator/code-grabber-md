# Code Grabber MD

[![Version](https://img.shields.io/badge/version-1.0-blue)](https://github.com/AlexReplicator/code-grabber-md)[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/AlexReplicator/code-grabber-md/blob/main/LICENSE)

## Оглавление

## Описание

**Code Grabber MD** — это Bash-скрипт, который сканирует указанный каталог, собирает содержимое всех текстовых файлов и сохраняет их в файл `output.md`. При этом учитываются правила из файла `.gitignore` корневого каталога проекта. Это удобно для документирования, анализа кода или создания сводных файлов с исходным кодом.

## Подготовительный этап

Если ваш проект еще не создан и не подключен к GIT

```
mkdir -p /path/to/your/project/
git init
```

Если проект уже создан и подключен к GIT

```
cd /path/to/your/project/
```
## Установка
Рекомендуется разместить скрипт в директории `./scripts/` вашего проекта:

```
mkdir -p scripts
cd scripts
```

Настройка Git для автоматического преобразования перевода строки
Создайте файл `.gitattributes` в корневой директории проекта с следующим содержимым:

```
* text=auto
```

### Добавление в качестве подмодуля Git

Чтобы добавить `Code Grabber MD ` в свой проект в качестве подмодуля, выполните:

`git submodule add https://github.com/AlexReplicator/code-grabber-md.git scripts/code-grabber-md`

### Запуск и конвертирование

Нужно установить dos2unix и преобразовать файл. Это можно сделать так:

```
sudo apt install dos2unix
dos2unix scripts/code-grabber-md/grabber.sh
```

Сделайте файл скрипта исполняемым:

`chmod +x scripts/code-grabber-md/grabber.sh`

## Использование

### Запуск скрипта

Перейдите в каталог вашего проекта:

```
cd /path/to/your/project/
```

Запустите скрипт:

```
./scripts/code-grabber-md/grabber.sh
```

>**Примечание:** Для установки необходимых пакетов может потребоваться ввод пароля суперпользователя.

При первом запуске скрипт установит пакеты `tree` и `ripgrep`, которые необходимы для его работы:

- **ripgrep**: Используется для эффективного поиска файлов с учетом правил .gitignore.
- **tree**: Используется для отображения структуры каталогов.

### Пример использования

Скрипт будет сканировать каталог `/path/to/your/project/` и собирать содержимое всех текстовых файлов в output.md.

## Удаление и обновление

### Удаление пакетов

Если необходимо удалить установленные пакеты `tree` и `ripgrep`, выполните:

```
sudo apt purge tree ripgrep && sudo apt autoremove
```

### Обновление подмодуля

#### Все подмодули

Для обновления всех подмодулей до последней версии:

```
git submodule update --init --recursive
```

#### Только этот подмодуль

Для обновления только этого подмодуля:

```
git submodule update --init --recursive scripts/code-grabber-md
git submodule status scripts/code-grabber-md
cd scripts/code-grabber-md
git pull origin main
```


## Сценарии использования

**Документирование проекта:** Создание единого файла с исходным кодом для обзора или презентации.
**Анализ кода:** Объединение всех текстовых файлов для статического анализа или проверки качества кода.
**Архивирование:** Сохранение резервной копии исходного кода в удобочитаемом формате.