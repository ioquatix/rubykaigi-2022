#!/usr/bin/env ruby

require 'async'
require 'timeout'

Async do
	Timeout.timeout(1) do
		puts "Sleeping #{Time.now}..."
		sleep(10)
	end
rescue => error
	puts "Error #{error.inspect} at #{Time.now}"
end

# Total execution time ~1 second.
