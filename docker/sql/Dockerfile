FROM mcr.microsoft.com/mssql/server:2019-CU2-ubuntu-16.04

ENV ACCEPT_EULA Y
ENV MSSQL_PID Developer
ENV SA_PASSWORD "MyC0m9l&xP@ssw0rd"

ADD adventureworks.bak /

RUN /opt/mssql/bin/sqlservr & \
    sleep 30 && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "MyC0m9l&xP@ssw0rd" -Q "RESTORE DATABASE AdventureWorks2017 FROM DISK = '/adventureworks.bak' WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf', MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2017.ldf', REPLACE" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "MyC0m9l&xP@ssw0rd" -Q shutdown; \
    exit 0
