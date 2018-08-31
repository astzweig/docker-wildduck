![Logo][svg-duck-logo]

# Docker Wildduck
Get the [nodemailer/wildduck][github-wildduck] email server as a Docker
service.

_This project is part of the [Astzweig][astzweig] social responsibility
program._

# Table of contents

* [Usage](#user-content-usage)
  - [From source](#user-content-from-source)
  - [From Docker Hub](#user-content-from-docker-hub)
* [Environment variables](#user-content-environment-variables)
  - [General](#user-content-general)
  - [Wildduck API](#user-content-wildduck-api)
  - [API configuration profile](#user-content-api-configuration-profile)
  - [Wildduck IMAP](#user-content-wildduck-imap)
  - [Build Args](#user-content-build-args)
  - [Build Args](#user-content-build-args)
* [Development decisions](#user-content-development-decisions)
* [Roadmap](#user-content-roadmap)
* [Alternatives](#user-content-alternatives)
* [License](#user-content-license)


## Usage
There are multiple ways to run this container and even more for
experienced users. For the impatience user we have some example
configurations prepared:

* [From source](#user-content-from-source)
* [From Docker Hub](#user-content-from-docker-hub)

Both ways will result in a fully functional mailserver that - depending
on your configuration - will either listen on IMAP port (143) and
submission port (587) or if SSL is enabled and you provid valid keys
will listen on IMAPS port (993) and SMTPS port (465).

### From source
Checkout this repository on the computer/server, change into the
cloned repository folder and edit [docker-compose.yml][compose1-in-repo]
as you wish.

```bash
$ git clone https://github.com/astzweig/docker-wildduck.git
$ cd docker-wildduck
$ vi docker-compose.yml
```

You should at least replace the values of the variables in that file.
Afterwards you can just run:

```bash
$ docker-compose up -d mail
```

### From Docker Hub
Copy the contents of the provided [docker-compose.yml][compose2-in-repo]
file with eiter `curl` or `wget` anywhere on your server:

```bash
$ curl -o 'docker-compose.yml' https://raw.githubusercontent.com/astzweig/docker-wildduck/master/docker-compose.hub.yml

 - or -

$ wget -O 'docker-compose.yml' https://raw.githubusercontent.com/astzweig/docker-wildduck/master/docker-compose.hub.yml
```

Afterwards you can just run:

```bash
$ docker-compose up -d mail
```

## Environment variables
The following tables shows a complete list of variables that you can
use to modify the container's build or runtime behaviour. A bold font
means you will have to provide a value in order for the container to
work correctly. An italic font means the setting can be overridden
individually for each email account.

### General
| Name | Meaning |
| --- | --- |
| **FQDN** | The fully qualified domain name of your docker host server. It is important that you understand what a [FQDN][fqdn] is. |
| MAIL_DOMAIN | The first domain you want Wildduck to receive emails for. This will also be the standard Domain when you create users and do not supply a domain name. Default: The value you supplied at FQDN |
| PRODUCT_NAME | A name that will be used to advertise the email service on communication with third parties e.g. in SMTP HELO. Default: Wildduck Mail |
| TLS_KEY | The in-container path to the private SSL key to use for all Wildduck services. If no value is provided, SSL (IMAPS, SMTPS, etc.) will be disabled. |
| TLS_CERT | The path to the public full chain SSL key to use for all Wildduck services. |
| REDIS_HOST | The connection URL of redis. Default: redis://redis:6379/8 |
| MONGODB_HOST | The connection URL of mongodb. Default: mongodb://mongodb:27017/wildduck |
| GRAYLOG_HOST_PORT | The hostname (or IP address) and port of the graylog server, e.g. graylog:12201. If set logging to graylog will be enabled. |
| ENABLE_STARTTLS | Enable StartTTLS capability of the IMAP and SMTP Server. Default: false |

### Wildduck API
| Name | Meaning |
| --- | --- |
| API_ENABLE | Enable the Wildduck API. Default: true |
| API_USE_HTTPS | Enable SSL for the API. Usually you want to disable it, if you use a reverse proxy. Default: false |
| API_URL | The URL at which the API is available from outside docker. E.g. 'https://example.com/api'. Default: https://$FQDN:443 if API_USE_HTTPS is set to true and TLS_* variables are provided else http://$FQDN:80 |
| API_TOKEN_SECRET | The token that the API will require to accept a call (given either through an HTTP header (X-ACCESS-TOKEN) or as a URL parameter (?accessToken=...). Leaving this variable empty or not defining it is a possible dangerous step, as anyone will be able to make API calls (and as such create users, etc.). This option should only be left empty by users who know what they are doing. |

#### API Configuration Profile

As the Wildduck API supports two factor (2fa) authentication, it also
supports application specific passwords. When an application specific
password is generated, the API generates also a so called
[Apple configuration profile][apple-profiles] automatically. That is a
file, that allows iOS and macOS devices, to set up accounts (e.g. in
this case email accounts) automatically. The following variables can be
used, to configure the metadata of those configuration profiles.

| Name | Meaning |
| --- | --- |
| CONFIGPROFILE_ID | The id for the configuration profile. According to the [specification][apple-profiles] a reverse-DNS style identifier. Default: The top level domain and the domain of the FQDN in reversed order |
| CONFIGPROFILE_DISPLAY_NAME | The name of the iOS mobile configuration that gets generated. Default: $PRODUCT_NAME |
| CONFIGPROFILE_DISPLAY_ORGANIZATION | The name of the organization which is providing the email service. Default: Unknown |
| CONFIGPROFILE_DISPLAY_DESC | The description of the contents of the profile. Maybe even a notice to the mobile user. '{email}' is replaced with the corresponding email address. Default: Install this profile to setup {email} |
| CONFIGPROFILE_ACCOUNT_DESC | The description of the account that is setup by the configuration profile. '{email}' is replaced as for 'CONFIGPROFILE_DISPLAY_DESC'. Default: {email} |

### Wildduck IMAP
| Name | Meaning |
| --- | --- |
| IMAP_PROCESSES | The number of IMAP processes to start. Default: 2 |
| IMAP_RETENTION | The amount of days after which messages in Trash or Junk folder shall be deleted automatically. Default: 4 |

### Build ARGS
These variables can be used to define the service versions that are used
in the container. They change only the build time behaviour.
| Name | Meaning |
| ---  | --- |
| SCRIPTS_DIR | Path where the scripts folder is uploaded inside the container. Default: '/root/scripts' |
| INSTALL_DIR | Path where the components (Wildduck, Haraka, etc.) will be installed inside the container. Default: '/var/nodemailer' |
| WILDDUCK_GIT_REPO | The git repository URL of [Wildduck][github-wildduck] (or your fork of it). Default: 'https://github.com/nodemailer/wildduck.git' |
| WILDDUCK_GIT_CID | The git commit ID or branch namer you want to checkout of the Wildduck git repository. Default: 'master' |
| HARAKA_VERSION | The version of [Haraka][github-haraka] to download and use. Default: '2.8.21' |
| HARAKA_WD_PLUGIN_GIT_REPO | The git repository URL of the [Wildduck plugin][github-haraka-wd-plugin] for [Haraka][github-haraka] (or your fork of it). Default: 'https://github.com/nodemailer/haraka-plugin-wildduck' |
| HARAKA_WD_PLUGIN_GIT_CID | The git commit ID or branch name you want to checkout of the Wildduck plugin for Haraka git repository. Default: 'master' |
| ZONEMTA_GIT_REPO | The git repository URL of [ZoneMTA][github-zonemta] (or your fork of it). Default: 'https://github.com/zone-eu/zone-mta-template.git' |
| ZONEMTA_GIT_CID | The git commit ID or branch name you want to checkout of the ZoneMTA git repository. Default: 'master' |
| ZONEMTA_WD_PLUGIN_GIT_REPO | The git repository URL of the [Wildduck plugin][github-zonemta-wd-plugin] for [ZoneMTA][github-zonemta] (or your fork of it). Default: 'https://github.com/nodemailer/zonemta-wildduck.git' |
| ZONEMTA_WD_PLUGIN_GIT_CID | The git commit ID or branch name you want to checkout of the Wildduck plugin for ZoneMTA git repository. Default: 'master' |

## Development decisions
- We will use shell scripts to run commands instead of writing
  everything in the Dockerfile. We want the build-stage scripts to form
  a sequence and thus we define a script naming scheme that contains an
  ordering prefix of two digits.
- Scripts that are not meant to be executed by their own start with an
  underscore. They are not moved out of the scripts folder inside the
  container and their execution bit is not set.
- Scripts that are meant to be executables in the running container
  will be in a sub-folder called 'bin'. They can have any name, with or
  without extension. They will be moved into one of the system paths.
- There is exactly one 'entrypoint.sh' script, that is the default
  command of the container.
- The container needs three components to run (Wildduck, Haraka and
  ZoneMTA). Each of those components has to be installed first, to be
  configured in a second step and to be started in a third step. We
  write one component script for each one of those components
  containing a functions for two of the steps above: a
  configure_{service} function and a start_{service} function. To make
  use of Docker image layer caching we implement the install step of
  each component in a single BUILD script.

## Roadmap
* Provide a docker container with the pre-installed services as done by
  the [setup scripts][setup-scripts] provided by the
  [Wildduck][github-wildduck] project.
* Provide scripts to configure the docker container using environment
  variables.

## Alternatives
Before starting to build this image we looked around for alternatives
and found [houlagins][dockerhub-houlagins]'s and
[hechengjin][dockerhub-hechengjin]'s containers. We still decided to go
for our own solution, as neither of them provides their build files or
a corresponding code repository. And - for some maybe less important -
neither does any of them provide a useful documentation.

## License
* Licensed under the [EUPL][eupl].
* Logo: [Duck by Milky - Digital innovation from the Noun Project][duck-logo].


[svg-duck-logo]: https://raw.githubusercontent.com/astzweig/docker-wildduck/master/duck-logo.svg?sanitize=true
[github-wildduck]: https://github.com/nodemailer/wildduck
[astzweig]: https://astzweig.de/ges-ver
[compose1-in-repo]: https://raw.githubusercontent.com/astzweig/docker-wildduck/master/docker-compose.yml
[compose2-in-repo]: https://raw.githubusercontent.com/astzweig/docker-wildduck/master/docker-compose.hub.yml
[fqdn]: https://easyengine.io/tutorials/mail/fqdn-reverse-dns-ptr-mx-record-checks
[apple-profile]: https://developer.apple.com/business/documentation/Configuration-Profile-Reference.pdf
[wildduck_webmail_demo]: https://webmail.wildduck.email
[github-haraka]: https://github.com/haraka/Haraka
[github-haraka-wd-plugin]: https://github.com/nodemailer/haraka-plugin-wildduck
[github-zonemta]: https://github.com/zone-eu/zone-mta-template
[github-zonemta-wd-plugin]: https://github.com/nodemailer/zonemta-wildduck
[setup-scripts]: https://github.com/nodemailer/wildduck/tree/master/setup
[dockerhub-houlagins]: https://hub.docker.com/r/houlagins/wildduck/
[dockerhub-hechengjin]: https://hub.docker.com/r/hechengjin/mailserver/
[eupl]: https://eupl.eu/1.2/en/
[duck-logo]: https://thenounproject.com/term/duck/33145/
