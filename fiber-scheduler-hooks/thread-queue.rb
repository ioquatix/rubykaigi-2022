#!/usr/bin/env ruby

require 'async'

queue = Thread::Queue.new

Thread.new do
	3.times do |i|
		queue.push(i)
		sleep 1
	end
	
	queue.close
end

Async do
	while i = queue.pop
		puts i # 1, 2, 3
	end
end
