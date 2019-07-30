###UPDATE STRING IN APPWORX .EXP FILE for Process flows/chains.###
###reated: 8/23/2017###
###Last updated: 7/9/2019 Added functions###

import fileinput

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

def replace(file, a, b):
    #replace strings in loop
    with fileinput.FileInput(file, inplace=True) as file:
        for line in file:
            print(line.replace(a, b), end='')

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

#Perform search and replace for chains.

srch_st1 = ('\``DELETE=', '\``START=', '\``so_predecessors=')

'''Rename string'''
replace(input_file,string1,string2)
        
'''Remove new line'''
replace(input_file,'\n', '``')

'''Run list search string srch_str'''
for x in srch_st1:
    '''Remove string replace ^'''
    replace(input_file, x, '^')
    '''Rename ^'''
    count = len(search_str)
    count -= 1 #shorten list number
    while count != -1:
        replace(input_file, search_str[count], replace_str[count])
        count -= 1
                            
        '''Add srch_st1 back'''
        replace(input_file,'^',x)

'''Add new line'''
replace(input_file,'``', '\n')

'''Inactivate schedules'''
replace(input_file,'aw_active=Y', 'aw_active=N')

print('Schedules inactive')
print('Complete')


