EVENT_STREAM_HEADERS = {
	'content-type' => 'text/event-stream',
	'cache-control' => 'no-cache',
}

HTML_HEADERS = {
	'content-type' => 'text/html',
}

run do |env|
	body = proc do |stream|
		while true
			stream.write("data: The time is #{Time.now}\n\n")
			sleep 1
		end
	end
	
	if env['PATH_INFO'] == '/time'
		[200, EVENT_STREAM_HEADERS.dup, body]
	else
		[200, HTML_HEADERS.dup, File.open('index.html')]
	end
end
