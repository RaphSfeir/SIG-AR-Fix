puts "Testing sequel for Sig-Ar-Fix module. Independant from Ruby's gems."

require Dir.pwd + "/lib/sequel"


DB = Sequel.postgres(:host=>'54.246.97.87', :user=>'sigar', :password=>'rubyECN#2013', :database=>'sigar_test')
puts "Connected."
puts "Fetching personne table content : "
DB.fetch("SELECT * FROM personne") do |row|
  puts row[:nom_personne]
end