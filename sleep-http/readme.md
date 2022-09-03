# (Non-)Blocking Operation Simulator

This example simulates a blocking IO operation so we can compare the performance.

## Puma

Puma has a limited pool of workers, say 10 workers. Each worker can handle one request at a time. If each request takes 0.1 seconds, then each worker can handle 10 requests per second, so with 10 workers you can handle 100 requests per second in total.

Let's test that. First, start the server:

``` bash
> puma -t 10:10
Puma starting in single mode...
* Puma version: 5.6.5 (ruby 3.1.2-p20) ("Birdie's Version")
*  Min threads: 10
*  Max threads: 10
*  Environment: development
*          PID: 93763
* Listening on http://0.0.0.0:9292
Use Ctrl-C to stop
```

Then, confirm the performance with `wrk` which defaults to simultaneous 10 connections:

``` bash
$ wrk http://0.0.0.0:9292
Running 10s test @ http://0.0.0.0:9292
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   104.04ms    1.39ms 108.98ms   68.99%
    Req/Sec    47.91      4.96    50.00     86.87%
  961 requests in 10.08s, 48.80KB read
Requests/sec:     95.36
Transfer/sec:      4.84KB
```

See, we got roughly 100 requests per second. However, if we increase the number of clients to 20, performance stays the same (or can get worse).

``` bash
$ wrk -c 20 http://0.0.0.0:9292
Running 10s test @ http://0.0.0.0:9292
  2 threads and 20 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   324.04ms  352.70ms   1.36s    79.44%
    Req/Sec    47.88     18.84    70.00     46.97%
  961 requests in 10.09s, 50.47KB read
Requests/sec:     95.28
Transfer/sec:      5.00KB
```

Even thought the CPU usage is close to zero, we are limited by the thread-per-request model and fixed pool size. Notice that the latency per request has gone up by ~3x.

## Falcon

Falcon does not have a fixed pool size, so it will scale according to the incoming number of connections. As the process gets busy handling requests, it will spend more of it's time handling existing requests and less time accepting them, leading to a graceful degradation.

First, let's start the server (with one process):

``` bash
$ falcon --bind http://0.0.0.0:9292 --count 1
```

First, let's try 10 connections as we did with Puma:

``` bash
$ wrk http://0.0.0.0:9292
Running 10s test @ http://0.0.0.0:9292
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   102.35ms    1.05ms 108.29ms   70.31%
    Req/Sec    48.84      4.81    50.00     96.97%
  980 requests in 10.08s, 58.38KB read
Requests/sec:     97.20
Transfer/sec:      5.79KB
```

Let's try with 100 connections:

```
$ wrk -c 100 http://0.0.0.0:9292
Running 10s test @ http://0.0.0.0:9292
  2 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   102.66ms    1.73ms 120.45ms   75.78%
    Req/Sec   490.23     34.13   505.00     94.95%
  9800 requests in 10.09s, 583.79KB read
Requests/sec:    971.08
Transfer/sec:     57.85KB
```

As you can see, falcon scales up gracefully to handle 100 connections, each handling about 10 requests per second, giving a total of ~1000 requests per second. Notice that the latency stayed about the same.
