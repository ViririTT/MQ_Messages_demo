FROM ubuntu:16.04

LABEL maintainer "Timothy T Viriri <timothyviriri12@gmail.com>"

LABEL "ProductName"="IBM Integration Bus" \
      "ProductVersion"="10.0.0.11"

# The URL to download the MQ installer from in tar.gz format
ARG MQ_URL=https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev904_ubuntu_x86-64.tar.gz

# The MQ packages to install
ARG MQ_PACKAGES="ibmmq-server ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-msg-.* ibmmq-client ibmmq-sdk ibmmq-samples ibmmq-ft*"

# Install additional packages required by MQ and IIB, this install process and the runtime scripts
RUN apt-get update && \
    apt-get install -y curl rsyslog sudo && \
    rm -rf /var/lib/apt/lists/*
    
ARG IIB_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.11-IIB-LINUX64-DEVELOPER.tar.gz

# Install IIB V10 Developer edition
RUN mkdir /opt/ibm && \
    curl $IIB_URL \ 
    | tar zx --exclude iib-10.0.0.11/tools --directory /opt/ibm && \
    /opt/ibm/iib-10.0.0.11/iib make registry global accept license silently

# Configure system
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog

# Create user to run as
RUN groupadd -f mqbrkrs && \
    groupadd -f mqclient && \
    useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo,mqm,mqclient iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers

# Copy in script files
COPY *.sh /usr/local/bin/
COPY mq-config /etc/mqm/mq-config
RUN chmod 755 /usr/local/bin/*.sh \
  && chmod 755 /etc/mqm/mq-config

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/iib_env.sh MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1 MQSI_DONT_RUN_LISTENER=true LANG=en_US.UTF-8

# Expose default admin port and http ports
EXPOSE 4414 7800 1414

USER iibuser

# Set entrypoint to run management script
ENTRYPOINT ["iib_manage.sh"]
