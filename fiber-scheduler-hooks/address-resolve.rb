#!/usr/bin/env ruby

require 'async'

Async do |task|
	5.times do
		task.async do
			puts "Starting request..."
			# This operation uses non-blocking DNS resolution:
			Addrinfo.getaddrinfo("www.google.com", 80, :INET, :STREAM).tap{|result| puts "Finished request: #{result}"}
		end
	end
end
