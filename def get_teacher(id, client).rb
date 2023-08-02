def get_teacher(id, client)
    f = "SELECT first_name, middle_name, last_name, birth_date FROM teachers_lucas_fernandes WHERE id = #{id}"
    results = client.query(f).to_a
    if results.count.zero?
      puts "Teacher with ID #{id} was not found."
    else
      puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime("%d %b %Y (%A)")}"
    end
  end
  
  # 1
  
  def get_subject_teachers(subject_id, client)
    q = <<~SQL
    SELECT s.name, t.first_name, t.middle_name, t.last_name FROM subjects_lucas_fernandes AS s
    JOIN teachers_lucas_fernandes AS t
      ON s.id = t.subject_id WHERE s.id = #{subject_id}
    SQL
  
    results = client.query(q).to_a
  
    if results.count.zero?
      puts "No one teaches the subject with ID #{subject_id}."
    else
      string = ""
      
      results.each do |row|
      string += "Subject: #{row['name']}\nTeachers:\n#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
      end
  
      puts string
    end
  end
  
  # 2
  
  def get_class_subjects(subject_name, client)
    q = <<~SQL
    SELECT c.name AS class_name, s.name AS subject_name, t.first_name, t.middle_name, t.last_name FROM classes_lucas_fernandes AS c
    JOIN teachers_classes_lucas_fernandes AS tc
      ON tc.class_id = c.id
    JOIN teachers_lucas_fernandes AS t
      ON t.id = tc.teacher_id
    JOIN subjects_lucas_fernandes AS s
      ON s.id = t.subject_id WHERE s.name = \"#{subject_name}\"
    SQL
  
      results = client.query(q).to_a
  
      if results.count.zero?
        puts "There is no teacher teaching #{subject_name}."
      else
        string = "Subject: #{results[0]['subject_name']}\n"
  
        results.each do |row|
        string += "Classes: #{row['class_name']} (#{row['first_name']} #{row['middle_name']} #{row['last_name']})\n"
        end
  
        puts string
      end
  end
  
  # 3
  
  def get_teachers_list_by_letter(letter, client)
    q = <<~SQL
    SELECT first_name, middle_name, last_name, s.name AS subject_name FROM classes_lucas_fernandes AS c
    JOIN teachers_classes_lucas_fernandes AS tc
      ON tc.class_id = c.id
    JOIN teachers_lucas_fernandes AS t
      ON t.id = tc.teacher_id
    JOIN subjects_lucas_fernandes AS s
      ON s.id = t.subject_id
    WHERE first_name LIKE '%#{letter}%' OR last_name LIKE '%#{letter}%'
    SQL
  
    results = client.query(q).to_a
  
    if results.count.zero?
      puts "There are no teachers whose first name or last name contains the letter \"#{letter}\""
    else
      string = ""
  
      results.each do |row|
      string += "#{row['first_name'][0] + '.'} #{row['middle_name'][0] + '.'} #{row['last_name']} (#{row['subject_name']})\n"
      end
  
      puts string
    end
  end
  
  # 4
  
  def set_md5(client)
    q = <<~SQL
    SELECT * FROM teachers_lucas_fernandes;
    SQL
  
    results = client.query(q).to_a
  
    results.each do |row|
      digested = Digest::MD5.hexdigest "#{row['middle_name']} #{row['middle_name']} #{row['last_name']} #{row['birth_date']} #{row['subject_id']} #{row['current_age']}"
  
      puts digested
  
      u = "UPDATE teachers_lucas_fernandes SET md5 = '#{digested}' WHERE id = #{row['id']};"
  
      client.query(u)
    end
  
  end
  
  # 5
  
  def get_class_info(class_id, client)
    involved_teachers = <<~SQL
    SELECT c.name, t.first_name, t.last_name FROM teachers_classes_lucas_fernandes AS tc
    JOIN classes_lucas_fernandes AS c
      ON tc.class_id = c.id
    JOIN teachers_lucas_fernandes AS t
      ON tc.teacher_id = t.id
    WHERE c.id = #{class_id};
    SQL
  
    responsible_teacher = <<~SQL
    SELECT c.name, t.first_name, t.last_name FROM classes_lucas_fernandes AS c
    JOIN teachers_lucas_fernandes AS t
      ON c.responsible_teacher_id = t.id
    WHERE c.id = #{class_id};
    SQL
  
    results_involved = client.query(involved_teachers).to_a
    results_responsible = client.query(responsible_teacher).to_a
  
    if results_involved.count.zero? or results_responsible.count.zero?
      puts "There are no involved or responsible teachers in class with id #{class_id}"
    else
      string = ""
  
      results_responsible.each do |row|
        string += "Class name: #{row['name']}\nResponsible teacher: #{row['first_name']} #{row['last_name']}\n"
      end
  
      results_involved.each do |row|
        string += "Involved teachers: #{row['first_name']} #{row['last_name']}"
      end
  
      puts string
    end
  end
  
  # 6
  
  def get_teachers_by_year(year, client)
    q = <<~SQL
    SELECT first_name name FROM teachers_lucas_fernandes
    WHERE YEAR(birth_date) = #{year}
    SQL
  
    results = client.query(q).to_a
  
    if results.count.zero?
      puts "There are no teachers born in #{year}"
    else
      string = "Teachers born in #{year}:"
  
      results.each do |row|
      string += " #{row['name']},"
      end
  
      puts string.gsub(/,$/, '.')
    end
  end
  
  # 7
  
  def random_date(begin_date, end_date)
    begin_date = Date.parse(begin_date)
    end_date = Date.parse(end_date)
  
    random_date = rand(begin_date..end_date)
  
    random_date
  end
  
  # 8
  
  def random_last_names(n, client)
    q = <<~SQL
    SELECT * FROM last_names
    ORDER BY RAND()
    LIMIT #{n}
    SQL
  
    results = client.query(q).to_a
  
    results.map { |row| row['last_name'] }
  end
  
  # 9
  
  def random_first_names(n, client)
    q = <<~SQL
      SELECT names FROM female_names
      UNION
      SELECT FirstName FROM male_names
      ORDER BY RAND()
      LIMIT #{n}
    SQL
  
    results = client.query(q).to_a
  
    results.map { |row| row['names'] }
  end
  
  # 10
  
  def generate_random_people(n, client)
    create_table = <<~SQL
    CREATE TABLE IF NOT EXISTS random_people_lucas_fernandes (
    id bigint(20) AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    birth_date DATE
    );
    SQL
  
    client.query(create_table)
  
    first_names = random_first_names(n, client)
    last_names = random_last_names(n, client)
    birth_dates = []
  
    n.times do 
      birth_dates << random_date("1923-01-01","2023-01-01").to_s
    end
  
    people = first_names.zip(last_names).zip(birth_dates).map(&:flatten)
  
    people.each_slice(10000) do |group| 
      insert = "INSERT INTO random_people_lucas_fernandes (first_name, last_name, birth_date) VALUES "
      group.each do |row|
        insert += "(\"#{row[0]}\", \"#{row[1]}\", \"#{row[2]}\"),"
      end
        client.query(insert.chop!)
    end
  
  end
  
   