#!/bin/bash

if [ ! -f "./ej3.sh" ]; then
    echo "ERROR: Este script debe ejecutarse en la misma carpeta donde está alojado el script ej3.sh"
else
    echo "./ej3.sh -c ./ -a listar"
    ./ej3.sh -c ./ -a listar
    sleep 2
    echo ""

    echo ""
    echo "touch a #va a parecer un mensaje de modificacion, es un error conocido y registrado en help"
    touch a
    sleep 2
    echo ""


    echo "rm a"
    rm a
    sleep 2
    echo ""

    echo "mkdir carpeta"
    mkdir carpeta
    sleep 2
    echo ""

    echo "touch carpeta/a"
    touch carpeta/a
    sleep 2
    echo ""

    echo "touch carpeta/b"
    touch carpeta/b
    sleep 2
    echo ""

    echo "mv carpeta/a carpeta/b"
    mv carpeta/a carpeta/b
    sleep 2
    echo ""

    echo "rm -r carpeta #carpeta tiene el archivo "a" adentro"
    rm -r carpeta
    sleep 2
    echo ""

    echo "pkill ej3.sh"
    pkill ej3.sh
fi