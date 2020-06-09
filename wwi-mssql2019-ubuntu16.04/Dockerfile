FROM mcr.microsoft.com/mssql/server:2019-CU2-ubuntu-16.04 as stage1

ENV ACCEPT_EULA Y
ENV MSSQL_PID Developer
ENV SA_PASSWORD "MyC0m9l&xP@ssw0rd"

ADD wwi.bak /

RUN /opt/mssql/bin/sqlservr & \
    sleep 30 && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "MyC0m9l&xP@ssw0rd" -Q "RESTORE DATABASE WideWorldImporters FROM DISK = '/wwi.bak' WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf', MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_userdata.ndf', MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf', MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1'" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "MyC0m9l&xP@ssw0rd" -Q shutdown; \
    exit 0

FROM mcr.microsoft.com/mssql/server:2019-CU2-ubuntu-16.04

ENV ACCEPT_EULA Y
ENV MSSQL_PID Developer
ENV SA_PASSWORD "MyC0m9l&xP@ssw0rd"

COPY --from=stage1 /var/opt/mssql/data/ /var/opt/mssql/data/
