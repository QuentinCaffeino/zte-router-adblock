#!/usr/bin/env bash

ROUTER_IP=$1
COOKIE_SID=$2

DNS_LIST_FILE_PATHNAME="/tmp/zte-router-adblock-rules.txt"
SESSION_FILE_PATHNAME="/tmp/zte-router-adblock-session.html"


initSessionToken(){
    # Download security page from router
    # It's important cause router generates session token for specific page
    curl -L -s "http://${ROUTER_IP}/getpage.lua?pid=123&nextpage=Internet_Security_SecFilter_t.lp&Menu3Location=0"\
        --header "Cookie: SID=${COOKIE_SID}; _TESTCOOKIESUPPORT=1" -o "${SESSION_FILE_PATHNAME}"
    # Find session token in code: _sessionTmpToken = "\x33\x32..."
    SESSION_TOKEN_UNESCAPED=$(cat ${SESSION_FILE_PATHNAME} | grep "_sessionTmpToken = " | sed 's/[^"]*"\([^"]*\)".*/\1/')
    # Escape token
    SESSION_TOKEN=$(echo -e "${SESSION_TOKEN_UNESCAPED}")
}


pushRulesToRouter(){
    initSessionToken

    # Push files to router
    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    for i in $(cat < "${DNS_LIST_FILE_PATHNAME}"); do
        # Router is able to save names with up to 10 charaters
        HASHED_NAME=$(echo "${i}" | sha256sum | cut -c1-10)

        echo "Pushing: ${i} as ${HASHED_NAME}"
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


python3 ./pull-rules-list.py
pushRulesToRouter
