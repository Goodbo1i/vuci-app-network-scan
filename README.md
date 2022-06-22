# Network Scan

## Postman Documentation

For more examples visit: https://documenter.getpostman.com/view/17755621/UzBmPTdy

## Getting started

#### To Install argparse is needed: https://openwrt.org/packages/pkgdata/lua-argparse

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

`scan_network` Params:

|Parameter   |Type  |Description                  |Required|
|------------|------|-----------------------------|--------|
|`ipv4subnet`|string|Expects "network address/netmask size"|true    |
|`ports`     |bolean|If true enables port scanning and also able to add range.|true    |
|`range`      |string|Scanning port range     |false    |

#### Get Network Scan Results

URI: `POST` http://192.168.1.1/rpc/

Getting Results after network scan.

Params:

|Parameter   |Type  |Description                  |Required|
|------------|------|-----------------------------|--------|
|`sid`|string|Session ID|true    |
|`netscan`     |string|Where get results function is|true    |
|`get_results`      |string|Get scan results    |false    |

If scan is still in progress when trying to get result data, then it will output `"message": "Scan in progress"`

#### Stop Network Scanning

URI: `POST` http://192.168.1.1/rpc/

Stop Scanning

Params:

|Parameter   |Type  |Description                  |Required|
|------------|------|-----------------------------|--------|
|`sid`|string|Session ID|true    |
|`netscan`     |string|Where get results function is|true    |
|`stop_scan`      |string|Stop scan   |false    |



