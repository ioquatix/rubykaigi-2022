#!/usr/bin/env ruby

require 'async'

items = [1, 1]
guard = Thread::Mutex.new

thread = Thread.new do
	5.times do |i|
		guard.synchronize {items << items[-1] + items[-2]}
	end
end

Async do
	5.times do |i|
		guard.synchronize {items << items[-1] + items[-2]}
	end
end

thread.join
p items # [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
