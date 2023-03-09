FROM mcr.microsoft.com/devcontainers/base:ubuntu

WORKDIR /home/

RUN echo "===> Installing Azure CLI..."
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN echo "===> Installing Bicep..."
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \
    chmod +x ./bicep && \
    mv ./bicep /usr/local/bin/bicep

RUN echo "===> Installing .NET 7.0 SDK..."
RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-7.0 && \
    dotnet --version

RUN echo "===> Installing Bicep registry module..."
RUN dotnet tool install --global Azure.Bicep.RegistryModuleTool --version 0.15.31
