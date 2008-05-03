uses_connection Rails plugin
======
This is a fairly simple but handy plugin that lets you specify which database connection to use on a per-model basis. It is useful when you have multiple applications sharing the same data.

Usage Example
======
First lets create a 'shared' database configuration in config/database.yml:

<pre><code>
shared:
  adapter: mysql
  database: shared_database
  username: user
  password: password
  host: dbs_host
</code></pre>

Next we tell our model that it should connect the the 'shared' database and use the table there...

<pre><code>
class ZipCode < ActiveRecord::Base
  # Uses the 'shared' database in all environments
  uses_connection :shared, :in => :all
end
</code></pre>

... and voila, the next time you do

<pre><code>
ZipCode.find(:first)
</code></pre>

or any other interaction with the ZipCode model it will use the zip\_codes table in your shared database! In other words, this is just a nicer way to use "Model.establish_connection(database)".

Documentation
======

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


Author
======
Thiago Jackiw: tjackiw at gmail dot com

Release Information
======
Released under the MIT license.