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
echo -e "              ${DARK_RED}EDUARDO AMARAL -- OSINT Recon & Intelligence Framework${RESET}"
echo -e "${RESET}"
}

USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TIMEOUT=10


####################################
# BANNER
####################################
banner

####################################
# CRIAR PROJETO
####################################
criar_projeto() {

    while true; do
        read -rp "${GREEN}Nome do projeto: ${RESET}" PROJETO
        [[ -z "$PROJETO" ]] && continue

        if [[ -d "$PROJETO" ]]; then
            echo "${RED}Projeto já existe.${RESET}"
            read -rp "${YELLOW}Substituir (S) ou novo nome (N)?${RESET} " escolha

            case "$escolha" in
                S|s) rm -rf "$PROJETO"; mkdir "$PROJETO"; break ;;
                N|n)
                    random=$(tr -dc a-z0-9 </dev/urandom | head -c 4)
                    PROJETO="${PROJETO}_${random}"
                    mkdir "$PROJETO"
                    break
                ;;
                *) echo "Opção inválida." ;;
            esac
        else
            mkdir "$PROJETO"
            break
        fi
    done

    RELATORIO="$PROJETO/relatorio.txt"
    touch "$RELATORIO"
}

linha() { echo "========================================" | tee -a "$RELATORIO"; }
log() { echo "$1" | tee -a "$RELATORIO"; }

check_http() {
    curl -s -o /dev/null -w "%{http_code}" \
        -A "$USER_AGENT" --max-time "$TIMEOUT" "$1"
}

curl_page() {
    curl -s -A "$USER_AGENT" -L --max-time "$TIMEOUT" "$1"
}

####################################
# INSTAGRAM (VERSÃO COMPLETA)
####################################
scan_instagram() {

    local user="$1"

    linha
    log "[INSTAGRAM]"

    local url="https://instaincognito.com/en/u/$user"
    local page
    page=$(curl_page "$url")

    nick=$(echo "$page" | grep -oP '"name":\s*"\K[^"]+' | head -n1)

    if [[ -z "$nick" ]]; then
        log "Conta não encontrada"
        return
    fi

    followers=$(echo "$page" \
        | grep -oP 'Followers:\s*[0-9,]+' \
        | grep -oP '[0-9,]+' \
        | head -1)

    following=$(echo "$page" \
        | tr '\n' ' ' \
        | grep -oP '<strong>[0-9,]+</strong>\s*Following' \
        | grep -oP '[0-9,]+' \
        | head -1)

    posts=$(echo "$page" \
        | grep -oP 'Posts:\s*[0-9,]+' \
        | grep -oP '[0-9,]+' \
        | head -1)

    bio=$(echo "$page" \
        | grep -oP '(?<=class="bio">)[^<]+' \
        | head -1)

    foto=$(echo "$page" \
        | grep -oP 'https://[^"]+profile_pic[^"]+' \
        | head -1)

    log "${GREEN}Perfil:${RESET} https://instagram.com/$user"
    log "${GREEN}Nickname:${RESET} $nick"
    log "${GREEN}Seguidores:${RESET} ${followers:-N/A}"
    log "${GREEN}Seguindo:${RESET} ${following:-N/A}"
    log "${GREEN}Posts:${RESET} ${posts:-N/A}"
    [[ -n "$bio" ]] && log "${GREEN}Bio:${RESET} $bio"
    [[ -n "$foto" ]] && log "${GREEN}Foto:${RESET} $foto"

    sleep 1

}


####################################
# REDES SOCIAIS (COMPLETO)
####################################
scan_socials() {

    local user="$1"

    linha
    log "${GREEN}USUÁRIO ANALISADO:${RESET} $user"
    linha

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
        ["Tumblr"]="https://$user.tumblr.com"
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

        if [[ "$nome" == "Tumblr" ]]; then
            url="$base"
        else
            url="${base}${user}"
        fi

        status=$(check_http "$url")

        if [[ "$status" == "200" ]]; then
            log "${GREEN}[+] $nome ->${RESET} $url"
        else
            log "[-] $nome -> Não encontrado"
        fi
    done
	# Instagram detalhado
    	scan_instagram "$user"
}

####################################
# GRAVATAR
####################################
scan_gravatar() {

    local email="$1"
    local num="$2"

    linha
    log "[GRAVATAR — Email $num]"

    hash=$(echo -n "$email" | md5sum | cut -d" " -f1)
    url="https://gravatar.com/avatar/$hash?s=600"

    status=$(check_http "$url")

    if [[ "$status" == "200" ]]; then
        log "${GREEN}Foto encontrada:${RESET} $url"
        curl -s "$url" -o "$PROJETO/gravatar_email_${num}.jpg"
    else
        log "Nenhuma foto encontrada"
    fi
}

####################################
# EMAIL VAZADO
####################################
scan_email() {

    local email="$1"
    local num="$2"

    linha
    log "[VAZAMENTO — Email $num]"

    dados=$(curl -s "https://api.proxynova.com/comb?query=$email" \
        | grep "$email" | cut -d'"' -f2)

    if [[ -n "$dados" ]]; then
        echo "$dados" | while read l; do log "${GREEN}$l${RESET}"; done
    else
        log "Nenhum vazamento encontrado"
    fi
}

####################################
# ESCAVADOR
####################################
scan_escavador() {

    local alfa="$1"
    local busca=$(echo "$alfa" | sed 's/ /+/g')

    linha
    log "[ESCAVADOR]"


    site="https://www.escavador.com/busca?qo=t&q=\"$busca\""
    page=$(curl_page "$site")

	echo $site

    if echo "$page" | grep -qi "resultados"; then
        log "${GREEN}Possíveis registros encontrados${RESET}"
        echo "$page" | grep "link-address" | cut -d">" -f2 | sed 's#</a##g' | tee -a "$RELATORIO"
    else
        log "Nenhum resultado"
    fi

}


####################################
# MAIN
####################################
criar_projeto

read -rp "${GREEN}Nome completo (opcional):${RESET} " nome
read -rp "${GREEN}Emails separados por vírgula (opcional):${RESET} " emails
read -rp "${GREEN}Nicknames separados por vírgula (opcional):${RESET} " nicks

####################################
# VALIDAR — AO MENOS UM DADO
####################################
if [[ -z "$nome" && -z "$emails" && -z "$nicks" ]]; then
    echo "Erro: informe ao menos um dado."
    exit 1
fi

linha
log "RELATÓRIO OSINT"
linha
log "Nome: ${nome:-Não informado}"
log "Emails: ${emails:-Não informado}"
log "Nicknames: ${nicks:-Não informado}"

####################################
# PROCESSAR EMAILS MÚLTIPLOS
####################################
if [[ -n "$emails" ]]; then

    IFS=',' read -ra EMAIL_LIST <<< "$emails"

    contador=1

    for e in "${EMAIL_LIST[@]}"; do
        e=$(echo "$e" | xargs)

        [[ -z "$e" ]] && continue

        scan_gravatar "$e" "$contador"
        scan_email "$e" "$contador"

        ((contador++))
    done
fi

####################################
# PROCESSAR NICKS
####################################
if [[ -n "$nicks" ]]; then

    IFS=',' read -ra USERS <<< "$nicks"

    for u in "${USERS[@]}"; do
        u=$(echo "$u" | xargs)
        [[ -n "$u" ]] && scan_socials "$u"
    done
fi

####################################
# PROCESSAR NOME
####################################
if [[ -n "$nome" ]]; then
    scan_escavador "$nome"
fi

linha
log "FINALIZADO: $(date)"
