#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej5.sh
# Número de APL: 1
# Número de Ejercicio: 5
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

Usage() {
    echo "   Uso:"
    echo "    $0 [opciones]"
    echo -e "    $0 --materias [ruta] --notas [ruta]\n" #-e sirve para reconocer el \n y demas caracteres de escape
    echo "    Procesa el archivo especificado en la ruta que acompaña la opcion [notas]
              utilizando la información de materias y departamentos que están en el archivo
              indicado en la opción [materias]."
    echo "    Otras opciones:"
    echo "    -h, --help              muestra esta información y termina la ejecución"
    exit 0
}

#-a sirve para decirle que los parametros cortos tambien se pueden mandar con la inicial
ARGUMENTS=$(getopt -o h --long help,notas:,materias: -- "$@" 2>/dev/null)
retorno=$?
if [ $retorno -ne 0 ] || [ $# -ne 4 ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
fi

HELP=0
NOTAS=""
MATERIAS=""
eval set -- "$ARGUMENTS"
while true; do
    case "$1" in
    --help)
        HELP=1
        shift 2
        break
        ;;
    -h)
        HELP=1
        shift 2
        break
        ;;
    --notas)
        NOTAS="$2"
        shift 2
        ;;
    --materias)
        MATERIAS="$2"
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

if [ "${NOTAS}" == "" ]; then
    echo "Error: No se envió una ruta acompañando la opcion [--notas]." 1>&2
    exit 2
fi

if [ "${MATERIAS}" == "" ]; then
    echo "Error: No se envió una ruta acompañando la opcion [--materias]." 1>&2
    exit 2
fi

if [ ! -f "${MATERIAS}" ]; then
   echo "Error: La ruta especificada en la opcion [--materias] no es un archivo." 1>&2
    exit 2
fi

if [ ! -f "${NOTAS}" ]; then
   echo "Error: La ruta especificada en la opcion [--notas] no es un archivo." 1>&2
    exit 2
fi
if [ ! -r "${NOTAS}" ]; then
    echo "Error: No tiene permisos de lectura en la ruta de la opcion [--notas]." 1>&2
    exit 2
fi

if [ ! -r "${MATERIAS}" ]; then
   echo "Error: No tiene permisos de lectura en la ruta de la opcion [--materias]." 1>&2
    exit 2
fi





CONTENIDODEPARTAMENTOSARCH=""

# declare -A myMap
IFS=$'\n'
for LINEAD in $(#levantamos datos del archivo de departamentos
    cat "${MATERIAS}" | tail -n +2
); do
    temp=""
    temp=$(echo "$LINEAD" | awk -e  '$0 ~ /[0-9]{1,2}\|[áéíóúÁÉÍÓÚñÑa-zA-Z0-9 ]+\|[0-9]{1,2}$/ {print $0}') 
    if ! test -z "$temp"; then
        idMateriaValido=$(echo "$LINEAD" | awk -F "|" '{print $1}')$'\n' #digo que el delimitador es | y obtengo la primer columna
       
        if [[ $IDMATERIAS != *"$idMateriaValido"* ]]; then
            IDMATERIAS+="$idMateriaValido"$'\n' #una lista para filtrar registros con ids de materias invalidos
            CONTENIDODEPARTAMENTOSARCH+="$LINEAD"$'\n'
        fi
        
    fi
done


if test -z "$IDMATERIAS"; then
    echo "El archivo $MATERIAS no contiene datos válidos."
else
    CONTENIDODEPARTAMENTOSARCH=$(echo "$CONTENIDODEPARTAMENTOSARCH" | sort -t "|" -k3,3 | sed '/^ *$/d')
    for LINEA in $(#por cada linea del archivo
        cat "${NOTAS}" | tail -n +2
    ); do
        temp=""
        temp=$(echo "$LINEA" | awk -e '$0 ~ /^[1-9][0-9]{7}\|[0-9]+\|(([1-9]|10)?\|){3}([1-9]|10)?$/ {print $0}')$'\n'
		DNI=$(echo "$temp" | awk -F "|" '{print($1)}')
		idMateriaAlumno=$(echo "$temp" | awk -F "|" '{print($2)}')
		if [[ $(echo "${IDMATERIAS}" | grep "^"${idMateriaAlumno}"$") ]]; then #codigo de materia valido
			PARCIAL1=$(echo "$temp" | awk -F "|" '{print($3)}')
			PARCIAL2=$(echo "$temp" | awk -F "|" '{print($4)}')
			RECU=$(echo "$temp" | awk -F "|" '{print($5)}')
			FINAL=$(echo "$temp" | cut -d '|' -f 6)
			resTemp+="$temp" #si llega aca los numeros son validos, pero podrian no tener sentido
							 #ej: nota final sin notas de parciales
		fi
    done

    resTemp=$(echo "$resTemp" | sort -t "|" -k2,2 | sed '/^ *$/d')    #cambio | por ' ' y ordeno por idMateria

    #contadores para los resultados de cada materia
    FINALES=0
    RECURSAN=0
    ABANDONAN=0
    PROMOCIONAN=0

    #variable para corte control
    MATERIAANTERIOR=$(echo "$resTemp" | head -1 | awk -F "|" '{print($2)}') #levanto el idMat del primer registro

    #mapa que contiene los resultados de cada materia
    declare -A mapaAlumnos

    for temp in $resTemp; do

        idMateriaAlumno=$(echo "$temp" | awk -F "|" '{print($2)}')
        PARCIAL1=$(echo "$temp" | awk -F "|" '{print($3)}')
        PARCIAL2=$(echo "$temp" | awk -F "|" '{print($4)}')
        RECU=$(echo "$temp" | awk -F "|" '{print($5)}')
        FINAL=$(echo "$temp" | cut -d '|' -f 6)

        #corte control, cuando cambia el id se guarda la info en el mapa
        if [[ $MATERIAANTERIOR != $idMateriaAlumno ]]; then #hubo un cambo de ids de materia, se retean contadores
            mapaAlumnos[$MATERIAANTERIOR]="$FINALES $RECURSAN $ABANDONAN $PROMOCIONAN"
            FINALES=0
            RECURSAN=0
            ABANDONAN=0
            PROMOCIONAN=0
            MATERIAANTERIOR=$idMateriaAlumno
        fi

        NOTA1=0 #1 o 2 da igual, no se refiere a que parcial hace referencia, el recuperatorio pisa la que corresponda
        NOTA2=0
        if [[ $PARCIAL1 == ?* ]]; then
            NOTA1=$PARCIAL1
        fi
        if [[ $PARCIAL2 == ?* ]]; then
            NOTA2=$PARCIAL2
        fi
        if [[ $RECU == ?* ]]; then
            if [[ $NOTA1 -gt $NOTA2 ]]; then
                NOTA2=$RECU
            else
                NOTA1=$RECU
            fi
        fi

        if ([[ $NOTA1 -eq 0 ]] || [[ $NOTA2 -eq 0 ]]) && ! test -z "$FINAL"; then #es un error de los indicados en la cadena de ifs al procesar ARCHIVO
            :
        elif ([[ $NOTA1 -lt 7 ]] || [[ $NOTA2 -lt 7 ]]) && [[ $NOTA1 -gt 3 ]] && [[ $NOTA2 -gt 3 ]]; then
            #si esta en condicion de rendir final (haya rendido o no)
            if test -z "$FINAL"; then #si no hay nota de final
                ((FINALES++))
            else
                if [[ $FINAL -lt 3 ]]; then
                    ((RECURSAN++))
                fi
                #else aprueba el final
            fi
        elif [[ $NOTA1 -gt 6 ]] && [[ $NOTA2 -gt 6 ]]; then
            ((PROMOCIONAN++))
        elif [[ $NOTA1 -eq 0 ]] || [[ $NOTA2 -eq 0 ]]; then
            ((ABANDONAN++))
        else
            ((RECURSAN++))
        fi
    done

    if [[ $FINALES -ne 0 ]] || [[ $RECURSAN -ne 0 ]] || [[ $ABANDONAN -ne 0 ]] || [[ $PROMOCIONAN -ne 0 ]]; then 
        mapaAlumnos[$MATERIAANTERIOR]="$FINALES $RECURSAN $ABANDONAN $PROMOCIONAN"
    fi

    # if [[ $mapaAlumnos ]]

    if [[ ${!mapaAlumnos[@]} == "" ]]; then
        echo "El archivo $NOTAS no contiene datos válidos."
    else

        

        IFS=$'\n'

        DEPARTAMENTOANTERIOR=-1
        JSON="{         
    \"departamentos\": ["

        PRIMERAVEZ=1
        for datosDepartamento in $(echo "$CONTENIDODEPARTAMENTOSARCH"); do

            idDep=$(echo "$datosDepartamento" | awk -F "|" '{print($3)}')
            if [[ $PRIMERAVEZ -eq 0 ]]; then
                if [[ $idDep != $DEPARTAMENTOANTERIOR ]]; then
                    JSON+="                
                }"
                else
                    JSON+="                
                },"
                fi
            fi
            if [[ $idDep != $DEPARTAMENTOANTERIOR ]]; then #cambio de departamento
                if [[ $PRIMERAVEZ -eq 0 ]]; then
                    JSON+="            
            ]
        },"
                fi
                PRIMERAVEZ=0
                JSON+="        
        {
            \"id\": $idDep,
            \"notas\": ["
            fi
            DEPARTAMENTOANTERIOR=$idDep
            if [[ $idDep == $DEPARTAMENTOANTERIOR ]]; then
                idMat=$(echo "$datosDepartamento" | awk -F "|" '{print($1)}')
                descr=$(echo "$datosDepartamento" | awk -F "|" '{print($2)}')
                RESULTADOS=${mapaAlumnos[$idMat]}
                FINAL=$(echo "$RESULTADOS" | awk '{print($1)}')
				FINAL=$([[ "$FINAL" -ne 0 ]] && echo "$FINAL" || echo 0)
                REC=$(echo "$RESULTADOS" | awk '{print($2)}')
				REC=$([[ "$REC" -ne 0 ]] && echo "$REC" || echo 0)
                AB=$(echo "$RESULTADOS" | awk '{print($3)}')
				AB=$([[ "$AB" -ne 0 ]] && echo "$AB" || echo 0)
                PROM=$(echo "$RESULTADOS" | awk '{print($4)}')
				PROM=$([[ "$PROM" -ne 0 ]] && echo "$PROM" || echo 0)

                JSON+="
                {
                    \"id_materia\": $idMat,
                    \"descripcion\": \"$descr\",
                    \"final\": \"$FINAL\",
                    \"recursan\": \"$REC\",
                    \"abandonaron\": \"$AB\",
                    \"promocionaron\": \"$PROM\""
            fi
        done

        idMat=$(echo "$datosDepartamento" | awk -F "|" '{print($1)}')
        descr=$(echo "$datosDepartamento" | awk -F "|" '{print($2)}')
        RESULTADOS=${mapaAlumnos[$idMat]}
        FINAL=$(echo "$RESULTADOS" | awk '{print($1)}')
        REC=$(echo "$RESULTADOS" | awk '{print($2)}')
        AB=$(echo "$RESULTADOS" | awk '{print($3)}')
        PROM=$(echo "$RESULTADOS" | awk '{print($4)}')

        JSON+="
                }       
            ]
        }
    ]
}"

        echo "$JSON" > "./resultado.json"
        echo "Archivo resultado creado correctamente"

    fi
fi

#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 5                         #
#---------------------------------------------------------------------#