#!/usr/bin/env python3

import os
import subprocess
import sys

def check_file_exists():
    """Проверяет что файл DO существует"""
    do_path = "code-samples/DO"
    print(f"Проверяю существование файла: {do_path}")
    print(f"Текущая директория: {os.getcwd()}")
    print(f"Содержимое текущей директории: {os.listdir('.')}")
    
    if os.path.exists('code-samples'):
        print(f"Содержимое code-samples: {os.listdir('code-samples')}")
    else:
        print("Папка code-samples не существует!")
        return False
    
    if not os.path.exists(do_path):
        print("Файл DO не найден!")
        return False
    
    print("Файл DO найден")
    return True

def run_test(command, should_fail=False):
    """Запускает тест и проверяет результат"""
    print(f"Запускаю: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    print(f"Статус: {result.returncode}")
    print(f"Вывод: {result.stdout.strip()}")
    if result.stderr:
        print(f"Ошибки: {result.stderr.strip()}")
    
    if should_fail:
        if result.returncode == 0:
            print(f"Ошибка: {command} - должна быть ошибка!")
            return False
        return True
    else:
        if result.returncode != 0:
            print(f"Ошибка: {command} - код возврата: {result.returncode}")
            return False
        return True

# Главная функция
def main():
    print("=== ИНТЕГРАЦИОННЫЕ ТЕСТЫ ===")
    
    if not check_file_exists():
        sys.exit(1)
    
    print("\n=== ЗАПУСК ТЕСТОВ ===")
    
    # Тесты
    tests = [
        ("./code-samples/DO", True, "Без аргументов - ошибка"),
    ]
    
    # Добавляем тесты с аргументами 1-6
    for i in range(1, 7):
        tests.append((f"./code-samples/DO {i}", False, f"Аргумент {i}"))
    
    tests.extend([
        ("./code-samples/DO 999", True, "Неправильный аргумент - ошибка"),
        ("./code-samples/DO -1", True, "Отрицательный аргумент - ошибка"),
    ])
    
    all_passed = True
    for command, should_fail, description in tests:
        print(f"\n--- {description} ---")
        if run_test(command, should_fail):
            print(f"{description} - ПРОЙДЕН")
        else:
            print(f"{description} - НЕ ПРОЙДЕН")
            all_passed = False
    
    if all_passed:
        print("\n=== ВСЕ ТЕСТЫ ПРОЙДЕНЫ! ===")
        sys.exit(0)
    else:
        print("\n=== ТЕСТЫ НЕ ПРОЙДЕНЫ! ===")
        sys.exit(1)

# Запуск
if __name__ == "__main__":
    main()