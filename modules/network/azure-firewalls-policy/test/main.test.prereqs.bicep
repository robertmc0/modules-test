@description('The geo-location where the resource lives.')
param location string

@description('User assigned identity object.')
param userAssignedIdentities object

@description('The name of the key vault.')
param keyVaultName string

resource createFirewallCACert 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'CreateCACertificate'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentities
  }
  properties: {
    forceUpdateTag: '2'
    azPowerShellVersion: '9.1'
    scriptContent: '''
    param(
      [string] $keyVaultName
    )

    $randomPassword = -join ((48..57) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    [string]$exportPassword = "pass:" + $randomPassword
    $certPassword = $randomPassword
    $certName = "TlsInterCA"

    # Create OpenSSL Config
    New-Item openssl.cnf
    $opensslConfig = '
    [ req ]
    default_bits        = 4096
    distinguished_name  = req_distinguished_name
    string_mask         = utf8only
    default_md          = sha512

    [ req_distinguished_name ]
    countryName                     = Country Name (2 letter code)
    stateOrProvinceName             = State or Province Name
    localityName                    = Locality Name
    0.organizationName              = Organization Name
    organizationalUnitName          = Organizational Unit Name
    commonName                      = Common Name
    emailAddress                    = Email Address

    [ rootCA_ext ]
    subjectKeyIdentifier = hash
    authorityKeyIdentifier = keyid:always,issuer
    basicConstraints = critical, CA:true
    keyUsage = critical, digitalSignature, cRLSign, keyCertSign

    [ interCA_ext ]
    subjectKeyIdentifier = hash
    authorityKeyIdentifier = keyid:always,issuer
    basicConstraints = critical, CA:true, pathlen:1
    keyUsage = critical, digitalSignature, cRLSign, keyCertSign

    [ server_ext ]
    subjectKeyIdentifier = hash
    authorityKeyIdentifier = keyid:always,issuer
    basicConstraints = critical, CA:false
    keyUsage = critical, digitalSignature
    extendedKeyUsage = serverAuth
    '
    $opensslConfig >> .\openssl.cnf

    # Create root CA
    openssl req -x509 -new -nodes -newkey rsa:4096 -keyout rootCA.key -sha256 -days 3650 -out rootCA.crt -subj '/C=US/ST=US/O=Self Signed/CN=Self Signed Root CA' -config openssl.cnf -extensions rootCA_ext

    # Create intermediate CA request
    openssl req -new -nodes -newkey rsa:4096 -keyout interCA.key -sha256 -out interCA.csr -subj '/C=US/ST=US/O=Self Signed/CN=Self Signed Intermediate CA'

    # Sign on the intermediate CA
    openssl x509 -req -in interCA.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out interCA.crt -days 3650 -sha256 -extfile openssl.cnf -extensions interCA_ext

    # Export the intermediate CA into PFX
    openssl pkcs12 -export -out interCA.pfx -inkey interCA.key -in interCA.crt -password $exportPassword

    Write-Host ""
    Write-Host "================"
    Write-Host "Successfully generated root and intermediate CA certificates"
    Write-Host "   - rootCA.crt/rootCA.key - Root CA public certificate and private key"
    Write-Host "   - interCA.crt/interCA.key - Intermediate CA public certificate and private key"
    Write-Host "   - interCA.pfx - Intermediate CA pkcs12 package which could be uploaded to Key Vault"
    Write-Host "================"

    $secPassword = ConvertTo-SecureString -String $certPassword -AsPlainText -Force
    $keyVaultCert = Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certName -FilePath .\interCA.pfx -Password $secPassword
    $certId = $keyVaultCert.id
    $certIdUnversioned = $certId.Substring(0,$certId.LastIndexOf("/"))
    $certSecretId = $certIdUnversioned.Replace("/certificates/", "/secrets/")

    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["certName"] = $certName
    $DeploymentScriptOutputs["certId"] = $certId
    $DeploymentScriptOutputs["certIdUnversioned"] = $certIdUnversioned
    $DeploymentScriptOutputs["certSecretId"] = $certSecretId

    '''
    arguments: '-keyVaultName ${keyVaultName}'
    timeout: 'PT15M'
    retentionInterval: 'PT1H'
    cleanupPreference: 'Always'
  }
}

@description('The name of the key vault certificate.')
output certName string = createFirewallCACert.properties.outputs.certName

@description('The id of the key vault certificate.')
output certId string = createFirewallCACert.properties.outputs.certId

@description('The id of the key vault certificate without the version.')
output certIdUnversioned string = createFirewallCACert.properties.outputs.certIdUnversioned

@description('The secret id of the key vault certificate.')
output certSecretId string = createFirewallCACert.properties.outputs.certSecretId
