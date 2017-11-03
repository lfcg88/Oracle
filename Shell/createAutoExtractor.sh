#!/bin/bash

# Jeferson A SILVA
# 22/09/2005

AUX_A="script1.sh_tmp"
AUX_B="script2.sh_tmp"

Usage(){
	echo -e "Usage:"
	echo -e "\t--preinst\t- Arquivo texto ou .sh com os comandos (script) pré-instalacao."
	echo -e "\t--posinst\t- Arquivo texto ou .sh com os comandos (script) pós-instalacao."
	echo -e "\t--input\t\t- Obrigatorio - Arquivo .tar.gz com arquivos e/ou binarios."
	echo -e "\t--output\t- Obrigatorio - Nome do script de saida. E.: meushell.sh"
	echo -e "\t--help\t\t- Utilize para obter informações sobre a utilização deste."
	echo -e "Exemplo:"
	echo -e "\t$0 --input=teste.tar.gz --output=teste.sh"
	echo -e "\t$0 --preinst=preinst.sh --posinst=postinst.sh --input=files.tar.gz --output=meushell.sh"
	exit 0
}

while [ $# -gt 0 ]
do
	case $1 in
		--preinst*)
			if echo $1 | grep -q '=' >/dev/null
			then
				PREINST=`echo $1 | sed 's/^--preinst=//'`
			else
				PREINST=$2
				shift
			fi
			;;
		--posinst*)
			if echo $1 | grep -q '=' >/dev/null
			then
				POSINST=`echo $1 | sed 's/^--posinst=//'`
			else
				POSINST=$2
				shift
			fi
			;;
		--input*)
			if echo $1 | grep -q '=' >/dev/null
			then
				INPUT=`echo $1 | sed 's/^--input=//'`
			else
				INPUT=$2
				shift
			fi
			;;
		--output*)
			if echo $1 | grep -q '=' >/dev/null
			then
				OUTPUT=`echo $1 | sed 's/^--output=//'`
			else
				OUTPUT=$2
				shift
			fi
			;;
		--help|-help|--h|--info|-info*)
			Usage
			;;
		*)
			echo "Opcao invalida utilizada na funcao $(basename $0) - $1"
			Usage
			;;
	esac
	shift
done

if [ -e "$INPUT" ] && [ ! -z "$OUTPUT" ]
then
	echo '#!/bin/bash' > ${AUX_A}
	echo "" >> ${AUX_A}
	if [ ! -z "${PREINST}" ] && [ -e "${PREINST}" ]
	then
		echo "# Pré Install" >> ${AUX_A}
		cat ${PREINST} | grep -v '#!/bin/bash' >> ${AUX_A}
	else
		echo "ATENÇÃO - pré-install não definido ou não encontrado ${PREINST}"
	fi
	echo "# Install" >> ${AUX_A}
	echo "tail -n +{NUMBER} \$0 > ${INPUT}" >> ${AUX_A}
	echo "tar zxf ${INPUT}" >> ${AUX_A}
	echo "rm -f ${INPUT}" >> ${AUX_A}
	if [ ! -z "${POSINST}" ] && [ -e "${POSINST}" ]
	then
		echo "# Pós Install" >> ${AUX_A}
		cat ${POSINST} | grep -v '#!/bin/bash' >> ${AUX_A}
	else
		echo "ATENÇÃO - pós-install não definido ou não encontrado ${POSINST}"
	fi
	echo "" >> ${AUX_A}
	echo "exit 0" >> ${AUX_A}
	LINE=$(($(wc -l ${AUX_A} | awk '{print $1}')+1))
	sed -e "s/{NUMBER}/${LINE}/g" ${AUX_A} > ${AUX_B}
	mv -f ${AUX_B} ${AUX_A}
	cat "${AUX_A}" "${INPUT}" > ${OUTPUT}
	chmod +x ${OUTPUT}
	rm -f ${AUX_A}
	echo "Script gerado em ${OUTPUT}"
else
	Usage
fi

