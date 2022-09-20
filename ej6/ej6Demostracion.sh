#!/bin/bash

    if ! [ -x "$(command -v zip)" ]; then
    echo 'Error: paquete zip no instalado.'
        echo "Por favor use el comando [sudo apt install zip]"
    exit 1
    fi

if ! test -f "./ej6.sh"; then
    echo "No se encontro el archivo ej6.sh en el directorio actual."
else

    echo ""
    echo "touch a"
    touch a
    sleep 2
    echo ""

    echo "./ej6.sh --eliminar a"
    ./ej6.sh --eliminar a
    sleep 2
    echo ""

    echo "./ej6.sh --listar"
    ./ej6.sh --listar
    sleep 2
    echo ""

    echo "mkdir carpeta "
    mkdir carpeta
    sleep 2
    echo ""

    echo "touch carpeta/a #archivo con el mismo nombre pero otro directorio"
    touch carpeta/a
    sleep 2
    echo ""

    echo "./ej6.sh --eliminar carpeta/a"
    ./ej6.sh --eliminar carpeta/a
    sleep 2
    echo ""

    echo "./ej6.sh --listar"
    ./ej6.sh --listar
    sleep 2
    echo ""

    echo "./ej6.sh --recuperar a #se recuperará la opcion 1"
    sleep 2
    ./ej6.sh --recuperar a <<< 1
    sleep 2
    echo ""

     echo "./ej6.sh --vaciar"
    ./ej6.sh --vaciar
    sleep 2
    echo ""

    echo "./ej6.sh --listar"
    ./ej6.sh --listar
    echo ""

    rm -r carpeta
    rm a
fi