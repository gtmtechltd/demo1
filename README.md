Demo PS server project
======================

Prerequisites
=============

You will need ruby installed. Ruby 1.8 should be sufficient, and is bundled with Centos 6. It has only been tested with ruby 1.8, but should work with other rubies.

Running
=======

To run, simply type: 

```
    sudo yum install ruby
    cd lib/
    ruby ./ps_server.rb
```

To run, testing with Docker (as I have), ensure docker is up and running and type:

```
    ./docker_test.sh
```

Testing
=======

When the server is running, type - either natively, or within the running docker container:

```
    curl http://localhost:1337/      # for a 404 response
    curl http://localhost:1337/ps    # to exercise the ps functionality
```

You can further test that the output is in correct JSON format by using:

```
    sudo yum install wget telnet
    sudo wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    sudo chmod 755 /usr/local/bin/jq

    curl http://localhost:1337/ps | jq -r .
```

You can further test that behaviour works with concurrent connections by using (for example):

```
    sudo yum install httpd
    ab -n 100 -c 10  http://localhost:1337/ps # simulate 10 concurrent connections over 100 times

    Concurrency Level: 10
    Complete requests: 100
    Failed requests:   0
    Total transferred: 422100 bytes
```

You can further test that behaviour works with slow connections by using telnet:

```
    telnet localhost 1337
    Connected to localhost.
    Escape character is '^]'.
    GET / HTTP/1.1
    Host: localhost

```

(enter twice)
    

Guide
=====

Here is a short guide to the files

```
    event_handler.rb      # simple event-handling module to be included in other classes
    json.rb               # JSON library which monkey patches base classes to allow to_json to output a JSON object
    logger.rb             # Logger library to make it easy to see logs and errors

    procfs_mapper.rb      # ProcFS reading libs to output the contents of the process table
    procfs_entry.rb       # by examining proc

    stream.rb             # Stream libraries which take input/output streams from the socket
    http_stream.rb        # and process them as HTTP requests

    server.rb             # Basic Event driven select(2) webserver

    ps_server.rb          # Entrypoint 
```

Design
======

As I am not able to use any third-party libraries, I have implemented in pure ruby:

* Base JSON functionality, for outputting of JSON
* Base socket-handling TCP server, ensuring to use nonblocking sockets, with select(2)
* Base procfs reading libs to capture any output of a process

* Single-threaded event-driven model, with callbacks  (timeouts not implemented)


Known Issues
============

* I have not tested with genuine Centos 6 installation involving unprivileged and privileged processes. 
  I am aware more work is required.

* I have not yet tested with timeouts, and deliberately timing out client-side connections. With a single-threaded
  server, obviously any uncaught exceptions would cause the server to die. 
