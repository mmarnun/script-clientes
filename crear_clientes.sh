#!/bin/bash

. ./funciones.sh

f_principal

if f_comprobarroot; then
    if f_comprobarplantilla; then
        f_datos $1 $2 $3
        if f_volumen; then
            if f_redimension; then
                if f_hostname; then
                    if f_clonacion; then
                        if f_conectarred; then
                            if f_iniciarmaquina; then
                                f_finscript
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
fi
