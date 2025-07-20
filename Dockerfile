# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and restore
COPY HelloWorldWebApp.sln .
COPY HelloWorldWebApp.Web/ HelloWorldWebApp.Web/
COPY HelloWorldWebApp.Tests/ HelloWorldWebApp.Tests/

# Restore and build the web project
WORKDIR /src/HelloWorldWebApp.Web
RUN dotnet restore
RUN dotnet build -c Release --no-restore

# Publish
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Expose ports
EXPOSE 80
EXPOSE 443

# Run the application
ENTRYPOINT ["dotnet", "HelloWorldWebApp.Web.dll"]
