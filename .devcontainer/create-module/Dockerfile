FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN echo "===> Installing Azure CLI..."
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN echo "===> Installing Azure Bicep..."
RUN az config set bicep.use_binary_from_path=False
RUN az bicep install

RUN echo "===> Installing .NET 7.0 SDK..."
RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-7.0

RUN echo "===> Installing Bicep registry module..."
RUN dotnet tool install --global Azure.Bicep.RegistryModuleTool