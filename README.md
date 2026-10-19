
[Русский](#RU)

#  Abiotic Factor — DualSense Adaptive Triggers & Haptics (Linux / SteamOS)
# EN
A modification for **Abiotic Factor** adding support for adaptive triggers, recoil, and dynamic radiation lightbar illumination for the **DualSense** controller on Linux and specifically SteamOS (Steam Deck).

> ⚠️ **Warning and Development Process:**  
> I am not a programmer, and this is my first experience writing Lua scripts. The mod is in **active development (WIP)**; unstable performance and missing features are possible.

> 🤖 **Use of AI in Development:**  
> Artificial intelligence was used during the creation of this project. However, the project was **not written by a neural network from start to finish**: the entire architecture and workflow logic were conceived and designed by me personally. AI was used primarily as a technical assistant - helping write functions and specific parts of the code, providing advice on UE4SS syntax, answering questions, and generating debugging tools (not included in the repository).

> 👥 **Multiplayer and Co-op:**  
> The mod **has not been tested at all in online or co-op** (because I am alone). All tests were carried out exclusively in single-player mode, and it will unlikely be tested in online mode.  
> There is a high probability that the mod will start picking up events from other players, but this is not certain.

---

### Features
* **Adaptive triggers:** individual resistance and recoil profiles for different weapons and tools (pistols, crossbow, industrial vacuum, drill, melee weapons) using `bow`, `weapon`, `vibration`, and `feedback` modes.
* **Radiation indicator via lightbar:** the controller's lightbar smoothly changes color depending on the contamination level ($0..50$):  
  **Green** $\to$ **Yellow** $\to$ **Orange** $\to$ **Red**.
* **Automatic reconnection (Watchdog):** if the controller goes to sleep on timeout, runs out of battery, or the cable disconnects - the background script detects the reconnection itself and instantly restores the appropriate trigger profile and lightbar color.
* **Ultra-fast transfer via RAM:** data transmission between Proton and Linux goes through shared memory (`/dev/shm`) and the kernel's built-in `inotify` mechanism. This provides near-zero latency, 0% CPU overhead, and completely eliminates SSD wear.

---

### System Requirements
* **OS:** Linux only (SteamOS, Arch, Ubuntu, Bazzite, Fedora, etc.).  
  *Windows is not supported.*
* **Controller:** Sony DualSense connected via **USB cable** or **Bluetooth**.
* **Software:**
  * [AF-UE4SS](https://github.com/igromanru/AF-UE4SS) installed in the game directory under Proton.
  * Python 3 (preinstalled on all Linux distributions and SteamOS).

---

### How It Works

1. **UE4SS (Lua):** intercepts in-game events (item switch, firing, melee swing, radiation change).
2. **RAM file (`/dev/shm/dualsense_state`):** an instant inter-process communication (IPC) bridge for passing commands from Proton to the Linux host system.
3. **Background daemon (`dualsense.py`):** listens for Linux kernel events via `inotify`, caches the current state, and directly controls the controller via `dualsensectl`.

---

### Installation and Setup

#### Step 1: Installing UE4SS (if not already installed)
1. Download the latest **AF-UE4SS** release from the [GitHub Releases](https://github.com/igromanru/AF-UE4SS) page.
2. Extract the archive contents into the game's executable directory:  
   `AbioticFactor/Binaries/Win64/`  
   *(Next to the `AbioticFactor-Win64-Shipping.exe` file).*

#### Step 2: Installing the Mod
1. Download the mod archive from the **Releases** page (the `.tar.gz` format is recommended to preserve file execution permissions).
2. Extract the archive into the `AbioticFactor/Binaries/Win64/` directory.

#### Step 3: Configuring Launch Options in Steam
To automatically start the daemon in the background when the game launches:

1. Open Steam Library $\to$ Right-click **Abiotic Factor** $\to$ **Properties** $\to$ **General** tab.
2. In the **Launch Options** field, enter:
```bash
WINEDLLOVERRIDES="dwmapi.dll=n,b" ./dualsense.sh %command%
```
*(Or simply `./dualsense.sh %command%` if you placed the launch script in the game's root directory).*

> **How it works:**  
> The `dualsense.sh` script starts the background Python process, after which Steam launches the game executable via `%command%`.

---

### Licenses and Acknowledgements
* The **[dualsensectl](https://github.com/nowrep/dualsensectl)** utility was created by developer **nowrep** and is distributed under the **GNU General Public License v2.0 (GPL-2.0)**.
* The project is based on the **[RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS)** platform and the **[AF-UE4SS](https://github.com/igromanru/AF-UE4SS)** fork by **igromanru**.




---
[English](#EN)
# RU

Модификация для **Abiotic Factor**, добавляющая поддержку адаптивных курков, отдачи и динамической подсветки радиации для геймпада **DualSense** под Linux и в частности SteamOS (Steam Deck).

> ⚠️ **Предупреждение и процесс разработки:**  
> Я не программист, и это мой первый опыт написания скриптов на Lua. Мод находится в **активной разработке (WIP)**, возможна не стабильная работа и отсутствие отдельных функций.

> 🤖 **Использование ИИ при разработке:**  
> В процессе создания проекта использовался искусственный интеллект. Однако проект **не написан нейросетью от начала до конца**: вся архитектура, логика работы придуманы и спроектированы мной лично. ИИ привлекался в основном в роли технического ассистента - для помощи в написании функций и отдельных частей кода, консультаций по синтаксису UE4SS и ответов на вопросы, и создавал инструменты для отладки (в репозиторий не входят).

> 👥 **Сетевой режим и кооператив:**  
> Мод **вообще не тестировался в онлайн и кооперативе** (ибо я один). Все тесты проводились исключительно в одиночном режиме и вряд ли будет испытываться в онлайн режиме.
> Велика вероятность, что мод начнёт подхватывать события от других игроком, но это не точно.

---

### Возможности
* **Адаптивные курки:** индивидуальные профили сопротивления и отдачи для разных видов оружия и инструментов (пистолеты, арбалет, строительный пылесос, дрель, холодное оружие) с использованием режимов `bow`, `weapon`, `vibration`, `feedback`.
* **Индикатор радиации на подсветке (Lightbar):** световая панель геймпада плавно меняет цвет в зависимости от уровня заражения ($0..50$):  
  **Зелёный** $\to$ **Жёлтый** $\to$ **Оранжевый** $\to$ **Красный**.
* **Автоматическое переподключение (Watchdog):** если геймпад уснул по тайм-ауту, сел аккумулятор или отошёл провод — фоновый скрипт сам перехватит включение и мгновенно вернёт нужный профиль курков и цвет подсветки.
* **Сверхбыстрый обмен через ОЗУ:** передача данных между Proton и Linux идёт через системную память (`/dev/shm`) и встроенный механизм `inotify` ядра. Это даёт околонулевую задержку, 0% нагрузки на процессор и полное отсутствие износа SSD.

---

### Системные требования
* **ОС:** Только Linux (SteamOS, Arch, Ubuntu, Bazzite, Fedora и др.).  
  *Windows не поддерживается.*
* **Контроллер:** Sony DualSense, подключенный по **USB-кабелю** или **Bluetooth**.
* **Программное обеспечение:**
  * Установленный [AF-UE4SS](https://github.com/igromanru/AF-UE4SS) в папке с игрой под Proton.
  * Python 3 (предустановлен во всех дистрибутивах Linux и SteamOS).

---

### Как это устроено

1. **UE4SS (Lua):** перехватывает игровые события внутри игры (смена предмета, выстрел, замах, изменение радиации).
2. **Файл в ОЗУ (`/dev/shm/dualsense_state`):** мгновенный межпроцессный мост (IPC) для передачи команд из-под Proton в систему Linux.
3. **Фоновый демон (`dualsense.py`):** ожидает события от ядра Linux через `inotify`, сохраняет текущее состояние в кэш и напрямую управляет геймпадом через `dualsensectl`.

---

### Установка и настройка

#### Шаг 1: Установка UE4SS (если ещё не установлен)
1. Скачайте актуальный релиз **AF-UE4SS** со страницы [GitHub Releases](https://github.com/igromanru/AF-UE4SS).
2. Распакуйте содержимое архива в папку исполняемых файлов игры:
   `AbioticFactor/Binaries/Win64/`  
   *(Рядом с файлом `AbioticFactor-Win64-Shipping.exe`).*

#### Шаг 2: Установка мода
1. Скачайте архив мода со страницы **Releases** (рекомендуется формат `.tar.gz`, чтобы сохранить права на исполнение файлов).
2. Распакуйте архив в папку `AbioticFactor/Binaries/Win64/`.

#### Шаг 3: Настройка параметров запуска в Steam
Чтобы демон запускался в фоне автоматически вместе со стартом игры:

1. Откройте библиотеку Steam $\to$ Правой кнопкой мыши по **Abiotic Factor** $\to$ **Свойства** $\to$ вкладка **Общие**.
2. В поле **Параметры запуска** вставьте:
```bash
WINEDLLOVERRIDES="dwmapi.dll=n,b" ./dualsense.sh %command%
```
*(Либо просто `./dualsense.sh %command%`, если вы поместили скрипт запуска в корневую папку игры).*

> **Как это работает:**  
> Скрипт `dualsense.sh` стартует фоновый процесс Python, после чего Steam через `%command%` запускает сам исполняемый файл игры.

---

### Лицензии и благодарности
* Утилита **[dualsensectl](https://github.com/nowrep/dualsensectl)** создана разработчиком **nowrep** и распространяется под свободной лицензией **GNU General Public License v2.0 (GPL-2.0)**.
* Проект базируется на платформе **[RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS)** и форке **[AF-UE4SS](https://github.com/igromanru/AF-UE4SS)** от **igromanru**.



---
