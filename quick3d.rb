
i = File.new("3dcoorddata", "r")


#4 nums per line
#ex.
#2508    3       2       0

re = /([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)/

while l=i.readline
	re.match(l)

	puts "goto #{$1}; edit name ( #{$2}. #{$3}. #{$4} )"
end

