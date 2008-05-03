# Copyright (c) 2008 Thiago Jackiw
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'active_record'

module UsesConnection
  
  module ClassMethods
    
    # This is a fairly simple but handy plugin that lets you specify which database 
    # connection to use on a per-model basis. It is useful when you have multiple 
    # applications sharing the same data.
    # 
    # === options:
    # :in:: Accepts an array or a single symbol describing the environment it
    #       should use the connection for. Examples:
    # 
    #       class Book < ActiveRecord::Base
    #         # Uses the 'shared' database in all environments
    #         uses_connection :shared, :in => :all
    # 
    #         # Uses the 'shared' database in the production environment
    #         uses_connection :shared, :in => :production
    # 
    #         # Uses the 'shared' database in the production and development environments
    #         uses_connection :shared, :in => [:production, :development]
    #       end
    # 
    # 
    # :except:: Ignores the call if the current environment matches the array
    #           or the single symbol used to describe the environment.
    # 
    #           class Book < ActiveRecord::Base
    #             # Skips the plugin for the development environment
    #             uses_connection :shared, :in => :all, :except => :development
    # 
    #             # Skips the plugin for the development and test environments
    #             uses_connection :shared, :in => :all, :except => [:development, :test]
    #           end
    # 
    # And on your database.yml:
    # 
    # shared:
    #   adapter: mysql
    #   database: shared_database
    #   username: user
    # 
    def uses_connection(database=nil, args={})
      retried = false
      logger  = RAILS_DEFAULT_LOGGER
      options = { :in => [], :except => [] }
      options.update(args) if args.is_a?(Hash)
      
      raise(ArgumentError, "Please specify the environment that should use this connection.") if options[:in].to_s.empty?
      return true if (options[:except].is_a?(Array) ? options[:except].include?(RAILS_ENV.to_sym) : options[:except].to_s == RAILS_ENV)
      
      if options[:in] == :all || (options[:in].is_a?(Array) ? options[:in].include?(RAILS_ENV.to_sym) : options[:in].to_s == RAILS_ENV)
        raise(ArgumentError, "Please specify the database connection to use. The name has to be included on your config/database.yml file.") unless database
        begin
          self.establish_connection database
        rescue ActiveRecord::StatementInvalid => e
          if e.message =~ /MySQL server has gone away/
            if retried
              raise e
            else
              logger.info "-- uses_connection: StatementInvalid caught, trying to reconnect... --"
              self.connection.reconnect!
              retried = true
              retry
            end
          else
            logger.error "-- uses_connection: StatementInvalid caught, but unsure what to do with it: #{e} --"
            raise e
          end
        end
      end
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end

ActiveRecord::Base.class_eval { include UsesConnection }