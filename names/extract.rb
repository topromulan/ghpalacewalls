
i = File.new("raw", "r")

#ex.:
#$1	$2	$3	$4	$5
#36730	3	1	0	faux front lawn

re = /([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+(.*)/

j=0

begin
	while 1

		l = i.readline.chomp

		next if not re.match(l)

		j += 1
		t = 2.0 + j.to_f*0.2

		puts "#sched weed#{j} #{t} goto #{$1}; edit name (#{$2}. #{$3}. #{$4}) #{$5}"
	end
rescue
	puts "FINIS"
end
