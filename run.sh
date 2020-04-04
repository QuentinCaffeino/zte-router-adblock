#!/bin/bash

ROUTER_IP=$1
COOKIE_SID=$2

NAME_OSX="Darwin"
THIS_OS=$(uname -mrs)
DNS_LIST_FILE=zte-router-adblock-dns-list.txt
SESSION_FILE=session.html


# @see https://github.com/tanrax/maza-ad-blocking/blob/master/maza#L23
# Create sed cross system
custom-sed() {
    if [[ $THIS_OS = *$NAME_OSX* ]]; then
        # Check if OSX and install GSED
        if [ -x "$(command -v gsed)" ]; then
            gsed "$@"
        else
            echo "${COLOR_RED}ERROR. You must install gsed if you are using OSX${COLOR_RESET}"
            exit 1
        fi
    else
        # Linux
        sed "$@"
    fi
}
export -f custom-sed


pull-dns-list() {
    # Download DNS list
    curl -L -s "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0&mimetype=plaintext" -o "${DNS_LIST_FILE}"
    # Clear list
    ## Remove comments
    custom-sed -i.bak '/^#/ d' "${DNS_LIST_FILE}"
    ## Remove IPs
    custom-sed -i.bak 's@127\.0\.0\.1\ @@m' "${DNS_LIST_FILE}"
}
export -f pull-dns-list


get-session-token(){
    # Download security page from router
    # It's important cause router generates session token for specific page
    curl -L -s "http://${ROUTER_IP}/getpage.lua?pid=123&nextpage=Internet_Security_SecFilter_t.lp&Menu3Location=0"\
        --header "Cookie: SID=${COOKIE_SID}; _TESTCOOKIESUPPORT=1" -o "${SESSION_FILE}"
    # Find session token in code: _sessionTmpToken = "\x33\x32..."
    SESSION_TOKEN_UNESCAPED=`cat ${SESSION_FILE} | grep "_sessionTmpToken = " | sed 's/[^"]*"\([^"]*\)".*/\1/'`
    # Escape token
    SESSION_TOKEN=`echo -e "${SESSION_TOKEN_UNESCAPED}"`
}
export -f get-session-token


push-dns-list-to-router(){
    get-session-token

    # Push files to router
    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    for i in $(cat < "${DNS_LIST_FILE}"); do
        # Router is able to save names with up to 10 charaters
        HASHED_NAME=`echo "${i}" | md5sum | cut -c1-10`

        # Push entry to router
        curl --location --request POST "http://${ROUTER_IP}/common_page/URLFilter_lua.lua" \
            --header "Content-Type: application/x-www-form-urlencoded" \
            --header "Cookie: SID=${COOKIE_SID}; _TESTCOOKIESUPPORT=1" \
            --data-urlencode "IF_ACTION=Apply" \
            --data-urlencode "_InstID=-1" \
            --data-urlencode "Name=${HASHED_NAME}" \
            --data-urlencode "Url=${i}" \
            --data-urlencode "Btn_cancel_URLFilter=" \
            --data-urlencode "Btn_apply_URLFilter=" \
            --data-urlencode "_sessionTOKEN=${SESSION_TOKEN}"
        echo
    done
}
export -f push-dns-list-to-router


pull-dns-list
push-dns-list-to-router
