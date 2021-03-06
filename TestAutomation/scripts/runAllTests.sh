#!/bin/bash

#Compile all .java files in /project/src/
for i in ./project/src/*.java;
do
  CMD="javac ./project/src/"${i##*/}
  eval $CMD
done

#for i in ./testCaseExecutables/*.java;
for i in ./testCaseExecutables/*.java;
do
  CMD="javac ./testCaseExecutables/"${i##*/}
  eval $CMD
done

#Delete temp dir
for i in ./temp/*;
do
  #echo ${i##*/}
  CMD="rm ./temp/"${i##*/}
  eval $CMD
done

#create Reports.html with header
{
  echo "<!DOCTYPE html>"
  echo "<html>" 
  echo "<body>" 
  echo "<h1>" 
  echo "TESTING REPORT" 
  echo "</h1>"
  echo "<table>"
  echo "<tr>"
  echo "  <th>Test Case Number</th>"
  echo "  <th>Requirment Tested</th>"
  echo "  <th>class.method tested</th>"
  echo "  <th>Driver Source</th>"
  echo "  <th>Oracle</th>"
  echo "  <th>Method Inputs</th>" 
  echo "  <th>Method Output</th>"
  echo "  <th>Test Result</th>"
  echo "</tr>"
} >> ./temp/Report.html 

#run all test cases
#
#for each .txt file in testCases..
FILES="./testCases/*.txt"
for f in $FILES
do
  SRC="./testCaseExecutables/"  #dir containing driver.java files
  COLOR="green"                #default color of test result indicating PASS
  echo "Processing $f file..."
  
  # Reads each line in file to a cell in an array called lines
  # ${lines[0]} = testCaseNumber
  # ${lines[1]} = requirement being tested
  # ${lines[2]} = class.method
  # ${lines[3]} = driver.java
  # ${lines[4]} = oracle
  # ${lines[5]} = inputs
  IFS=$'\n' read -d '' -r -a lines < "$f"
  
  #create source path from SRC variable and line 3
  SRC+="${lines[3]}"

  #DRIVER="/testCaseExecutables/" + ${lines[3]} - ".java"
  DRIVER="${lines[3]%.*}"
  
  #INPUTS =${lines[5]} + "," + ${lines[0]}
  INPUTS="${lines[5]}"
  INPUTS+=":"
  INPUTS+="${lines[0]}"
  
  #run driver with arguments in ${lines[5]} and  store result in ${lines[6]}
  
  RUNCMD="java testCaseExecutables.$DRIVER '$INPUTS'"
  eval "$RUNCMD"
  RESULT="./temp/"
  RESULT+="${lines[0]}"
  RESULT+=".txt"
  read -r lines[6] < $RESULT #reads first line of tmp/testCase.txt
  
  #compare ${lines[4]} to ${lines[6]} and store report in ${lines[7]}
  if [[ "${lines[4]}"  =  *"${lines[6]}"* ]]; then   ##uses pattern matching to ignore any spaces
  lines[7]="PASS"
  else
  lines[7]="FAIL"
  fi
  
  #Change $COLOR to red if test failed
  if [ "${lines[7]}" == "FAIL" ]; then
    COLOR="red"
  fi  
  
  #format row of table for this test case-
  {
    echo "<tr>"
    echo "  <td>"
    echo ${lines[0]}
    echo " </td>"
    echo "  <td>"
    echo ${lines[1]}
    echo " </td>"
    echo "  <td>"
    echo ${lines[2]}
    echo " </td>"
    echo "  <td>"
    echo ${lines[3]}
    echo " </td>"
    echo "  <td>"
    echo ${lines[4]}
    echo " </td>"
    echo "  <td>"
    echo ${lines[5]}
    echo " </td>" 
    echo "  <td>"
    echo ${lines[6]}
    echo " </td>"
    echo "  <td>"
    echo " <font color=\"$COLOR\">" #color codes test result for quick, easy assessment
    echo ${lines[7]}                #green indicates PASS; red indicates FAIL
    echo " </font>"
    echo " </td>"
    echo "</tr>"
  } >> ./temp/Report.html
  
done


#Reports.html footer
{
  echo "</table>"
  echo "</body>"
  echo "</html>"
} >> ./temp/Report.html

#launch Report.html 
x-www-browser ./temp/Report.html
