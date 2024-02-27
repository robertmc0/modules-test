FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /home/

RUN echo "===> Installing Azure CLI..."
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN echo "===> Installing Bicep..."
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \
  chmod +x ./bicep && \
  mv ./bicep /usr/local/bin/bicep

RUN dotnet tool install Azure.Bicep.RegistryModuleTool --tool-path /usr/local/bin/
