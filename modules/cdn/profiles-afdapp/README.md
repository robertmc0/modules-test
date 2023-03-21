# 

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name               | Type     | Required | Description                                  |
| :----------------- | :------: | :------: | :------------------------------------------- |
| `profileName`      | `string` | Yes      | The name of the existing Front Door Profile. |
| `endpoints`        | `array`  | Yes      | Endpoints to deploy to Frontdoor             |
| `originGroups`     | `array`  | Yes      | Origin Groups to deploy to Frontdoor         |
| `origins`          | `array`  | Yes      | Origins to deploy to Frontdoor               |
| `secrets`          | `array`  | No       | Certificates to deploy to Frontdoor          |
| `customDomains`    | `array`  | No       | Custom domains to deploy to Frontdoor        |
| `routes`           | `array`  | Yes      | Routes to deploy to Frontdoor                |
| `securityPolicies` | `array`  | No       | Security Policies to deploy to Frontdoor     |

## Outputs

| Name          | Type  | Description |
| :------------ | :---: | :---------- |
| endpoints     | array |             |
| customDomains | array |             |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```