# Queueing

In order to see the impact of queueing on clients, you will need to use my custom fork of `wrk` which captures this information.

``` bash
$ git clone https://github.com/ioquatix/wrk
$ cd wrk
$ make
```

## Puma

Let's run puma with 4 workers:

``` bash
$ puma -t 4:4
```

Then, let's test it with `wrk`:

``` bash
$ ./wrk -t 1 -c 4 -d 10 "http://localhost:9292"
Running 10s test @ http://localhost:9292
  1 threads and 4 connections
connection 0: 10 requests completed
connection 1: 10 requests completed
connection 2: 10 requests completed
connection 3: 10 requests completed
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00s   283.54us   1.00s    70.00%
    Req/Sec     3.30      0.48     4.00     70.00%
  40 requests in 10.01s, 1.95KB read
Requests/sec:      4.00
Transfer/sec:     199.78B
```

As we expect, with 4 workers, and 4 clients, there are no issues.

Let's try with 8 clients:

``` bash
$ ./wrk -t 1 -c 8 -d 10 "http://localhost:9292"
Running 10s test @ http://localhost:9292
  1 threads and 8 connections
connection 0: 10 requests completed
connection 1: 10 requests completed
connection 2: 10 requests completed
connection 3: 10 requests completed
connection 4: 1 requests completed
connection 5: 1 requests completed
connection 6: 1 requests completed
connection 7: 1 requests completed
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00s   217.13us   1.00s    87.50%
    Req/Sec     5.25      7.83    30.00     91.67%
  44 requests in 11.02s, 2.22KB read
  Socket errors: connect 0, read 0, write 0, timeout 4
Requests/sec:      3.99
Transfer/sec:     206.63B
```

Since we only have 4 workers, only 4 connections can process requests. In addition, the 4 other connections are not handled fairly, and their only completed request is a timeout (see `Socket errors: ... timeout 4`).

## Falcon

Let's run Falcon with one event loop:

``` bash
$ falcon --bind http://localhost:9292 --count 1
```

Let's try making 8 clients:

``` bash
$ ./wrk -t 1 -c 8 -d 10 "http://localhost:9292"
Running 10s test @ http://localhost:9292
  1 threads and 8 connections
connection 0: 10 requests completed
connection 1: 10 requests completed
connection 2: 10 requests completed
connection 3: 10 requests completed
connection 4: 10 requests completed
connection 5: 10 requests completed
connection 6: 10 requests completed
connection 7: 10 requests completed
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00s   416.22us   1.00s    83.75%
    Req/Sec     7.50      0.53     8.00    100.00%
  80 requests in 10.11s, 5.70KB read
Requests/sec:      7.91
Transfer/sec:     577.62B
```

As you can see, all clients had their requests serviced. Let's try 100 clients:

``` bash
$ > ./wrk -t 1 -c 100 -d 10 "http://localhost:9292"
Running 10s test @ http://localhost:9292
  1 threads and 100 connections
connection 0: 10 requests completed
connection 1: 10 requests completed
connection 2: 10 requests completed
connection 3: 10 requests completed
connection 4: 10 requests completed
connection 5: 10 requests completed
connection 6: 10 requests completed
connection 7: 10 requests completed
connection 8: 10 requests completed
connection 9: 10 requests completed
connection 10: 10 requests completed
... all the same ...
connection 99: 10 requests completed
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00s     7.45ms   1.03s    90.30%
    Req/Sec   428.40    428.84     0.97k    75.00%
  1000 requests in 10.14s, 71.29KB read
Requests/sec:     98.61
Transfer/sec:      7.03KB
```

Because this application is not bound by CPU or memory usage, Falcon continues to process connections efficiently, but if you look closely, you see a slight degradation in latency. As you continue to push up the number of connected clients, Falcon will gracefully degrade:

``` bash
$ ./wrk -t 1 -c 5000 -d 10 "http://localhost:9292"
Running 10s test @ http://localhost:9292
  1 threads and 5000 connections
connection 0: 10 requests completed
connection 1: 10 requests completed
connection 2: 10 requests completed
connection 3: 10 requests completed
connection 4: 10 requests completed
connection 5: 10 requests completed
connection 6: 10 requests completed
connection 7: 10 requests completed
connection 8: 10 requests completed
connection 9: 10 requests completed
connection 10: 10 requests completed
... snip all the same ...
connection 2667: 10 requests completed
connection 2668: 9 requests completed
... snip all the same ...
connection 4999: 9 requests completed
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.08s   105.74ms   1.62s    90.23%
    Req/Sec     5.10k     3.34k   14.22k    73.03%
  47668 requests in 11.07s, 3.32MB read
Requests/sec:   4307.37
Transfer/sec:    307.07KB
```

In any case, you can push falcon a lot further with it's graceful approach to handling lots of connections.
