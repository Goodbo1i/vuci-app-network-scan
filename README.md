# Network Scan

## Postman Documentation

https://documenter.getpostman.com/view/17755621/UzBmPTdy

## Getting started

This Collection contains sample requests.

It contains following requests
* Login
* Begin network scanning
* Get network scan results
* Stop scanning

### Usage

### POST method

|Parameters    |Description              |
|--------------|-------------------------|
|`scan_network`|Starts scanning network  |   
|`get_results` | Get network scan results|   
|`stop_scan`   | Stop scanning           | 

#### Start scanning

URI: `POST` http://192.168.1.1/rpc/

Begin network scanning params

Params:

|Parameter   |Type  |Description                  |Required|
|------------|------|-----------------------------|--------|
|`ipv4subnet`|string|Expects "network address/netmask size"|true    |
|`ports`     |bolean|If true enables port scanning and also able to add range.|true    |
|`range`      |string|Scanning port range     |false    |

* Success response:
    * Code: 201 Created
* Error response:
    * Code: 400 Bad request
