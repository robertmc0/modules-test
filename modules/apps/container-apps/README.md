# Container App

This module deploys Microsoft.App/containerApps

## Details

- Creates Microsoft.App container apps resource.
- Enables ingress if specified.
- Creates containers with desired cpu and memory if specified.
- Mount secrets as environment variables.
- Creates dapr micro services apps.
- Scale container apps based on rules.
- Creates container apps from an image if specified.

## Parameters

| Name                         | Type     | Required | Description                                                                                              |
| :--------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------- |
| `location`                   | `string` | Yes      | The geo-location where the resource lives.                                                               |
| `tags`                       | `object` | No       | Optional. Resource tags.                                                                                 |
| `containerAppsEnvironmentId` | `string` | Yes      | Resource ID of the container app managed environment.                                                    |
| `containerName`              | `string` | Yes      | Name of the container app.                                                                               |
| `env`                        | `array`  | No       | Optional. Container environment variables.                                                               |
| `identityType`               | `string` | No       | Optional. The type of identity for the resource.                                                         |
| `imageName`                  | `string` | Yes      | Container image to deploy.                                                                               |
| `ingressEnabled`             | `bool`   | No       | Optional. Specifies if Ingress is enabled for the container app.                                         |
| `activeRevisionsMode`        | `string` | No       | Optional. Active revisions for container apps.                                                           |
| `dapr`                       | `object` | No       | Optional. Dapr configuration for the Container App.                                                      |
| `ingress`                    | `object` | No       | Optional. Ingress configurations for the Container App.                                                  |
| `scale`                      | `object` | No       | Optional. Scaling properties for the Container App.                                                      |
| `secrets`                    | `array`  | No       | Optional. Collection of secrets used by a Container app.                                                 |
| `serviceBinds`               | `array`  | No       | Optional. List of container app services bound to the app.                                               |
| `userAssignedIdentities`     | `object` | No       | Optional. The ID(s) to assign to the resource.                                                           |
| `registries`                 | `array`  | No       | Optional. Collection of private container registry credentials for containers used by the Container app. |
| `serviceType`                | `string` | No       | Optional. Service type for container apps, required only for dev container apps.                         |
| `containerResources`         | `object` | No       | Optional. Container resource requirements.                                                               |

## Outputs

| Name               | Type     | Description                                       |
| :----------------- | :------: | :------------------------------------------------ |
| `name`             | `string` | Name of the image deployed to the container app.  |
| `resourceId`       | `string` | Resource Id of the container app.                 |
| `containerAppFQDN` | `string` | Url of the deployed application as container app. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.