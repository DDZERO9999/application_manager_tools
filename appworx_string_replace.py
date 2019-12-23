###UPDATE STRING IN APPWORX .EXP FILE for Process flows/chains.###
###DAVE DESALVO Created: 8/23/2017###
###Last updated: 7/9/2019 Added functions###
###Last update: 12/11/2019 Created two new functions to speed up process###
###Last update: 12/18/2019 Use class inplace of function###

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
   #open File
        with open(self.file,"r") as FR:
            FILE = FR.read()
        FILE = FILE.replace(self.search, self.replace)
        #Write to the file
        with open(self.file,"w") as F:
            F.write(FILE)     
    
    #REPLACE STRINGS FROM A LIST
    def rep(self):
        #set variables
        count = len(self.search)
        X = 0   
        #open File
        with open(self.file,"r") as FR:
            FILE = FR.read()
        #change character
        while X < count:
            FILE = FILE.replace(self.search[X], self.replace[X])
            #print(a[X], b[X])
            X += 1
            #Write to the file     
        with open(self.file,"w") as F:
            F.write(FILE)

#Information to user about this program
print('This program renames chains/process flows for .exp files\n')
print('It is a good idea to check .exp for errors with editor before importing.\n')
print('.exp files are unpredictable. Better it edit cycles in smaller chunks.\n')
print('Place .exp file in same directory as this script.\n')

#File to edit
input_file = input('File to edit (.exp): ')

#provide string and list name for search and replace

string1 = input('\nSearch string: ')
string1 = string1.upper()
string2 = input('\nReplace string: ')
string2 = string2.upper()

#Run string_change function for replace proccess. 
search_str = string_change(string1)
replace_str = string_change(string2)

'''Rename string without changes'''
strings = Replace(input_file,string1,string2)
strings.repsingle()
        
'''Remove new line'''
delnewline = Replace(input_file,'\n', '~~')
delnewline.repsingle()

#Perform search and replace for chains.
srch_st1 = ('\\~~DELETE=', '\\~~START=', '\\~~so_predecessors=', '\\~~so_pred_ref_names=')

'''Run list search string srch_str'''
for x in srch_st1:
    '''Remove string replace ^'''
    repwithcarot = Replace(input_file, x, '^')
    repwithcarot.repsingle()
    '''Rename ^'''
    repsearchstring = Replace(input_file,search_str,replace_str)
    repsearchstring.rep()                       
    '''Add srch_st1 back'''
    removecarot = Replace(input_file,'^',x)
    removecarot.repsingle()
    '''Add new line'''

addnewline = Replace(input_file,'~~', '\n')
addnewline.repsingle()

'''Inactivate schedules'''
repactive = Replace(input_file,'aw_active=Y', 'aw_active=N')
repactive.repsingle()

print('Schedules inactive')
print('Complete')