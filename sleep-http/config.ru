class Sleep
	def call(env)
		sleep(0.1) # Simulate slow database query.
		[200, {}, []]
	end
end

run Sleep.new
