require 'mysql2'
require 'digest'
require 'dotenv/load'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "''")
end

def clean_names(client)
  begin
    create_table_query = <<~SQL
      CREATE TABLE hle_dev_test_lucas_fernandes
      AS SELECT * FROM hle_dev_test_candidates;
    SQL

    client.query(create_table_query)

    add_columns_query = <<~SQL
      ALTER TABLE hle_dev_test_lucas_fernandes
        ADD clean_name VARCHAR(150),
        ADD sentence VARCHAR(255),
      ADD CONSTRAINT unique_name UNIQUE (candidate_office_name);
    SQL

    client.query(add_columns_query)

  rescue Mysql2::Error
    insert_data_query = <<~SQL
      INSERT IGNORE INTO hle_dev_test_lucas_fernandes(name)
      SELECT DISTINCT name FROM hle_dev_test_candidates;
    SQL
  end

  retrieve_data_query = <<~SQL
    SELECT * FROM hle_dev_test_lucas_fernandes
  SQL

  names = client.query(retrieve_data_query).to_a

  names.map do |name|
    clean_name = name['candidate_office_name']
    .gsub(/^[^\/,]+$/, &:downcase)
    .gsub(/([^\/,]+,)/,&:downcase)
    .gsub(/,\s+([^\/,]+(?=(\/|$)))/, ' (\1)')
    .gsub(/([^\/]+)\/([^\/]+)\/([^\/]+)/) { "#{$3} #{$1.downcase} and #{$2.downcase}" }
    .gsub(/([^\/]+)\/([^\/]+)/) { "#{$2} #{$1.downcase}" }
    .gsub(/\bTwp\b/i, 'Township')
    .gsub(/\bHwy\b/i, 'Highway')
    .gsub(/\b(\w+)\b\s+\1\b/i, '\1')
    .strip
    
    insert_clean_name_query = <<~SQL
      UPDATE hle_dev_test_lucas_fernandes
      SET clean_name = '#{escape(clean_name)}'
      WHERE candidate_office_name = '#{escape(name['candidate_office_name'])}'
    SQL

    client.query(insert_clean_name_query)

    insert_sentence_query = <<~SQL
      UPDATE hle_dev_test_lucas_fernandes
      SET sentence = 'The candidate is running for the #{escape(clean_name)} office.'
      WHERE candidate_office_name = '#{escape(name['candidate_office_name'])}'
    SQL

    client.query(insert_sentence_query)
  
  end

end

clean_names(client)
