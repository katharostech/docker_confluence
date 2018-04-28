################
# Confluence image
################

# Set the base image
FROM registry.access.redhat.com/rhel7

# File Author / Maintainer
MAINTAINER dhaws opax@kadima.solutions

# Build Args
ARG CONFL_VERSION
ARG CONFL_DOWNLOAD_URL=http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFL_VERSION}.tar.gz
ARG MYSQL_JDBC_DRIVER_VERSION=5.1.42
ARG MYSQL_DRIVER_DOWNLOAD_URL=http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JDBC_DRIVER_VERSION}.tar.gz

# Environment Variables
# Confluence
ENV CONFLUENCE_HOME     /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL  /opt/atlassian/confluence
ENV CONFL_VERSION       $CONFL_VERSION
ENV CONFL_DOWNLOAD_URL  $CONFL_DOWNLOAD_URL
# MySQL
ENV MYSQL_JDBC_DRIVER_VERSION $MYSQL_JDBC_DRIVER_VERSION
ENV MYSQL_DRIVER_DOWNLOAD_URL $MYSQL_DRIVER_DOWNLOAD_URL
# User
ENV RUN_USER            confluence
ENV RUN_GROUP           devops

# JAVA HOME changed due to new requirement of sideloading oracle java
ENV JAVA_HOME					  /usr/java/jdk1.8.0_162

# Create unprivileged account
RUN \
groupadd ${RUN_GROUP} && \
useradd -g ${RUN_GROUP} ${RUN_USER}

# Add pre-install files
COPY epel-release-latest-7.noarch.rpm /
RUN \
chmod 644 /epel-release-latest-7.noarch.rpm

# Copy oracle package into container for installation
COPY jdk-8u162-linux-x64.rpm /
RUN \
chmod 644 /jdk-8u162-linux-x64.rpm

#  Install any necesary utilities
RUN set -x \
&& yum localinstall -y epel-release-latest-7.noarch.rpm \
&& yum localinstall -y jdk-8u162-linux-x64.rpm \
&& yum -y install \
tomcat-native \
xmlstarlet \
&& yum clean all \
&& rm -rf /var/cache/yum

# Install Confluence
RUN set -x \
&& mkdir -p                           "${CONFLUENCE_HOME}" \
&& chmod -R 700                       "${CONFLUENCE_HOME}" \
&& chown ${RUN_USER}:${RUN_GROUP}     "${CONFLUENCE_HOME}" \
&& mkdir -p                           "${CONFLUENCE_INSTALL}/conf" \
&& curl -Ls                           "${CONFL_DOWNLOAD_URL}" | tar -xz --directory "${CONFLUENCE_INSTALL}" --strip-components=1 --no-same-owner \
&& curl -Ls                           "${MYSQL_DRIVER_DOWNLOAD_URL}" | tar -xz --directory "${CONFLUENCE_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_JDBC_DRIVER_VERSION}/mysql-connector-java-${MYSQL_JDBC_DRIVER_VERSION}-bin.jar" \
&& chmod -R 700                       "${CONFLUENCE_INSTALL}/conf" \
&& chmod -R 700                       "${CONFLUENCE_INSTALL}/temp" \
&& chmod -R 700                       "${CONFLUENCE_INSTALL}/logs" \
&& chmod -R 700                       "${CONFLUENCE_INSTALL}/work" \
&& chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_INSTALL}/conf" \
&& chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_INSTALL}/temp" \
&& chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_INSTALL}/logs" \
&& chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_INSTALL}/work" \
&& echo -e                            "\nconfluence.home=${CONFLUENCE_HOME}" >> "${CONFLUENCE_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
&& xmlstarlet                         ed --inplace \
    --delete                          "Server/@debug" \
    --delete                          "Server/Service/Connector/@debug" \
    --delete                          "Server/Service/Connector/@useURIValidationHack" \
    --delete                          "Server/Service/Connector/@minProcessors" \
    --delete                          "Server/Service/Connector/@maxProcessors" \
    --delete                          "Server/Service/Engine/@debug" \
    --delete                          "Server/Service/Engine/Host/@debug" \
    --delete                          "Server/Service/Engine/Host/Context/@debug" \
                                      "${CONFLUENCE_INSTALL}/conf/server.xml" \
&& touch -d "@0"                      "${CONFLUENCE_INSTALL}/conf/server.xml"

# Add post install scripts
COPY docker-cmd.sh /docker-cmd.sh
RUN chmod 744 /docker-cmd.sh

COPY confluence-cfg.sh /confluence-cfg.sh
RUN chmod 744 /confluence-cfg.sh

# Configure user defined JVM parameters
RUN sed -i '/Xms/c\CATALINA_OPTS="-Xms${JVM_MIN_MEM:-1024m} -Xmx${JVM_MAX_MEM-1024m} -XX:+UseG1GC ${JVM_SUPPORT_RECOMMENDED_ARGS} ${CATALINA_OPTS}"' ${CONFLUENCE_INSTALL}/bin/setenv.sh

# Expose default HTTP connector port.
EXPOSE 8090
EXPOSE 8091

# Run this on container startup
CMD ["/docker-cmd.sh"]
