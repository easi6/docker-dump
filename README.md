# The [`bigtruedata/dump`](https://hub.docker.com/r/bigtruedata/dump/) Docker image

[![Docker Pulls](https://img.shields.io/docker/pulls/bigtruedata/dump.svg)](https://hub.docker.com/r/bigtruedata/dump/)
[![Docker Stars](https://img.shields.io/docker/stars/bigtruedata/dump.svg)](https://hub.docker.com/r/bigtruedata/dump/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Table of Contents
- [Overview](#overview)
- [Quick Start](#quick-start)


## Overview

This image provides a way of backing up specific resources as MySQL or MongoDB databases. It is based in the [`bigtruedata/cron`](https://hub.docker.com/r/bigtruedata/cron/) image to provide automatic scheduling of the specified dump. In sum, the most important features it includes are:
- time zone adjustment,
- automatic scheduled dumps
- SSL encryption of generated dumps and,
- output processing options.


## Quick Start

The execution of this image is parametrized using environment variables. There are three groups of variables that modifies the behaviour of the running container:
- the `TIME_SPEC` and `TIME_ZONE` variables that modify the time options of the image,
- the variables related to the dump command and,
- the variables related to the dump processing.

### Scheduling the execution of the dump command

The most important environment variable used to specify the dump command to ve executed is the `DUMP_COMMAND` variable. This variable is mandatory and **must** contain command that can be executed in the running container. The following example dump a listing of the root directory:
```sh
$ docker run --rm --tty --interactive --env "DUMP_COMMAND=ls -l /" bigtruedata/dump
```

The next section will show what the ouput of the previous command is used for.

### Changing the default processing of the dump ouput

By default the output of the dump command is redirected to a file in the `/dump` local directory. To access these dump files from the outside of the running container, the `/dump` directory should be used as a volumen when running the image. However, this behaviour can be changed by providing a value to the `OUTPUT_COMMAND` environment variable. It is important to notice the value of this variable should be a command that reads its imput from the standard input.

The following command stores the output of the `ls -l /` command to a file called `listing` in the root directory instead of the default `/dump` directory:
```sh
$ docker run --rm --tty --interactive --env "DUMP_COMMAND=ls -l /" --env "OUTPUT_COMMAND=cat - > /listing" bigtruedata/dump
```

### Setting the scheduling format

The previous sections described the excution and configuration of dump execution. What about changing when de dumps are generated? By default, the image is configured to executed the dump command once a day but this behaviour can be changed by specifying the correct value to the `TIME_SPEC` environment variable. The value provided is the same as used by the source [`bigtruedata/cron`](https://hub.docker.com/r/bigtruedata/cron/) image used whel building the image. More information can be found on the `crontab(5)` manual page on Unix systems manual.

The following command dumps system's date to the default destination every minute:
```sh
$ docker run --rm --tty --interactive --env "TIME_SPEC=* * * * *" --env "DUMP_COMMAND=date" bigtruedata/dump
```

### Adjusting the time zone of the local clock

I am working in another place whose local time is not UTC, can this image be configured to address that issue? Yes, it can! To change the local time zone, an appropiate value should be set to the `TIME_ZONE` environment variable. Those values are provided by the `tzdata` package of the Alpine Linux distribution and can be found in the [Alpine wiki](https://wiki.alpinelinux.org/wiki/Setting_the_timezone). The following command will output the local time each minute for a container working in Iran's timezone:
```sh
docker run --rm --tty --interactive --env "TIME_ZONE=Iran" --env "TIME_SPEC=* * * * *" --env "DUMP_COMMAND=date" --env "OUTPUT_COMMAND=cat -" bigtruedata/dump
```

### Ciphering the resulting dump

The image supports on-line encryption using symetic encoding with OpenSSL for generated dumps. There are two environment variables used to configure the encryption. By setting an appropiate value to the `CIPHER_ALGORITHM` the running containers uses the specified algorithm to encode the dump after it is generated. Legal values for this variable are the encoding commands provided by the OpenSSL package. By default this feature is deactivated and no encryption is performed on the generated dump.

When providing the cipher algorithm, a password is required to properly execute the command. This password is provided via the `CIPHER_PASSWORD` environment variable.

The following command outputs the encoded result of the dump usinh the `aes256` algorithm and providing the password `gungus`:
```sh
$ docker run --rm -ti -e "TIME_SPEC=* * * * *" -e "DUMP_COMMAND=date" -e "OUTPUT_COMMAND=cat -" -e "CIPHER_ALGORITHM=aes256" -e "CIPHER_PASSWORD=gungus" bigtruedata/dump:3.5
```
