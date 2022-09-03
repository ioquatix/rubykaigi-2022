require 'active_support'
ActiveSupport::IsolatedExecutionState.isolation_level = ENV.fetch('ISOLATION_LEVEL', 'fiber').to_sym

require 'active_record'
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "test", pool: 64)

require 'async'
require 'db/client'
require 'db/postgres'

class Compare
	def initialize(app)
		@app = app
		@db = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))
	end
	
	def active_record_checkout(env)
		connection = ActiveRecord::Base.connection_pool.checkout
		connection.execute("SELECT pg_sleep(1)")
	ensure
		ActiveRecord::Base.connection_pool.checkin(connection)
	end
	
	def active_record_with_connection(env)
		ActiveRecord::Base.connection_pool.with_connection do |connection|
			connection.execute("SELECT pg_sleep(1)")
		end
	end
	
	def active_record(env)
		ActiveRecord::Base.connection.execute("SELECT pg_sleep(1)")
	end
	
	def db(env)
		@db.session do |session|
			session.query("SELECT pg_sleep(1)").call
		end
	end
	
	PATH_INFO = 'PATH_INFO'.freeze
	
	def call(env)
		_, name, *path = env[PATH_INFO].split("/")
		
		method = name&.to_sym
		
		if method and self.respond_to?(method)
			self.send(method, env)
			return [200, {}, ['ok']]
		else
			return @app.call(env)
		end
	end
end

use Rack::CommonLogger

use Compare

run lambda {|env| [404, {}, ["Not Found"]]}
