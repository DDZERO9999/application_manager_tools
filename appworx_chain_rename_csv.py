###UPDATE STRING IN APPWORX .EXP FILE for Process flows/chains.###
###Last updated: 7/11/2019###
###Last update: New functions 12/12/2019###
###Added class inplace of functions 12/19/2019###
###Removed writes from functions 12/20/2019###
import csv
import time

'''get start time to determine execution time'''
start_time = time.time()

def string_change(string):
    #Create lists for ^ place holder for search and replace
    count = (len(string))
    fstr_pos = 1
    frst_char = 1
    list_name = []
    #Add ^ to string  
    for z in string:
        while count >= 1:
            str1 = string[0:frst_char]
            str2 = string[fstr_pos:]
            list_name.append(str1 + '^' + str2)
            fstr_pos += 1
            frst_char +=1
            count -= 1
    return list_name

class Replace:
    def __init__(self, file, search, replace):
        self.file = file
        self.search = search
        self.replace = replace
    '''REPLACE SINGLE STRING '''
    def repsingle(self):
        global FILE
        FILE = self.file.replace(self.search, self.replace)
        return FILE

    #REPLACE STRINGS FROM A LIST
    def rep(self):
        #set variables
        global FILE
        count = len(self.search)
        X = 0   
        #change character
        FILE = self.file
        while X < count:
            FILE = FILE.replace(self.search[X], self.replace[X])
            #print(a[X], b[X])
            X += 1 
        return FILE

#Information to user about this program
print('This program renames chains/process flows for .exp files\n')
print('It is a good idea to check .exp for errors with editor before importing.\n')
print('Place .exp file and lists.csv in same directory as this script.\n')

#File to edit
input_file = input('File to edit (.exp): ')

#provide strings for seach and relplace in lists.csv file
#Convert .csv file into lists.
with open('lists.csv') as inputData:
    data = csv.reader(inputData)
    string1 = [row[0] for row in data]
    inputData.seek(0)
    string2 = [row[1] for row in data]

#open File
with open(input_file,"r") as FR:
    FILE = FR.read()
#print(FILE) #for test
'''Rename string without changes'''        
for j, f in zip(string1,string2):
    strings = Replace(FILE, j, f)
    strings.repsingle()

''' #Remove new line'''
delnewline = Replace(FILE,'\n', '~~')
delnewline.repsingle()

#Change with special character ^
for x, k in zip(string1,string2):
    search_str = string_change(x)
    replace_str = string_change(k)

    #Perform search and replace for chains.    
    srch_st1 = ('\\~~DELETE=', '\\~~START=', '\\~~so_predecessors=', '\\~~so_pred_ref_names=')    

    '''Run list search string srch_str'''
    for x in srch_st1:
        '''Remove string replace ^'''
        repwithcarot = Replace(FILE, x, '^')
        repwithcarot.repsingle()
        '''Rename ^'''
        repsearchstring = Replace(FILE,search_str,replace_str)
        repsearchstring.rep()                       
        '''Add srch_st1 back'''
        removecarot = Replace(FILE,'^',x)
        removecarot.repsingle()
   
# '''Add new line'''
addnewline = Replace(FILE,'~~', '\n')
addnewline.repsingle()

'''Inactivate schedules'''
repactive = Replace(FILE,'aw_active=Y', 'aw_active=N')
repactive.repsingle()

# #Write to the file     
with open(input_file,"w") as F:
    F.write(FILE)

print('Schedules inactive')
print('Complete')

end_time = time.time()
print("Total execution time: {}".format(end_time - start_time))