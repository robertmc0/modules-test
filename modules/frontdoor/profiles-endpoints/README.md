# Front Door Profile Endpoints Module

This module deploys front door profile endpoints and associated resources to an existing front door profile.

## Description

This module allows you to create AFD endpoints for an existing frontdoor profile, along with assoicated resources. It does the following:-

- Creates Front Door endpoints.
- Creates Front Door Custom Domains and links them to DNS Zones.
- Creates Front Door Origin Groups and origins.
- Creates Front Door RuleSets.
- Creates Front Door Secrets and links to secrets stored in key vault.
- Creates Front Door Routes linking to provided custom domains, endpoints and rulesets.
- Creates Front Door Security Policies linking to existing Front Door Web Application Firewall policy.

## Parameters

| Name               | Type     | Required | Description                                                                                                |
| :----------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------- |
| `profileName`      | `string` | Yes      | The name of the existing Front Door/CDN Profile.                                                           |
| `endpoints`        | `array`  | Yes      | Endpoints to deploy to Front Door.                                                                         |
| `originGroups`     | `array`  | Yes      | Origin Groups to deploy to Front Door.                                                                     |
| `origins`          | `array`  | Yes      | Origins to deploy to Front Door.                                                                           |
| `secrets`          | `array`  | No       | Optional. Secrets to deploy to Front Door. Required if customer certificates are used to secure endpoints. |
| `customDomains`    | `array`  | No       | Optional. Custom domains to deploy to Front Door.                                                          |
| `routes`           | `array`  | Yes      | Routes to deploy to Front Door.                                                                            |
| `ruleSets`         | `array`  | No       | Optional. RuleSets to deploy to Front Door.                                                                |
| `securityPolicies` | `array`  | No       | Optional. Security Policies to deploy to Front Door.                                                       |

## Outputs

| Name                    | Type  | Description                                                             |
| :---------------------- | :---: | :---------------------------------------------------------------------- |
| endpoints               | array | The endpoints of the deployed Azure Front Door Profile.                 |
| customDomains           | array | The custom domains of the deployed Azure Front Door Profile.            |
| customDomainValidations | array | The custom domain validations of the deployed Azure Front Door Profile. |
| securityPolicies        | array | The security policies of the deployed Azure Front Door Profile.         |
| ruleSets                | array | The ruleSets of the deployed Azure Front Door Profile.                  |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.