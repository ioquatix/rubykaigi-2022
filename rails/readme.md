# Rails 7.1 Fiber Per Request

Rails 7.1 will likely introduce per-fiber ActiveRecord connection pool. This means each Falcon fiber-per-request can use the database without contention.

## Usage

> **Info:** You will need to have a local posgres server running for this example.

First, try it with per-thread isolation level. Start the server:

```
ISOLATION_LEVEL=thread bundle exec falcon serve
```

Then try making some requests:

``` bash
$ wrk https://0.0.0.0:9292/active_record
Running 10s test @ https://0.0.0.0:9292/active_record
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.02s    12.60ms   1.04s    63.64%
    Req/Sec     0.82      1.60     4.00     81.82%
  19 requests in 10.09s, 1.52KB read
  Socket errors: connect 0, read 0, write 0, timeout 8
Requests/sec:      1.88
Transfer/sec:     154.46B
```

You will see the request time starts to get slower and slower as each subsequent request has to wait for the previous one to complete before it can use the database connection:

```
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0288
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0222
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0183
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0241
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0213
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0171
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0130
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0152
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0113
127.0.0.1 - - [03/Sep/2022:17:12:10 +1200] "GET /active_record HTTP/1.1" 200 - 1.0102
127.0.0.1 - - [03/Sep/2022:17:12:11 +1200] "GET /active_record HTTP/1.1" 200 - 1.0044
127.0.0.1 - - [03/Sep/2022:17:12:12 +1200] "GET /active_record HTTP/1.1" 200 - 2.0046
127.0.0.1 - - [03/Sep/2022:17:12:13 +1200] "GET /active_record HTTP/1.1" 200 - 3.0074
127.0.0.1 - - [03/Sep/2022:17:12:14 +1200] "GET /active_record HTTP/1.1" 200 - 4.0101
127.0.0.1 - - [03/Sep/2022:17:12:15 +1200] "GET /active_record HTTP/1.1" 200 - 5.0127
127.0.0.1 - - [03/Sep/2022:17:12:16 +1200] "GET /active_record HTTP/1.1" 200 - 6.0158
127.0.0.1 - - [03/Sep/2022:17:12:17 +1200] "GET /active_record HTTP/1.1" 200 - 7.0183
127.0.0.1 - - [03/Sep/2022:17:12:18 +1200] "GET /active_record HTTP/1.1" 200 - 8.0205
127.0.0.1 - - [03/Sep/2022:17:12:19 +1200] "GET /active_record HTTP/1.1" 200 - 9.0243
127.0.0.1 - - [03/Sep/2022:17:12:20 +1200] "GET /active_record HTTP/1.1" 200 - 10.0271
```

Let's try using per-fiber ActiveRecord connection pool. Start the server:

```
ISOLATION_LEVEL=thread bundle exec falcon serve
```

Then try making some requests:

```
Running 10s test @ https://0.0.0.0:9292/active_record
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.01s     7.80ms   1.03s    89.01%
    Req/Sec     9.48     14.02    40.00     82.61%
  91 requests in 10.09s, 7.29KB read
Requests/sec:      9.02
Transfer/sec:     739.50B
```

You will see the requests do not content with each other and have a consistent response time:

```
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0189
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0179
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0188
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0189
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0188
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0168
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0162
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0213
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0183
127.0.0.1 - - [03/Sep/2022:17:15:57 +1200] "GET /active_record HTTP/1.1" 200 - 1.0212
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0017
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0013
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0022
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0031
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0033
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0033
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0033
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0037
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0042
127.0.0.1 - - [03/Sep/2022:17:15:58 +1200] "GET /active_record HTTP/1.1" 200 - 1.0037
```
