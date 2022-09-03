#!/usr/bin/env ruby

require 'async'

Async do
	threads = 3.times.map do
		Thread.new do
			# Legacy code
			sleep 1
		end
	end
	
	# Non-blocking join - won't block the reactor.
	p threads.map(&:join)
end
