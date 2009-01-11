

i = File.new("exits.txt", "r")

o = File.new("exits.output", "w")

begin 
	while 1
		l = i.readline

		j = 1

		re1 = /^([0-9]+)\s([a-z]+)\s/
		re2 = /^([0-9]+)/

		while m = re1.match(l)
			r1 = $1
			dir = $2
			
			l = m.post_match()
			r2 = re2.match(l)
	
			raise "invalid expression!" if not r2
	
			case dir
				when 'n'
					dirn = '0'
				when 'e'
					dirn = '1'
				when 's'
					dirn = '2'
				when 'w'
					dirn = '3'
				when 'u'
					dirn = '4'
				when 'd'
					dirn = '5'
				when 'nw'
					dirn = '6'
				when 'ne'
					dirn = '7'
				when 'se'
					dirn = '8'
				when 'sw'
					dirn = '9'
				else
					raise "unrecognized direction on line #{j}"
			end
	
			puts "goto #{r1}; pex #{dirn} #{r2}"
	
			j += 1
	
		end
	end

rescue EOFError
#rescue
	puts "program terminaed normally."
end

