
i = File.new('sectors.txt', 'r')

re = /([0-9]+)\s+([0-9]+)/

while l = i.readline
	re.match(l)

	puts "goto #{$1}; edit sector_type #{$2}"
end



	
