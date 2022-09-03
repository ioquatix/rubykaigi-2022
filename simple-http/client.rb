#!/usr/bin/env ruby

require 'async'

Async do
	socket = Socket.tcp('www.google.com', 80)
	socket.write("GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n")
	while line = socket.gets
		puts line
	end
end
