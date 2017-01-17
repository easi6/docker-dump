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
- automatic scheduled dumps and,
- dump processing options.


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

I am working in another place whose local time is not UTC, can this image be configured to address that issue? Yes, it can! To change the local time zone, an appropiate value should be set to the `TIME_ZONE` environment variable. The following command will output the local time each minute for a container working in Iran's timezone:
```sh
docker run --rm --tty --interactive --env "TIME_ZONE=Iran" --env "TIME_SPEC=* * * * *" --env "DUMP_COMMAND=date" --env "OUTPUT_COMMAND=cat -" bigtruedata/dump
```
