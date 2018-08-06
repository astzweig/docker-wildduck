![Logo][svg-duck-logo]

# Docker Wildduck
Get the [nodemailer/wildduck][github-wildduck] email server as a Docker
service.

_This project is part of the [Astzweig][astzweig] social responsibility
program._

## Environment Variables
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
| TLS_KEY | The in-container path to the private SSL key to use for all Wildduck services. If no value is provided, SSL (IMAPS, SMTPS, etc.) will be disabled. Default: /etc/tls-keys/privkey.pem |
| TLS_CERT | The path to the public full chain SSL key to use for all Wildduck services. Default: /etc/tls-keys/fullchain.pem |
| REDIS_HOST | The connection URL of redis. Default: redis://redis:6379/8 |
| MONGODB_HOST | The connection URL of mongodb. Default: mongodb://mongodb:27017/wildduck |
| GRAYLOG_HOSTNAME | The hostname or IP address of graylog server. If set logging to graylog will be enabled. |

### Wildduck API
| Name | Meaning |
| --- | --- |
| API_ENABLE | Enable or disable the Wildduck API. Default: true |
| API_USE_HTTPS | Enable or disable SSL for the API. Usually you want to disable it, if you use a reverse proxy. Default: false |
| API_URL | The URL at which the API is available from outside docker. E.g. 'https://example.com/api'. Default: https://$FQDN:443 if API_USE_HTTPS is set to true else http://$FQDN:80 |
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
| IMAP_DISABLE_STARTTLS | Disable or enable StartTTLS capability of the IMAP Server. Default: false |

## Development Decisions
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

# Roadmap
* Provide a docker container with the pre-installed services as done by
  the [setup scripts][setup-scripts] provided by the
  [Wildduck][github-wildduck] project.
* Provide scripts to configure the docker container using environment
  variables.

# Alternatives
Before starting to build this image we looked around for alternatives
and found [houlagins][dockerhub-houlagins]'s and
[hechengjin][dockerhub-hechengjin]'s containers. We still decided to go
for our own solution, as neither of them provides their build files or
a corresponding code repository. And - for some maybe less important -
neither does any of them provide a useful documentation.

# License
* Licensed under the [EUPL][eupl].
* Logo: [Duck by Milky - Digital innovation from the Noun Project][duck-logo].


[svg-duck-logo]: https://raw.githubusercontent.com/astzweig/docker-wildduck/master/duck-logo.svg?sanitize=true
[github-wildduck]: https://github.com/nodemailer/wildduck
[astzweig]: https://astzweig.de/ges-ver
[fqdn]: https://easyengine.io/tutorials/mail/fqdn-reverse-dns-ptr-mx-record-checks
[apple-profile]: https://developer.apple.com/business/documentation/Configuration-Profile-Reference.pdf
[wildduck_webmail_demo]: https://webmail.wildduck.email
[setup-scripts]: https://github.com/nodemailer/wildduck/tree/master/setup
[dockerhub-houlagins]: https://hub.docker.com/r/houlagins/wildduck/
[dockerhub-hechengjin]: https://hub.docker.com/r/hechengjin/mailserver/
[eupl]: https://eupl.eu/1.2/en/
[duck-logo]: https://thenounproject.com/term/duck/33145/
