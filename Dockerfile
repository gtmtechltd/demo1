FROM centos:6

RUN yum install -y ruby man-pages man wget telnet
RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64

RUN mkdir /tmp/lib
RUN chmod 755 /usr/local/bin/jq
ADD lib/*.rb /tmp/lib/
ADD *.sh /tmp/lib/

EXPOSE 1337

