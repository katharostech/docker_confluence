# Set variables
SVRCONFIGLOC=${CONFLUENCE_INSTALL}/conf
SERVERFILE=${SVRCONFIGLOC}/server.xml

#remove JAVA HOME from setting in confluence-cfg.sh it is now and ENV variable in Dockerfile
if [[ -n "${ssl_term_domain}" ]] ; then
    # Build proxy info
    MYPROXY="proxyName=\"${ssl_term_domain}\" secure=\"true\" proxyPort=\"443\" scheme=\"https\""
    # Insert proxy info
    sed -i "/coyote/ s/^\(.*\)\(\/\)/\1 ${MYPROXY}\2/" ${SERVERFILE}
fi

# Import ROOT cert to allow app links in dev to work along with other app-to-app communication 
if [[ -n "${AUX_ROOT_CERT_1}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_1} -alias AUX_ROOT_CERT_1
fi

if [[ -n "${AUX_ROOT_CERT_2}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_2} -alias AUX_ROOT_CERT_2
fi

if [[ -n "${AUX_ROOT_CERT_3}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_3} -alias AUX_ROOT_CERT_3
fi

if [[ -n "${AUX_ROOT_CERT_4}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_4} -alias AUX_ROOT_CERT_4
fi

if [[ -n "${AUX_ROOT_CERT_5}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_5} -alias AUX_ROOT_CERT_5
fi


# Import Intermediate cert to allow app links in dev to work along with other app-to-app communication

if [[ -n "${AUX_INTER_CERT_1}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_1} -alias AUX_INTER_CERT_1
fi

if [[ -n "${AUX_INTER_CERT_2}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_2} -alias AUX_INTER_CERT_2
fi

if [[ -n "${AUX_INTER_CERT_3}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_3} -alias AUX_INTER_CERT_3
fi

if [[ -n "${AUX_INTER_CERT_4}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_4} -alias AUX_INTER_CERT_4
fi

if [[ -n "${AUX_INTER_CERT_5}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_5} -alias AUX_INTER_CERT_5
fi
