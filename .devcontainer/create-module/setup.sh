echo "===> Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "===> Installing Azure Bicep..."
az config set bicep.use_binary_from_path=False
az bicep install

echo "===> Installing .NET 7.0 SDK..."
wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-7.0

echo "===> Installing Bicep registry module..."
dotnet tool install --global Azure.Bicep.RegistryModuleTool
