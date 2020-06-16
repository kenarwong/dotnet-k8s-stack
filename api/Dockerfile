FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build
WORKDIR /app

# copy csproj and restore
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "api.dll"]
