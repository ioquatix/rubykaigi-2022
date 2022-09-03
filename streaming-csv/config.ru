require 'csv'

run do |env|
	body = proc do |stream|
		csv = CSV.new(stream)
		
		while true
			csv << ["Hello", "World"]
		end
	end
	
	[200, {'content-type' => 'text/csv'}, body]
end
