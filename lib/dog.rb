class Dog
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, id: nil, breed: )
    @id = id
    @name = name
    @breed = breed
  end



  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)
  end

  def save
     if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

 def self.create(attr_hash)
    dog = Dog.new(attr_hash)
    attr_hash.each {|key, value| dog.send(("#{key}="), value)}
    dog.save
  end
  
  def self.new_from_db(attr_array)
    Dog.new(id: attr_array[0],name: attr_array[1], breed: attr_array[2])
  end
  
   def self.find_by_id(id)
    sql="SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql,id)
    new_from_db(result[0])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed).first

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  
  
end


