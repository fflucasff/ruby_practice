require 'mysql2';

client = Mysql2::Client.new(
  host: 'localhost', 
  username: 'root',
  password: '',
  database: 'lucas_fernandes_database'
)

def get_data(client)

  first_ten_query = <<~SQL
    SELECT * FROM people_lucas_fernandes LIMIT 10
  SQL

  puts client.query(first_ten_query).to_a 

  def look_at_data(client)
    doctors_query = <<~SQL
    SELECT COUNT(*) AS count FROM people_lucas_fernandes
    WHERE profession = 'doctor'
    SQL

    result = client.query(doctors_query).to_a

    count = result.first['count'] 

    puts count
  end

  look_at_data(client)

  select_query = <<~SQL
    SELECT * FROM people_lucas_fernandes
  SQL

  client.query(select_query).to_a.each do |row|
    update_query = <<~SQL
      UPDATE people_lucas_fernandes
      SET email2 = "#{row['email2'].gsub('gmail', 'hotmail')}"
      WHERE profession = "Ecologist" AND id = #{row['id']}
    SQL

    client.query(update_query) 
  end
end

get_data(client)

client.close
