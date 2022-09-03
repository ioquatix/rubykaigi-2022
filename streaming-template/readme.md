# Streaming Template

This example shows how to stream real time HTML (or anything really) templates.

## Usage

Start the server:

``` bash
$ falcon
```

Check the streaming output:

``` bash
$ curl --insecure -N https://localhost:9292
<!DOCTYPE html><html><head><title>Beer Song</title></head><body>
  <p>99 bottles of beer on the wall</br>
     99 bottles of beer</br>
     take one down, and pass it around</br>
     98 bottles of beer on the wall</br></p>
  <p>98 bottles of beer on the wall</br>
     98 bottles of beer</br>
     take one down, and pass it around</br>
     97 bottles of beer on the wall</br></p>
  <p>97 bottles of beer on the wall</br>
     97 bottles of beer</br>
     take one down, and pass it around</br>
     96 bottles of beer on the wall</br></p>
```
