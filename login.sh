#!/bin/bash

# Script para proteger login seguro
# Este script age no momento em que a pessoa consegue se logar no servidor,
# envia um email com a senha para a conta de email cadastrada.

# Caso o email não esteja na lista de cadastrados, o script derruba a conexão.
# Caso a senha de entrada esteja incorreta, o script derruba a conexão.

# Este script deve ficar em /etc/profile.d/login.sh
# O arquivo de lista de emails tem que ficar em /opt/login/login.txt

# - Anti CTRL+C -
stty intr ""

# Esquema de cores
cp="\033[0m"            #CorPadrao
v="\033[0;32m"          #Verde
a="\033[1;33m"          #Amarelo
p="\033[0;30m"          #Preto
vc="\033[1;31m"         #VermelhoClaro

# Variáveis de sistema
HOJE=`date +%d-%m-%Y--%H:%M:%S`
DT=`date +%d-%m-%Y`
ADMIN_PASS='admin@admin'
DIR_LOG="/var/log/login_sec/"
FILE_LOG="$DT.log"

function cria_arquivo_log(){
	if [ -e $DIR_LOG ]; then
		touch $DIR_LOG$FILE_LOG
	else
		mkdir $DIR_LOG
		touch $DIR_LOG$FILE_LOG
	fi
}

function mata_usuario(){
	COMANDO=`tty`
	FILTRO_COMANDO=`echo $COMANDO | cut -c ${#COMANDO}`
	PEGA_PID=`ps xua | grep ssh | grep '@pts/'${FILTRO_COMANDO} | awk '{print $2}'`
	echo "${PEGA_PID}";
	kill -9 ${PEGA_PID}
}

function trataemail(){
	echo -e "$v||$cp Email : ";
	read -p "|| > " EMAIL;

	# Diretório onde estão os emails da wolk.
	DIR_EMAIL='/opt/login/logins.txt';

	# Verificando se o email existe.
	if grep -Fx $EMAIL $DIR_EMAIL > /dev/null
	then
		# Tratando
    echo -e "$v||-----------------------------------------------------$cp";
    echo -e "$v||$cp  Gerando nova senha ...";
    echo -e "$v||$cp  Enviando ...";
    echo -e "$v||$cp $a Atenção ! Não feche esta janela ! $cp";
    echo -e "$v||$cp  Foi enviada uma senha para o seu email,";

    # Gerando senha e enviando email
    SENHA=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c 20`
    echo $SENHA | mail -s $HOSTNAME $EMAIL

    echo -e "$v||$cp  Digite no campo abaixo : ";
    read -p "|| > " NOVA_SENHA

    if [ "$NOVA_SENHA" == "$SENHA" ]; then
			# Gerando log
			cria_arquivo_log
			echo "Usuario $EMAIL logando $HOME" >> $DIR_LOG$FILE_LOG
			# Enviando email avisando que o usuário logou !
			echo "Usuário $EMAIL logando $HOJE" | mail -s $HOSTNAME infra@wolk.com.br

			#liberando login de usuário
      echo -e "$v||$cp Liberando terminal.";
      sleep 3
      clear
      echo " ____ ____ ____ ____ ";
      echo "||w |||o |||l |||k ||";
      echo "||__|||__|||__|||__||";
      echo "|/__\|/__\|/__\|/__\|";
      echo "";

      # Restaurando o recurso do CTRL+C
      stty 500:5:bf:8a3b:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0
      #exit;
		elif [ "$SENHA" != "$ADMIN_PASS" ]; then
			echo "Liberando terminal";
			stty 500:5:bf:8a3b:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0
		else
      echo -e "$vc|| Senha inválida, deslogando. ||$cp ";
      mata_usuario
      exit 0;
    fi;
  else
    echo -e "$vc|| Não encontrei este email, deslogando. ||$cp";
    mata_usuario
  fi
}

function trataentradas(){
	# Tratamento do login
	echo -e "$v||-----------------------------------------------------$cp";
	echo -e "$v||$cp  Olá !";
	echo -e "$v||$cp  Bem vindo ao Servidor$a $HOSTNAME $cp";
	echo -e "$v||-----------------------------------------------------$cp";

	trataemail;
}

trataentradas
