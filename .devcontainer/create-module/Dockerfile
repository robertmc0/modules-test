FROM mcr.microsoft.com/devcontainers/base:ubuntu

WORKDIR /home/

RUN echo "===> Installing Azure CLI..."
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN echo "===> Installing Bicep..."
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \
  chmod +x ./bicep && \
  mv ./bicep /usr/local/bin/bicep

RUN echo "===> Installing .NET 7.0 SDK..."
RUN sudo apt update && sudo apt -y install dotnet7 && \
  dotnet --version
