#!/usr/bin/python3
# Framework for Simple http service with JSON reply
# John MacFarlane (2020)

import json
from http.server import BaseHTTPRequestHandler, HTTPServer


# non-repeat-fd.py family dinner table and work assignments, WITH non repeat addition
#2/12/20 modified to be a function that returns an array of collection items suitable for json transfer
#kenzie compsci
#done with my mom and jess
#changed the code because we don't need to produce the csv file anymore, and added "Table " + 0 fill on table numbers for easier searching in app,  

import random


#formal_dinner('Dinner Seating - Student List 2018-19 4.csv')


def formal_dinner(file_in, num_student_column=2,num_table=31, num_kitchen=7, label_kitchen='Kitchen', label_waiter='W'):

# added classes for our API to be read in Swift

    class Student():
        def __init__(self,assignmentType,id,fname,lname,assignment):
            self.assignmentType = assignmentType
            self.id = id
            self.fname = fname
            self.lname = lname
            self.assignment = assignment
            
    class StudentData():

        def __init__(self):
            self.status = "OK"
            self.numStudents = 0
            self.students = []
            #print("in student data.init")
            
        def addStudent(self,s):
            self.students.append(s)
            self.numStudents = self.numStudents + 1
            #print(s.lname+','+s.assignment)
            
# function returns JSON for API
        def toJSON(self):
            return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=4)   
            
    #declare list vars
    kitchen = []
    waiter = []
    waiter_option = []
    to_be_seated_option = []
    kitchen_option = []
    to_be_seated = []

    #read student file, Splitting on comma into a list and then slicing the list to retain the first three columns-- because we need the old assignment to make sure no repeats
    #now we know previous assignments
    try:
        with open(file_in) as student_file:
            for line in student_file:
                alist = line.split(',')
                #print(alist)
                x = slice(3)
                a = alist[x]
                #print(a)
                if a[2][:1] == label_waiter:
                    kitchen_option.append(a)
                    to_be_seated_option.append(a)               
                elif a[2] == label_kitchen:
                    waiter_option.append(a)
                    to_be_seated_option.append(a)
                else:
                    waiter_option.append(a)
                    kitchen_option.append(a)
                    to_be_seated_option.append(a)

    #waiterOption now contains student minus last week's waiters, same for kitchen
        
        num_student = len(to_be_seated_option)
        
        #randomly pick num_kitchen kitchen students and num_table waiter students
        #random.sample randomly select # of unique items without repetition
        waiter = random.sample(waiter_option,num_table)

    #have to try/except on all removes because just because a student is a waiter now doesn't mean it was in the kitchen option pool
        for each in waiter:
            try: 
                kitchen_option.remove(each)
            except ValueError:
                pass

        #making new kitchen assignments using kitchen option list so that new staff is made of students who didn't work last week
        kitchen = random.sample(kitchen_option,num_kitchen)

        #need to remove selected waiters and selected kitchen crew from our to be seated list
        #need try/except for same reason as above with waiters and kitchen_option...
        for each in waiter:
            try:
                to_be_seated_option.remove(each)
            except ValueError:
                pass
            
        for each in kitchen:
            try:
                to_be_seated_option.remove(each)
            except ValueError:
                pass


        sort_to_be_seated  = sorted(to_be_seated_option,key=lambda x: x[2])
    # if we sort the students left to be seated by their previous assignment,
    # and assign new tables in order, as long as there are more tables than students
    # at table, they won't be seated at same table
    
    
        jsonData = StudentData()
        
        id = 0
        counter = 1
        max_table = num_table
        for each_student in kitchen:
            s = Student('All',id,each_student[1],each_student[0],label_kitchen)
            jsonData.addStudent(s)
            id = id + 1
                
        for each_student in waiter:
            scounter = str(counter)

            s = Student('All',id,each_student[1],each_student[0],label_waiter+' '+ scounter.zfill(2))
            jsonData.addStudent(s)
            id = id + 1

            counter = counter + 1
            if counter > max_table:
                counter = 1

        counter = 1
        for each_student in sort_to_be_seated:
            scounter = str(counter)

            s = Student('All',id,each_student[1],each_student[0],'Table ' + scounter.zfill(2))
            jsonData.addStudent(s)
            id = id + 1

            counter = counter + 1
            if counter > max_table:
                counter = 1

    except IOError as err:
        print('IO Error reading student file: '+str(err))

    return jsonData.toJSON()

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        requestPath = self.path

        #Log to us
        print(f'\n----- GET Request Start ----->\n')
        print(f'Request path: {requestPath}')
        print(f'Request headers:\n')
        for line in self.headers:
            print(f'  > {line}: {self.headers[line]}')
        print(f'\n<----- GET Request End -----\n')

        #Answer 200 => OK Status
        self.send_response(200)

        #Add Headers if any needed
        #self.send_header("Set-Cookie", "cate=true")
        self.end_headers()
        json_reply = formal_dinner('Dinner Seating - Student List 2018-19 4.csv')
        #Body of reply
        self.wfile.write(json_reply.encode(encoding='utf_8'))

# Listen on Port 80

port = 80
print('Listening on localhost:%s' % port)
server = HTTPServer(('', port), RequestHandler)
server.serve_forever()


#data = formal_dinner('Dinner Seating - Student List 2018-19 4.csv', 'x.csv')
