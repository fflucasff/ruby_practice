require 'mysql2'
require 'digest'
require 'dotenv/load'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

=begin
get_teacher(2, client)
get_subject_teachers(3, client) 
get_class_subjects("Chemistry", client) 
get_teachers_list_by_letter("a", client) 
set_md5(client) 
get_class_info(7, client) 
get_teachers_by_year(1981, client) 
random_date('1950-01-01', '1990-12-31') 
random_last_names(10, client) 
random_first_names(10, client) 
def generate_random_people(10, client) 
=end

generate_random_people(10, client)

client.close
