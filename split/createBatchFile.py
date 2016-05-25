f = open('batchExecute.bat','w')

fileName = "C:\\Users\\Alienware\\Documents\\MATLAB\\NAVIGATION\\SISTEMA\\PROGRAMAS\\split\\OBS_FILE_II.sql."
command = 'psql -Upostgres -drinex -f\"' + fileName

f.write("set PGPASSWORD=123456\n")

for i in range(143):
	f.write(command + str(i) + '"' + "\n")
	
f.close()