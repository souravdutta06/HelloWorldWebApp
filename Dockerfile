# syntax=docker/dockerfile:1.4

# Base builder stage with cached dependencies
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /src

# Cache NuGet packages by copying csproj files first
COPY HelloWorldWebApp.sln .
COPY HelloWorldWebApp.Web/*.csproj ./HelloWorldWebApp.Web/
COPY HelloWorldWebApp.Tests/*.csproj ./HelloWorldWebApp.Tests/

# Restore packages (creates layer with dependencies)
RUN dotnet restore HelloWorldWebApp.sln

# Build stage
FROM base AS build
WORKDIR /src

# Copy all source code
COPY . .

# Build with optimizations
RUN dotnet build HelloWorldWebApp.sln \
    -c Release \
    --no-restore \
    -p:ContinuousIntegrationBuild=true \
    -p:DebugType=none \
    -p:DebugSymbols=false \
    -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish HelloWorldWebApp.Web/HelloWorldWebApp.Web.csproj \
    -c Release \
    --no-build \
    --no-restore \
    --no-self-contained \
    -p:EnableCompressionInSingleFile=true \
    -p:PublishTrimmed=true \
    -p:TrimMode=partial \
    -p:InvariantGlobalization=true \
    -o /app/publish

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

# Security hardening
RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser && \
    chsh -s /bin/false appuser && \
    rm -rf /tmp/*

WORKDIR /app
COPY --from=publish --chown=appuser:appgroup /app/publish .

# Non-root user for security
USER appuser

# Health check and port configuration
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/healthz || exit 1

ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

EXPOSE 80

# Optimized entrypoint
ENTRYPOINT ["dotnet", "HelloWorldWebApp.Web.dll"]
