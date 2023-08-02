require 'mysql2';

client = Mysql2::Client.new(
  host: 'localhost', 
  username: 'root',
  password: '',
  database: 'lucasfernandes_database' 
)

def get_data_from_table(client) 
  select_query = <<~SQL
    SELECT * FROM people_lucasfernandes;
  SQL

  client.query(select_query).to_a.each do |row|
    lastname = row['lastname'];

    unless row['lastname'].match?(/edited$/)
      updated_lastname = "#{lastname} edited"
    end
    
    update_query = <<~SQL
      UPDATE people_lucasfernandes
      SET email = "#{row['email'].downcase}", profession = "#{row['profession'].strip}", lastname =  "#{updated_lastname}"
      WHERE id = #{row['id']}; 
    SQL

    client.query(update_query)
  end
end

get_data_from_table(client)

client.close
