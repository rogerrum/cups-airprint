# AirPrint bridge for your local printers

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/rogerrum/cups-airprint)](https://hub.docker.com/r/rogerrum/cups-airprint/tags)
[![license](https://img.shields.io/github/license/rogerrum/cups-airprint)](https://github.com/rogerrum/cups-airprint/blob/main/LICENSE)
[![DockerHub pulls](https://img.shields.io/docker/pulls/rogerrum/cups-airprint.svg)](https://hub.docker.com/r/rogerrum/cups-airprint/)
[![DockerHub stars](https://img.shields.io/docker/stars/rogerrum/cups-airprint.svg)](https://hub.docker.com/r/rogerrum/cups-airprint/)
[![GitHub stars](https://img.shields.io/github/stars/rogerrum/cups-airprint.svg)](https://github.com/rogerrum/cups-airprint)
[![Contributors](https://img.shields.io/github/contributors/rogerrum/cups-airprint.svg)](https://github.com/rogerrum/cups-airprint/graphs/contributors)
[![Paypal](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal)](https://www.paypal.com/donate/?business=CRVGAN4YGG9KL&no_recurring=0&item_name=rogerrum&currency_code=USD)



## Purpose
Run a container with CUPS and Avahi (mDNS/Bonjour) so that local printers
on the network can be exposed via AirPrint to iOS/macOS devices.

I'm using it on my Kube cluster with my old brother printer to use it as airprint. The local Avahi will be utilized for advertising the printers on the network.

I started with the base from https://github.com/DrPsychick/docker-cups-airprint and extended it use the latest ubuntu version and use Brother printer drivers.

## Requirements
* you must have CUPS drivers available for your printer (Brother)
* If you have multiple subnets then make sure mDNS is turned on your router to support airprint

## Configuration

### Variables overview
Important! Docker environment variables only support single line without double quotes!
```shell script
CUPS_ADMIN_USER=${CUPS_ADMIN_USER:-"admin"}
CUPS_ADMIN_PASSWORD=${CUPS_ADMIN_PASSWORD:-"secr3t"}
CUPS_WEBINTERFACE=${CUPS_WEBINTERFACE:-"yes"}
CUPS_SHARE_PRINTERS=${CUPS_SHARE_PRINTERS:-"yes"}
CUPS_REMOTE_ADMIN=${CUPS_REMOTE_ADMIN:-"yes"} # allow admin from non local source
CUPS_ACCESS_LOGLEVEL=${CUPS_ACCESS_LOGLEVEL:-"config"} # all, access, config, see `man cupsd.conf`
CUPS_LOGLEVEL=${CUPS_LOGLEVEL:-"warn"} # error, warn, info, debug, debug2 see `man cupsd.conf`
CUPS_ENV_DEBUG=${CUPS_ENV_DEBUG:-"no"} # debug startup script and activate CUPS debug logging
CUPS_IP=${CUPS_IP:-$(hostname -i)} # no need to set this usually
CUPS_HOSTNAME=${CUPS_HOSTNAME:-$(hostname -f)} # no need to set this usually -> allows accessing cups via name: https://cups.domain:631/
# pass the server cert/key via env in one line each, i.e. CUPS_SSL_CERT=---- BEGIN CERT ...\none\nline\nseparated\nby\nbackslash\nnewline
CUPS_SSL_CERT=${CUPS_SSL_CERT:-""}
CUPS_SSL_KEY=${CUPS_SSL_KEY:-""}
# avahi configuration options
AVAHI_INTERFACES=${AVAHI_INTERFACES:=""}
AVAHI_IPV6=${AVAHI_IPV6:="no"}
AVAHI_REFLECTOR=${AVAHI_REFLECTOR:="no"}
AVAHI_REFLECT_IPV=${AVAHI_REFLECT_IPV:="no"}
```

### Add printer through ENV
Set any number of variables which start with `CUPS_LPADMIN_PRINTER`. These will be executed at startup to set up printers through `lpadmin`.
```shell script
CUPS_LPADMIN_PRINTER1=lpadmin -p brother -D 'Brother HL2270 printer' -m 'HL2270DW.ppd' -v lpd://<printer-host>/BINARY_P1
CUPS_LPADMIN_PRINTER1_ENABLE=cupsenable brother
CUPS_LPADMIN_PRINTER1_ACCEPT=cupsaccept brother
CUPS_LPADMIN_PRINTER2=lpadmin -p second -D 'another' -m everywhere -v ipp://myhost/second
CUPS_LPADMIN_PRINTER3=lpadmin -p third -D 'samba printer' -m '..the right driver string...' -o PageSize=A4 -v smb://user:pass@host/printer
```

### Configure AirPrint
Nothing to do, it will work out of the box (once you've added printers)
* If you have multiple subnets then make sure mDNS is turned on your router to support airprint across the entire network. 

### Ports:
* `631`: the TCP port for CUPS must be exposed

## Docker Run
To simply do a quick and dirty run of the cups/airprint container:
```
docker run \
    -d --rm \
    --net=host \
    -e CUPS_WEBINTERFACE="yes" \
    -e CUPS_REMOTE_ADMIN="yes" \
     --name cups \
     rogerrum/cups-airprint
  
```
To stop the container simply run:
```
$ docker stop cups
```
To remove the conainer simply run:
```
$ docker rm cups
```
**WARNING**: Be aware that deleting the container (i.e. `cups` in the example)
will permanently delete the data that `docker volume` is storing for you.
If you want to permanently persist this data, pass the CUPS_LPADMIN_PRINTER env variable to setup the printer on startup 

## Docker Compose
If you don't want to type out these long **Docker** commands, you could
optionally use [docker-compose](https://docs.docker.com/compose/) to set up your
image. Just download the repo and run it like so:

```yaml
version: '3.8'
services:
  cups:
    image: rogerrum/cups-airprint:latest
    container_name: cups
    network_mode: host
    restart: unless-stopped
    environment:
      - CUPS_REMOTE_ADMIN="yes"
      - CUPS_REMOTE_ADMIN="yes"
      - CUPS_LPADMIN_PRINTER1=lpadmin -p brother -D 'Brother HL2270 printer' -m 'HL2270DW.ppd' -v lpd://<printer-host>/BINARY_P1
      - CUPS_LPADMIN_PRINTER1_ENABLE=cupsenable brother
      - CUPS_LPADMIN_PRINTER1_ACCEPT=cupsaccept brother
```

## Issues:
https://github.com/rogerrum/cups-airprint/issues

# Credits
This is based on awesome work of others
* https://github.com/quadportnick/docker-cups-airprint
* https://github.com/DrPsychick/docker-cups-airprint
* https://github.com/RagingTiger/cups-airprint

# Contribute
* I am happy for any feedback! Create issues, discussions, ... feel free and involve!
* Send me a PR
