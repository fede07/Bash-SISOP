#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej2.sh
# Número de APL: 1
# Número de Ejercicio: 2
# Número de Entrega: Primera reentrega

# ==============================================================

# ------------------------ Integrantes ------------------------
#
#        Nombre      |        Apellido          |      DNI
#        Gianluca    |        Espíndola         |   38.585.140
#        Juan        |        Diaz              |   38.958.153
#        Micaela     |        Dato Firpo        |   39.830.964
#        Melina      |        Sanson            |   42.362.352
#        Federico    |        Rossendy          |   37.804.899
#
# -------------------------------------------------------------

#el archivo de ordena primero alfabeticamente por nombre, y despues por fecha hora

Usage() {
    echo "   Uso:"
    echo "    $0 [opciones]"
    echo -e "    $0 -l|--logs [ruta]\n" #-e sirve para reconocer el \n y demas caracteres de escape
    echo "    Analiza los archivos de registro de llamadas .log en la ruta especificada"
    echo -e "    y devuelve la siguiente información:\n"
    echo "    1. Promedio de tiempo de las llamadas realizadas por día."
    echo "    2. Promedio de tiempo y cantidad por usuario por día."
    echo "    3. Los 3 usuarios con más llamadas en la semana."
    echo "    4. Cuántas llamadas no superan la media de tiempo por día."
    echo -e "    5. El usuario que tiene más cantidad de llamadas por debajo de la media en la semana.\n"
    echo "   Opciones:"
    echo "    -l, --logs [ruta]        analiza y procesa los registros .log en la ruta especificada"
    echo "    -h, --help              muestra esta información y termina la ejecución."
    echo "  Notas:"
    echo "      Solo funciona con logs de registros de maximo 5 dias (semana laboral)."
    echo -e "      Solo horario laboral. Si una llamada inicia un dia y finaliza al siguiente no sera contabilizada.
      Se asume que las fechas siempre son válidas.
      Los nombres de usuario distinguen de minúsculas y mayúsculas."
    exit 0
}
#un usuario podria no estar un dia pero siempre van del dia 1 al 5 sin saltos

numArgs=$#

#-a sirve para decirle que los parametros cortos tambien se pueden mandar con la inicial
ARGUMENTS=$(getopt -a -o '' --long help,logs: -- "$@" 2>/dev/null)
retorno=$?
if [ $retorno -ne 0 ] || [ $# -eq 0 ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
fi

HELP=0
RUTA=""
eval set -- "$ARGUMENTS"
while true; do
    case "$1" in
    --help)
        HELP=1
        shift 2
        break
        ;;
    --logs)
        RUTA="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opción inesperada: $1 - esto no debería suceder."
        exit 1
        ;;
    esac
done

if [ $HELP -eq 1 ]; then
    Usage
fi

if [ $numArgs -eq $# ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
fi

if [ ! -d "${RUTA}" ]; then
    echo "Error: La ruta especificada no existe." 1>&2
    exit 2
fi

if [ ! -r "${RUTA}" ]; then
    echo "Error: No tiene permisos de lectura en la ruta especificada." 1>&2
    exit 2
fi

cantArchivos=0
for archivo in $(ls "${RUTA}" | egrep '\.log$'); do
    ((cantArchivos++))
    temp=$(cat "${RUTA}"/"${archivo}")
    temp=$(echo "$temp" | awk -e '$0 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}-[a-zA-Z]+/ {print $0}')
    temp=$(echo "$temp" | sed 's/-/\ /3')$'\n'
    resFinal+="$temp"
done

if [ $cantArchivos -eq 0 ]; then
    echo "Error: No hay archivos de registro .log en la ruta especificada $RUTA" 1>&2
    exit 3
fi

if test -z "$resFinal"; then
    echo "No se encontraron registros válidos para procesar."
else
    resFinal=$(echo "$resFinal" | sed '/^ *$/d' | sort -k1,1 -k3,3 -k2,2)

    registroActual=$(echo "$resFinal" | head -1)

    IFS=$'\n'

    #punto 1
    declare -A mapPunto1
    arrayCantidadLlamadasPorDia=(0 0 0 0 0)
    arrayTiempoLlamadasPorDia=(0 0 0 0 0)
    arrayPromPorDia=(0 0 0 0 0)
    arrayIndice=0
    tiempoLlamadasPorDia=0
    cantidadLlamadasPorDia=0
    tiempoLlamadasPorDiaAux=0
    cantidadLlamadasPorDiaAux=0

    #punto 2
    punto2=""
    cantLlamadasUsuarioProcesado=0
    duracionLlamadaProcesada=0

    #punto 4
    diaDuracionUsuario=""
    declare -A mapPunto4

    #punto 5
    cantidadLlamadasSemana=0 #para sacar un promedio de la semana
    cantDias=0
    #duracionLlamadasSemana=0 #para sacar un promedio de la semana

    #otras
    inicioYFinRegistrados=0
    primerDia=0 #para validar limite de 5 dias consecutivos
    semanaSegundos=`expr 86400 \* 4` #para evitar calcularlo constantemente, se usa en validaciones
    diaInvalido=0
    #en caso de que un mismo usuario tenga varios registros seguidos forza la actualizacion del
    #registro de inicio de llamada

    # echo "$resFinal"
    for registroSiguiente in $(echo "$resFinal" | tail -n +2); do
        usuarioSiguiente=$(echo "$registroSiguiente" | grep -o '[^ ]*$')
        diaSiguiente=$(echo "$registroSiguiente" | cut -d '-' -f 3 | cut -d ' ' -f 1)
        usuarioActual=$(echo "$registroActual" | grep -o '[^ ]*$')
        diaActual=$(echo "$registroActual" | cut -d '-' -f 3 | cut -d ' ' -f 1)

        if [ $diaSiguiente -eq $diaActual ]; then
            if [ $inicioYFinRegistrados -eq 1 ]; then
                #salteo una llamada porque esta comparando inicio contra inicio"
                inicioYFinRegistrados=0
                registroActual="$registroSiguiente" #guardo el registro del siguiente inicio
            elif [ "$usuarioSiguiente" == "$usuarioActual" ]; then
                #se encontro mismo usuario, inicio y fin de llamada
                fechaActual=$(echo "$registroActual" | cut -d ' ' -f 1,2)
                fechaSiguiente=$(echo "$registroSiguiente" | cut -d ' ' -f 1,2)
                fechaActualSegundos=$(date -d "$fechaActual" +%s)
                fechaSiguienteSegundos=$(date -d "$fechaSiguiente" +%s)
                inicioYFinRegistrados=1

                if [[ $fechaActual != $fechaSiguiente ]]; then 
                #para evitar dos registros con la misma fecha y misma hora, con mismo usuario
                    if [[ $primerDia == 0 ]]; then
                        primerDia=$(echo "$fechaActual" | cut -d ' ' -f 1)
                        primerDia=$(date -d "$primerDia" +%s)
                    else
                        pendiente=$(echo "$fechaActual" | cut -d ' ' -f 1)
                        pendiente=$(date -d "$pendiente" +%s)
                        diferencia=`expr $pendiente - $primerDia`

                        if [[ $diferencia -gt $semanaSegundos  ]]; then
                        #para validar si desde el primer dia registrado pasaron menos de 5 dias
                            diaInvalido=1
                            break
                        fi
                    fi
                    #punto 1
                    ((arrayCantidadLlamadasPorDia[$arrayIndice]++))
                    arrayTiempoLlamadasPorDia[$arrayIndice]=$(expr ${arrayTiempoLlamadasPorDia[$arrayIndice]} + $fechaSiguienteSegundos - $fechaActualSegundos)

                    tiempoLlamadasPorDia=${arrayTiempoLlamadasPorDia[$arrayIndice]}
                    ((cantidadLlamadasPorDia++))

                    #punto 2
                    usuarioProcesado=$usuarioActual
                    diaProcesado=$(echo "$fechaActual" | cut -d ' ' -f 1)
                    ((cantLlamadasUsuarioProcesado++))
                    duracionLlamadaProcesada=$(expr $duracionLlamadaProcesada + $fechaSiguienteSegundos - $fechaActualSegundos)

                    #punto 4
                    fechaLlamada=$(echo "$registroActual" | cut -d ' ' -f 1)
                    duracionLlamada=$(expr "$fechaSiguienteSegundos" - "$fechaActualSegundos")
                    duracionLlamada=$(date -u -d @$duracionLlamada +%H:%M:%S)
                    diaDuracionUsuario+=$(echo "$fechaLlamada $duracionLlamada $usuarioActual")$'\n'

                    #punto 5
                    ((cantidadLlamadasSemana++))
                fi

            else

                registroActual="$registroSiguiente"
                inicioYFinRegistrados=0
            fi
        else
            registroActual="$registroSiguiente"
            inicioYFinRegistrados=0


            #punto 1
            if [[ $cantidadLlamadasPorDia -ne 0 ]]; then
                prom=$(expr $tiempoLlamadasPorDia / $cantidadLlamadasPorDia)
                mapPunto1[$(echo "$fechaActual" | cut -d ' ' -f 1)]=$(date -u -d @$prom +%H:%M:%S)
                ((arrayIndice++))
                cantidadLlamadasPorDiaAux=$cantidadLlamadasPorDia
                cantidadLlamadasPorDia=0
                tiempoLlamadasPorDiaAux=$tiempoLlamadasPorDia
                tiempoLlamadasPorDia=0
            fi
        fi

        #punto 2
        #echo "$usuarioSiguiente  $usuarioProcesado"
        if [ $cantLlamadasUsuarioProcesado -ne 0 ] && [ $usuarioSiguiente != $usuarioProcesado ]; then

            prom=$(expr $duracionLlamadaProcesada / $cantLlamadasUsuarioProcesado)
            prom2=$(date -u -d @$prom +%H:%M:%S)
            punto2+=$(echo "$diaProcesado $usuarioProcesado $prom2 $cantLlamadasUsuarioProcesado")$'\n'
            duracionLlamadaProcesada=0
            cantLlamadasUsuarioProcesado=0
        fi
    done    #fin procesamiento de archivo

    if [[ $cantidadLlamadasSemana -eq 0 ]]; then
        echo "No se contabilizó ninguna llamada en la semana."
    else
        #punto 1
        if [[ $diaInvalido -eq 1 ]]; then
            echo "Se recibieron mas llamadas por mas de 5 días. Solo se contabilizarán los primeros 5 días."
            echo ""
        fi

        echo "Punto 1: Promedio de tiempo de las llamadas realizadas por día."
        if [[ $diaInvalido -ne 1 ]]; then
            if [[ $cantidadLlamadasPorDiaAux -eq 0  ]]; then
                prom=$(expr $tiempoLlamadasPorDia / $cantidadLlamadasPorDia)
            else
                prom=$(expr $tiempoLlamadasPorDiaAux / $cantidadLlamadasPorDiaAux)
            fi
            mapPunto1[$(echo "$fechaActual" | cut -d ' ' -f 1)]=$(date -u -d @$prom +%H:%M:%S)
        fi
        for key in ${!mapPunto1[@]}; do
            echo "Fecha: "$key "Promedio: "${mapPunto1[$key]}
            ((cantDias++))
        done | sort -n -k3 #NO BORRAR, es del for each

echo ""

        #punto 2
        echo "Punto 2: Promedio de tiempo y cantidad por usuario por día."
        echo "" | awk '{printf ("%-11s %-15s %-20s %-2s\n", "Fecha", "Usuario", "Tiempo promedio", "Cantidad de llamadas")}'
        if [ $cantLlamadasUsuarioProcesado -ne 0 ]; then
            prom=$(expr $duracionLlamadaProcesada / $cantLlamadasUsuarioProcesado)
            prom2=$(date -u -d @$prom +%H:%M:%S)
            punto2+=$(echo "$diaProcesado $usuarioProcesado $prom2 $cantLlamadasUsuarioProcesado")$'\n'
        fi
        echo "$punto2" | awk '{printf ("%-11s %-15s %-20s %10s\n", $1, $2, $3, $4)}'

        #punto 3
        echo "Punto 3: Los 3 usuarios con más llamadas en la semana."
        datos=$(echo "$punto2" | sed '/^ *$/d' | sort -k2,2)
        contadores=""
        usuario=$(echo "$datos" | head -1 | cut -d ' ' -f 2)
        cantLlamadas=$(echo "$datos" | head -1 | cut -d ' ' -f 4)

        for reg in $(echo "$datos" | tail -n +2); do
            usuarioReg=$(echo "$reg" | cut -d ' ' -f 2)
            if [ $usuarioReg != $usuario ]; then
                datosAcumulados+=$(echo "$usuario $cantLlamadas")$'\n'
                usuario="$usuarioReg"
                cantLlamadas=0
            fi
            llamada=$(echo "$reg" | cut -d ' ' -f 4)
            cantLlamadas=$(expr $llamada + $cantLlamadas)
        done
        llamada=$(echo "$reg" | cut -d ' ' -f 4)
        datosAcumulados+=$(echo "$usuario $cantLlamadas")$'\n'
        punto3=$(echo "$datosAcumulados" | sort -k2,2 -r)
        echo "" | awk '{printf ("%-15s %-2s\n", "Usuario", "Cantidad de llamadas")}'
        echo "$punto3" | head -3 | awk '{printf ("%-15s %10s\n", $1, $2)}'

        echo ""

        #punto 4
        echo "Punto 4: Cuántas llamadas no superan la media de tiempo por día."
        punto4=$(echo "$diaDuracionUsuario" | sed '/^ *$/d')
        for reg in $(echo "$punto4"); do
            fecha=$(echo "$reg" | cut -d ' ' -f 1)
            promDelDia=${mapPunto1[$fecha]}
            duracionLlamada=$(echo "$reg" | cut -d ' ' -f 2)
            if [[ $duracionLlamada < $promDelDia ]]; then
                mapPunto4[$fecha]=$(expr ${mapPunto4[$fecha]} + 1)
            fi
        done
        if [[ ${!mapPunto4[@]} != "" ]]; then
            echo "" | awk '{printf ("%-15s %-2s\n", "Fecha", "Cantidad de llamadas")}'
            for key in ${!mapPunto4[@]}; do
                echo "" | awk -v FECHA="$key" -v LLAMADAS="${mapPunto4[$key]}" '{printf ("%-15s %10s\n", FECHA, LLAMADAS)}'
            done
        else
            echo "Todas las llamadas superan la media de tiempo por día."
        fi

        echo ""

        #punto 5
        #cantidadLlamadasSemana
        echo "Punto 5: El usuario que tiene más cantidad de llamadas por debajo de la media en la semana."
        for key in ${!mapPunto1[@]}; do
            ((cantDias++))
        done #feo? si, pero anda
        promCantLlamadas=$(expr $cantidadLlamadasSemana / $cantDias)
        #echo "$punto3" | awk -v PROM="$promCantLlamadas" '($2 < PROM) {printf ("%-15s %10s %22s\n", $1, $2, PROM)}' | head -1

        menorCantLLamadas=$(echo "$punto3" | tail -1 | awk '{print $2}')
        if [[ $promCantLlamadas -le $menorCantLLamadas ]]; then
            echo "Todos los usuarios están encima de la media (media = $promCantLlamadas)."
        else
            echo "" | awk '{printf ("%-15s %-21s %-21s\n", "Usuario", "Cantidad de llamadas", "Promedio de la semana")}'

            llamadasRegistro=$(echo "$punto3" | tail -1 | awk '{print $2}')
            punto5=$(echo "$punto3" | sort -k2)

            while read line && (("$menorCantLLamadas" == "$llamadasRegistro")); do
                llamadasRegistro=$(echo "$line" | awk '{print $2}')
                echo "$line" | awk -v PROM="$promCantLlamadas" '{printf ("%-15s %10s %22s\n", $1, $2, PROM)}'
            done <<<"$(echo "$punto5")"
        fi
    fi
fi

#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 2                         #
#---------------------------------------------------------------------#
