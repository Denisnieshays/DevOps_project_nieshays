#!/bin/bash

# Импорт функций
source ./system_info.sh
source ./memory_info.sh
source ./disk_info.sh
source ./file_operations.sh

# Основное выполнение
get_system_info
get_network_info
get_memory_info
get_disk_info

ask_to_save