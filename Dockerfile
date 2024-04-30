FROM ubuntu:22.04

LABEL "repository"="https://github.com/clicktruck/toolset" \
      "maintainer"="Chris Phillipson <chris@clicktruck.org>"

COPY init.sh init.sh

SHELL [ "/bin/bash" ]

RUN [ "chmod", "+x", "init.sh" ]
RUN [ "./init.sh" ]
