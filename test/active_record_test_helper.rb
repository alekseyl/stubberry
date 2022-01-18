require 'active_record'
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.create_table(:users) do |t|
  t.string :name
  t.string :last_name
end

ActiveRecord::Migration.create_table(:comments) do |t|
  t.belongs_to :user
  t.string :body
end

class User < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  def to_s
    body
  end
end


