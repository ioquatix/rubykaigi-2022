# Streaming CSV

This example shows how to stream CSV records. You can do something similar with [newline-delimited JSON](http://ndjson.org).

## Usage

Start the server:

``` bash
$ falcon
```

Then stream the output:

``` bash
$ curl --insecure -N https://localhost:9292
Hello,World
Hello,World
Hello,World
Hello,World
Hello,World
```
