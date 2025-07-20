# syntax=docker/dockerfile:1.4

# Base builder stage with cached dependencies
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base

# Create non-root user with home directory
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -m -d /appuser appuser && \
    chown -R appuser:appgroup /appuser

# Set working directory with proper ownership
WORKDIR /src
RUN chown appuser:appgroup /src

# Set environment variables for dotnet
ENV DOTNET_CLI_HOME=/appuser/.dotnet \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
    DOTNET_NOLOGO=1

# Switch to non-root user
USER appuser

# Cache NuGet packages by copying csproj files first
COPY --chown=appuser:appgroup HelloWorldWebApp.sln .
COPY --chown=appuser:appgroup HelloWorldWebApp.Web/*.csproj ./HelloWorldWebApp.Web/
COPY --chown=appuser:appgroup HelloWorldWebApp.Tests/*.csproj ./HelloWorldWebApp.Tests/

# Restore packages with user-level cache
RUN dotnet restore HelloWorldWebApp.sln

# Build stage
FROM base AS build
USER appuser
WORKDIR /src

# Copy all source code
COPY --chown=appuser:appgroup . .

# Build with optimizations
RUN dotnet build HelloWorldWebApp.sln \
    -c Release \
    --no-restore \
    -p:ContinuousIntegrationBuild=true \
    -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish HelloWorldWebApp.Web/HelloWorldWebApp.Web.csproj \
    -c Release \
    --no-build \
    --no-restore \
    -o /app/publish

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

# Security hardening
RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser && \
    chsh -s /bin/false appuser

WORKDIR /app
COPY --from=publish --chown=appuser:appgroup /app/publish .

# Non-root user for security
USER appuser

# Health check and port configuration
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/healthz || exit 1

ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true

EXPOSE 80

# Optimized entrypoint
ENTRYPOINT ["dotnet", "HelloWorldWebApp.Web.dll"]
