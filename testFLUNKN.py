#!/usr/bin/python
import csv
import sys
import argparse


#***********************************************************************************
#                           Script testFLUNKN.py                                   *
#***********************************************************************************

"""
Tests the FLUNKN bug fix in the parsePirep.pl PIREP decoder.
Usage: testFLUNKN.py [options] testData

Options:
 -h, --help         show this help
 testData           The name of the input PIREP test data (to be decoded by the
                    master decoder and the test decoder).

"""

#************************************************************************************
#Run tests on the output from parsePirep.pl to verify correct/expected behavior.
#The following tests are run:

#---Test 1 The /IC elevation is used instead of the /SK elevation information ---
#Test the changes to the parsePirep.pl decoder for FLUNKN with the SK group and
#IC group. The new parsePirep.pl decoder uses the IC group's elevation information 
#rather than the SK group's elevation information.  Run parsePirep.pl with the -i flag 
#to indicate that we want the icing flag turned on, save it as test.csv and rerun the 
#same data with the same parsePirep.pl without the -i flag.  Save this as master.csv 
#and compare the test.csv to the master.csv.  The only column that should be different is 
#column 6, the *altitude/flightLevel(100 ft MSL)* 


#---Test 2 The test parsePirep.pl (no icing flag) output is identical to the original/master ---
#Run the parsePirep.pl without the icing flag, and the original parsePirep.pl on the same data
#and verify that all rows and columns are identical.


#The script is very rudimentary and meant to be run on the host where the 
#icing data resides. This was meant to run in the /tmp directory to avoid any
#collisions/interference with on-going data processing. 
#************************************************************************************



def test(master_file, test_file):
    f1 = open(test_file,'rb')
    f2 = open(master_file, 'rb')

    c1 = csv.reader(f1, delimiter=",")
    c2 = csv.reader(f2, delimiter=",")
  
    #skip the header
    header = c1.next()    
    c2.next()

    #Set any flags here...
    #Assume that the test and master csv files are different where expected and the same otherwise.
    #this will be set to 'False' if any anticipated condition isn't met.
    passed = True
    
    #Create the data structures that will hold the
    #test and master data, respectively.
    test_data = []
    master_data = []
    for row in c1:
        test_data.append(row)

    for row in c2:
        master_data.append(row)

    #Do a quick check to see if the master_data and test_data have the same number of rows (i.e. number
    #of reports).
    if( len(test_data) != len(master_data)):
        print "The updated parsePirep.pl decoder does not decode the same number of PIREPs as the original decoder."
        passed = False

 

    #Now compare the elevation/altitude column in the test and master data.  These should be different.
    #If they are different, then make sure the other columns are identical between the test and master.
    for i in range(0,len(master_data)-1):
        num_cols = len(master_data[i])
        #Verify that the test decoder hasn't modified decoding of all the columns.  The exception to this is
        #the column corresponding to the flight level/altitude (which should be derived from the /IC group 
        #rather than the /SK group).
        for j in range(0,num_cols - 1): 
            if( j == 6 ):
                #Check the flight level/altitude column- these should be different, based on the input data used.
                if master_data[i][j] == test_data[i][j]:
                    print ("FAIL... Column number %s. Master data elev and Test data elev are the same, for report: %s")%(j,master_data[i][num_cols -1])
                    passed = False
                    print("Master Report: %s\n")%(master_data[i])
                    print("Test Report: %s\n")%(test_data[i])
                    print("================================================\n")
            else:
               if master_data[i][j] != test_data[i][j] :
                  print "FAILED... Column number %s, %s: %s. Test decoder value= %s"%(j,header[j], master_data[i][j],test_data[i][j])
                  passed = False
                  print("Master Report: %s\n")%(master_data[i])
                  print("Test Report: %s\n")%(test_data[i])
                  print("================================================\n")

    if (passed == False):
          print "The updates to parsePirep.pl did not produce the anticipated changes, and/or resulted in unexpected changes\n"


#-----------------main()---------------------------------

def main():
    parser = argparse.ArgumentParser(description="Tests that the test version of the parsePirep decoder behaves as expected relative to the master parsePirep decoder")
    parser.add_argument('-i','--input', help='full file name of the PIREP input file to be decoded',required=True) 
    parser.add_argument('-m', '--master', help='Full file name of Master parsePirep decoder',required =True)
    parser.add_argument('-t', '--test', help='Full file name of Test parsePirep decoder',required = True)
    args = parser.parse_args()
    print ("input PIREP: %s " %args.input)
    print ("Master decoder: %s " %args.master)
    print ("Test decoder: %s " %args.test)
    

    #Test 1 using the FLUNKN.PIREP data, which have /FLUNKN, /SK, and /IC groups
    #All columns should be identical except for the altitude/flightLevel(100 ft MSL) 
    #column from the test.csv file.  This file will now use the altitude information from
    #the /IC group.
    
    
    
    #Test 2 using the FLUNKN.PIREP data, with /FLUNKN, /SK, and /IC groups.  This time,
    #make sure the outpu from the test and master parsePirep.pl are identical if the 
    #icing flag is omitted from the command line.
    
#--------------------------------------------------------

if  __name__ == "__main__":
    main()

    



