#!/usr/bin/env python3

import ctypes
import os
import subprocess
import signal
import sys

# Подключаемся к главной библиотеке Linux (libc)
libc = ctypes.CDLL(None)

# 1. Создаём дескриптор inotify
fd = libc.inotify_init()

# 2. Магическое число события в ядре Linux:
# 0x00000008 — это константа IN_CLOSE_WRITE (файл был открыт на запись и закрыт)
IN_CLOSE_WRITE = 0x00000008

FILE_PATH = b"/dev/shm/dualsense_state"
DUALSENSECTL = str("dualsensectl")

# 3. Регистрируем слежку
libc.inotify_add_watch(fd, FILE_PATH, IN_CLOSE_WRITE)



while True:
    # 1. Ждём пинка от ядра (скрипт висит тут и спит, пока игра не запишет файл)
    os.read(fd, 1024)

    # 2. Ядро разбудило! Читаем, что записала игра:
    with open(FILE_PATH, "r") as f:
        for line in f:
            cmd_args = line.strip().split()
            if cmd_args:
                subprocess.run([DUALSENSECTL] + cmd_args)


# Функция красивого выхода
def on_exit(signum, frame):
    # Сбрасываем курки в ноль при закрытии игры
    subprocess.run(["dualsensectl", "trigger", "both", "off"])
    sys.exit(0)

# Регистрируем: если скрипт убивают командой kill — сначала выполнить on_exit
signal.signal(signal.SIGTERM, on_exit)
