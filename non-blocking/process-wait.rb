#!/usr/bin/env ruby

require 'async'

Async do |task|
	5.times do
		task.async do
			puts "Starting child process..."
			system("sleep 1").tap do |result|
				puts "Finished child process: #{result}"
			end
		end
	end
end

# Total execution time ~1 second.