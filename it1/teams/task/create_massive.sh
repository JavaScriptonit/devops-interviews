#!/bin/bash

# Объявляем массив files
files=()

# Заполняем массив files списком файлов в текущей директории
for file in *; do
    files+=("$file")
done

# Выводим содержимое массива files
for ((i=0; i<${#files[@]}; i++)); do
    echo "Файл $i: ${files[i]}"
done
