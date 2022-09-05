
require 'async/http/internet/instance'

run ->(env) do
	if env['PATH_INFO'] == '/concurrent'
		Sync do |task|
			internet = Async::HTTP::Internet.instance
			
			3.times.map do
				task.async{internet.get("https://httpbin.org/delay/1.0").finish}
			end.each(&:wait)
		end
	else
		Sync do |task|
			internet = Async::HTTP::Internet.instance
			
			3.times.map do
				internet.get("https://httpbin.org/delay/1.0").finish
			end
		end
	end
	[200, {}, ["Hello World!"]]
end
