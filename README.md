![Logo][svg-duck-logo]

# Docker Wildduck
Get the [nodemailer/wildduck][github-wildduck] email server as a Docker
service.

_This project is part of the [Astzweig][astzweig] social responsibility
program._

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
[setup-scripts]: https://github.com/nodemailer/wildduck/tree/master/setup
[dockerhub-houlagins]: https://hub.docker.com/r/houlagins/wildduck/
[dockerhub-hechengjin]: https://hub.docker.com/r/hechengjin/mailserver/
[eupl]: https://eupl.eu/1.2/en/
[duck-logo]: https://thenounproject.com/term/duck/33145/
