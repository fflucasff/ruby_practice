require 'csv'
require 'mysql2'

db_config = {
  host: 'localhost',
  username: 'seu_usuario_do_mysql',
  password: 'sua_senha_do_mysql',
  database: 'ruby_practice_db'
}

client = Mysql2::Client.new(db_config)

table_name = "people_your_name"
client.query("CREATE TABLE IF NOT EXISTS #{table_name} (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT)")

csv_file = File.join("ruby_practice", "people.csv")
CSV.foreach(csv_file, headers: true) do |row|
  name = row["name"]
  age = row["age"].to_i


  client.query("INSERT INTO #{table_name} (name, age) VALUES ('#{name}', #{age})")
end
