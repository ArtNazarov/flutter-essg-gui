# flutter-essg-gui

GUI для приложения ArtNazarov/elixir-ssg для записи атрибутов страницы

# 📌 Обзор

Админ-панель на Flutter для управления контентом и генерации статических HTML-страниц. Приложение позволяет создавать веб-страницы через простой интерфейс, сохраняя данные в структурированных текстовых файлах. Сгенерированные страницы совместимы с [elixir-ssg](https://github.com/ArtNazarov/elixir-ssg)

![screenshot 1](https://dl.dropbox.com/scl/fi/e8r5lc14089lexscz1l1i/flutter-essg-1.png?rlkey=62grzqt2skyoju2pepil4zoyv&st=ivpscymy)
![screenshot 2](https://dl.dropbox.com/scl/fi/ldth7syt7a39ou6zi4avg/flutter-essg-2.png?rlkey=2nlpxcpb4v1wtqer3fsp6tmzy&st=29f8gui7)
![screenshot 3](https://dl.dropbox.com/scl/fi/3rlikeou4i2ivwmto19aw/flutter-essg-3.png?rlkey=lwcgp6ey44b5sctzjpfv9ubrr&st=a2tk9t2d)
![screenshot 4](https://dl.dropbox.com/scl/fi/zupn8961u3vbd5phvqkcy/flutter-essg-4.png?rlkey=x3hi6laq973veqhixf8jj19t3&st=g5fhav0t)

# ✨ Возможности

✅ Создание страниц через форму

- Поля для Заголовка, Описания, Заголовка статьи, Контента, Года и Автора

- Автоматически генерирует Page ID, если не указан

✅ Хранение в файловой системе

- Сохраняет каждый атрибут страницы в отдельный .txt файл

- Формат именования: {pageID}-{attribute}.txt

- Файлы хранятся в директории приложения (/data/)

✅ Кросс-платформенность

- Работает на Linux, Windows (WSL) и macOS

- Использует API файловой системы Flutter

✅ Валидация и обработка ошибок

- Проверяет заполнение обязательных полей

- Показывает уведомления об успехе/ошибке

# 🚀 Сборка и запуск

**Требования**

Flutter SDK (3.19.0 или новее)

Linux/macOS (Для Windows — WSL 2)

CMake (для сборки на Linux)

**Инструкция**

1. Клонировать репозиторий
```
git clone https://github.com/ArtNazarov/flutter-essg-gui.git
cd flutter-essg-gui
```

2. Установить зависимости
```
flutter pub get
```
3. Запустить приложение (Linux)
```
flutter run -d linux
```

4. Собрать релизную версию (опционально)
```
flutter build linux --release
```

(Результат в build/linux/x64/release/bundle)

# 📂 Структура проекта

```
.
├── lib/
│   ├── main.dart            # Точка входа
│   └── widgets/             # UI-компоненты
├── linux/                   # Файлы для сборки на Linux
├── data/                    # Сгенерированные файлы страниц
│   └── {pageId}-*.txt
├── pubspec.yaml             # Зависимости Flutter
└── README.md                # Этот файл
```

# 🔧 Решение проблем

1. Ошибки CMake Cache (после перемещения проекта)

Если видите:

```
CMake Error: The current CMakeCache.txt directory ... is different...
```


Решение:
```
flutter clean
rm -rf build/ linux/build/
flutter create --platforms=linux .
flutter run -d linux
```

2. Проблемы с правами на файлы

Дайте права на запись:
```
chmod +w -R data/
```

3. Где хранятся файлы?

Linux/macOS: ~/.local/share/{app_name}/data/

Windows (WSL): /mnt/c/Users/.../AppData/Roaming/{app_name}/data/

# 📜 Лицензия

MIT License. Подробнее в LICENSE.

# 👨‍💻 Автор

Назаров А.А.,
📧 awnlwt1ty@mozmail.com
🔗 GitHub: https://github.com/ArtNazarov

