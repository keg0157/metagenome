import sys
inp = open(sys.argv[1],"r")
List = open("/home/masuda/DB/160705_library.list.txt","r")

dictionary = {}
for line in List:
	arr = line.split("\t")
	dictionary[arr[1].rstrip()] = arr[0]

for line in inp:
	print dictionary[line.rstrip()]
	

