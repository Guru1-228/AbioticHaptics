#!/usr/bin/env python3

import ctypes
import os
import subprocess
import threading
import signal
import sys
import time

# --- 2. Кэш состояния ---
cache = {
    "lightbar": None,
    "trigger_left": None,
    "trigger_right": None,
}


def send_to_controller(args):
    """Просто вызывает dualsensectl с аргументами"""
    subprocess.run(
        [DUALSENSECTL] + args,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def process_line(line):
    """Понимает, что это за команда, обновляет кэш и отправляет в геймпад"""
    args = line.strip().split()
    if not args:
        return

    # А. Это команда подсветки
    if args[0] == "lightbar":
        cache["lightbar"] = args
        send_to_controller(args)

    # Б. Это команда курков
    elif args[0] == "trigger":
        side = args[1]  # left, right или both

        if side == "both":
            cache["trigger_left"] = ["trigger", "left"] + args[2:]
            cache["trigger_right"] = ["trigger", "right"] + args[2:]
        elif side == "left":
            cache["trigger_left"] = args
        elif side == "right":
            cache["trigger_right"] = args
        send_to_controller(args)


# --- 3. Сторожевой пёс: проверяет связь раз в 1.5 секунды ---
def watchdog():
    was_connected = False
    # lightbar init
    subprocess.run(["dualsensectl", "lightbar", "on"])
    time.sleep(1.5)
    subprocess.run(["dualsensectl", "lightbar", "off"])
    while True:
        # dualsensectl battery вернет 0, если геймпад есть, и 1, если его нет
        check = subprocess.run(
            [DUALSENSECTL, "battery"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        is_connected = check.returncode == 0

        # Момент подключения: его не было, и вот он появился!
        if is_connected and not was_connected:
            subprocess.run(["dualsensectl", "lightbar", "on"])
            time.sleep(2)
            subprocess.run(["dualsensectl", "lightbar", "off"])
            for cmd in cache.values():
                if cmd:
                    send_to_controller(cmd)

        was_connected = is_connected
        time.sleep(1.5)


# Подключаемся к главной библиотеке Linux (libc)
libc = ctypes.CDLL(None)

# 1. Создаём дескриптор inotify
fd = libc.inotify_init()

# 2. Магическое число события в ядре Linux:
# 0x00000008 — это константа IN_CLOSE_WRITE (файл был открыт на запись и закрыт)
IN_CLOSE_WRITE = 0x00000008

FILE_PATH = b"/dev/shm/dualsense_state"
DUALSENSECTL = str("dualsensectl")


# Проверить существование файла
if not os.path.exists(FILE_PATH):
    open(FILE_PATH, "a").close()


# 3. Регистрируем слежку
libc.inotify_add_watch(fd, FILE_PATH, IN_CLOSE_WRITE)


threading.Thread(target=watchdog, daemon=True).start()
while True:
    # 1. Ждём пинка от ядра (скрипт висит тут и спит, пока игра не запишет файл)
    os.read(fd, 1024)


    # 2. Ядро разбудило! Читаем, что записала игра:
    with open(FILE_PATH, "r") as f:
        for line in f:
            process_line(line)


# Функция красивого выхода
def on_exit(signum, frame):
    # Сбрасываем курки в ноль при закрытии игры
    subprocess.run(["dualsensectl", "trigger", "both", "off"])
    sys.exit(0)

# Регистрируем: если скрипт убивают командой kill — сначала выполнить on_exit
signal.signal(signal.SIGTERM, on_exit)
