#!/bin/bash

# Script de instalação e atualização dos demais scripts.
# Só pode ser executado como root.

mkdir /opt/login_seguro

case $1 in
    instalar)
        echo "Instalando o Script Login-Secure";
        chmod +x login.sh
        cp login.sh /etc/profile.d/
        cp usuarios.usuarios /opt/login_seguro/
        echo "Instalado, para testar, logue novamente no servidor";
    ;;
    atualizar)
        echo "Atualizando o Script Login-Secure";
        chmod +x login.sh
        rm -rf /etc/profile.d/login.sh
        cp login.sh /etc/profile.d/
        rm -rf /opt/login_seguro/usuarios.usuarios
        cp usuarios.usuarios /opt/login_seguro/
        echo "Scripts atualizados";
    ;;
    remover)
        echo "Removendo o Script Login-Secure";
        rm -rf /etc/profile.d/login.sh
        rm -rf /opt/login_seguro/
        echo "Scripts removidos"
    ;;
    *)
    echo "Forma de utilização : ";
    echo "instalar | remover | atualizar"
esac
