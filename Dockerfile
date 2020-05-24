FROM ubuntu:16.04

# Set the default shell for executing commands.
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y apt-transport-https vim git postgresql wget lsb-release

ADD db_commands.txt /db_commands.txt

# Setup iRODS.
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -; \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods.list; \
    apt-get update && \
    apt-get install -y irods-server irods-auth-plugin-krb irods-database-plugin-postgres

RUN service postgresql start && su - postgres -c "psql -f /db_commands.txt" ; \
    service postgresql stop

ADD run_irods.sh  /run_irods.sh

# for Docker under windows, remove control-M chars for shebang line to work:

RUN tr -d '\015' </run_irods.sh >/tmp/run_irods.sh.rm_cM && \
    mv /tmp/run_irods.sh.rm_cM /run_irods.sh ; \
    chmod +x /run_irods.sh

CMD [ "/run_irods.sh" ]
