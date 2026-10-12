#!/usr/bin/env bash

# Точный путь к корню игры
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Путь к папке нашего мода
MOD_DIR="$GAME_DIR/AbioticFactor/Binaries/Win64/ue4ss/Mods/AbioticHaptics"
DAEMON_SCRIPT="$MOD_DIR/dualsense.py"
DUALSENSECTL="$MOD_DIR/dualsensectl"


# Проверка: на месте ли файлы?
if [ ! -f "$DAEMON_SCRIPT" ]; then
    echo "[DualSense] ПРЕДУПРЕЖДЕНИЕ: $DAEMON_SCRIPT не найден!"
    echo "[DualSense] Запускаем игру без мода на курки."
    exec "$@"
fi

# Возвращаем права на запуск бинарнику (на случай, если слетели в архиве/гите)
chmod +x "$DUALSENSECTL" 2>/dev/null

# Функция гарантированного сброса при выходе из игры
cleanup() {
    echo "[DualSense] Выход из игры. Сброс эффектов..."
    "$DUALSENSECTL" trigger both off 2>/dev/null
    "$DUALSENSECTL" lightbar 0 0 255 2>/dev/null # вернуть спокойный синий
    kill "$DAEMON_PID" 2>/dev/null
}
trap cleanup EXIT

# Запускаем Python-демон
python3 "$DAEMON_SCRIPT" &
DAEMON_PID=$!


# Переменные для Proton
export PROTON_DISABLE_HIDRAW=1

# Запуск игры через переданные от Steam аргументы (%command%)
"$@"
