#!/usr/bin/env bash

# ==============================================================
#  Autor       : Eduardo Amaral
#  Email       : eduardo4maral@protonmail.com
#  YouTube     : https://www.youtube.com/faciltech
#  GitHub      : https://github.com/faciltech
#  Site        : https://www.eduardo-amaral.com
#  LinkedIn    : https://www.linkedin.com/in/eduardo4maral/
#  Atualização : 16/02/2026
# ==============================================================

trap 'echo; exit 1' 2

# =========================
# CORES
# =========================
RED=$'\033[1;31m'
DARK_RED=$'\033[0;31m'
GREEN=$'\033[1;32m'
CYAN=$'\033[1;36m'
YELLOW=$'\033[1;33m'
RESET=$'\033[0m'

# =========================
# BANNER SCAN USER
# =========================
banner() {
clear
echo -e "${RED}"
echo "   ███████╗ ██████╗ █████╗ ███╗   ██╗    ██╗   ██╗███████╗███████╗██████╗ "
echo "   ██╔════╝██╔════╝██╔══██╗████╗  ██║    ██║   ██║██╔════╝██╔════╝██╔══██╗"
echo "   ███████╗██║     ███████║██╔██╗ ██║    ██║   ██║███████╗█████╗  ██████╔╝"
echo "   ╚════██║██║     ██╔══██║██║╚██╗██║    ██║   ██║╚════██║██╔══╝  ██╔══██╗"
echo "   ███████║╚██████╗██║  ██║██║ ╚████║    ╚██████╔╝███████║███████╗██║  ██║"
echo "   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝"
echo
echo -e "             ${GREEN}EDUARDO AMARAL${RESET} - ${DARK_RED}OSINT Recon & Intelligence Framework${RESET}"
echo -e "${RESET}"
}


USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TIMEOUT=10

curl_page() {
    curl -s -A "$USER_AGENT" -L --max-time "$TIMEOUT" "$1"
}
###################################
# NICKNAME
####################################
scan_socials() {
    read -p "${GREEN}Digite o username: ${RESET}" user
    echo "${CYAN}[+] Verificando perfis para:${RESET} $user"

    declare -A sites=(
        ["MercadoLivre"]="https://mercadolivre.com.br/loja/"
        ["TikTok"]="https://www.tiktok.com/@"
        ["Facebook"]="https://www.facebook.com/"
        ["Twitter"]="https://nitter.net/"
        ["YouTube"]="https://www.youtube.com/@"
        ["Reddit"]="https://www.reddit.com/user/"
        ["WordPress"]="https://wordpress.com/"
        ["Pinterest"]="https://www.pinterest.com/"
        ["OnlyFans"]="https://fanscout.com/"
        ["GitHub"]="https://github.com/"
        ["Flickr"]="https://www.flickr.com/people/"
        ["Steam"]="https://steamcommunity.com/id/"
        ["SoundCloud"]="https://soundcloud.com/"
        ["Medium"]="https://medium.com/@"
        ["About.me"]="https://about.me/"
        ["SlideShare"]="https://pt.slideshare.net/"
        ["Spotify"]="https://open.spotify.com/user/"
        ["Scribd"]="https://www.scribd.com/"
        ["Pastebin"]="https://pastebin.com/u/"
        ["Foursquare"]="https://foursquare.com/user/"
        ["Roblox"]="https://www.roblox.com/users/profile?username="
        ["Ebay"]="https://www.ebay.com/usr/"
    )

    for nome in "${!sites[@]}"; do
        base="${sites[$nome]}"
        url="${base}${user}"

        # Verifica HTTP status
        status=$(curl -L -s -o /dev/null -w "%{http_code}" "$url")

        if [[ "$status" == "200" ]]; then
            echo -e "${GREEN}[✓] $nome${RESET} → $url"
        fi
    done
	
    echo -e "${GREEN}[✔] Busca finalizada.${RESET}"
}
###################################
# LEAK EMAIL
####################################
verificar_email() {
    read -p "${GREEN}Digite o email: ${RESET}" email
    echo -e "${CYAN}[+] Verificando vazamentos para: $email${RESET}"
    

    dados=$(curl -s "https://api.proxynova.com/comb?query=$email" | grep "$email" | cut -d'"' -f2 | grep -v "?")

    if [[ -n "$dados" ]]; then
        echo "$dados" | while read l; do echo -e "${GREEN}$l${RESET}"; done
    else
        echo "Nenhum vazamento encontrado";
    fi
}
###################################
# ESCAVADOR
####################################
escavador_modulo() {
    read -p "${GREEN}Digite o nome completo: ${RESET}" nome
    echo -e "${CYAN}[+] Coletando informações do escavador...${RESET}"
    
    local alfa="$nome"
    local busca=$(echo "$alfa" | sed 's/ /+/g')

    site="https://www.escavador.com/busca?qo=t&q=\"$busca\""
    page=$(curl_page "$site")

    if echo "$page" | grep -qi "resultados"; then
        echo -e "${GREEN}Possíveis registros encontrados${RESET}"
        echo "$page" | grep "link-address" | cut -d">" -f2 | sed 's#</a##g' 
    else
        echo -e "Nenhum resultado"
    fi
    
    echo -e "${GREEN}[✔] Dados coletados.${RESET}"
}


###################################
# GRAVATAR
####################################
scan_gravatar() {
    read -p "${GREEN}Digite o email: ${RESET}" email

    hash=$(echo -n "$email" | md5sum | cut -d" " -f1)

    url="https://gravatar.com/avatar/$hash?s=600"
    
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")


    if [[ "$status" == "200" ]]; then
        echo -e "${GREEN}Foto encontrada:${RESET} $url"
         curl -s "$url" 
    else
         "Nenhuma foto encontrada"
    fi
}
# =========================
# INÍCIO
# =========================

banner

while true; do

    echo
    echo -e "${RED}================ MENU =================${RESET}"
    echo "[1] Buscar Username"
    echo "[2] Verificar Email (Password Leak)"
    echo "[3] Escavador"
    echo "[4] Gravatar"
    echo "[0] Sair"
    echo "========================================"
    read -p "${YELLOW}Escolha uma opção: ${RESET}" opcao
    echo

    case $opcao in
        1)
            scan_socials
            ;;
        2)
            verificar_email
            ;;
        3)
            escavador_modulo
            ;;
        4)
            scan_gravatar
            ;;
        0)
            echo -e "${RED}Encerrando Scan User...${RESET}"
            exit
            ;;
        *)
            echo -e "${YELLOW}Opção inválida!${RESET}"
            ;;
    esac

    echo
    echo -e "${CYAN}Pressione ENTER para voltar ao menu...${RESET}"
    read
done
