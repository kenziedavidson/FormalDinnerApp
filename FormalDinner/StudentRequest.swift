//
//  StudentRequest.swift
//  FormalDinner
//
//  Created by Kenzie Davidson on 2/14/20.
//  Copyright © 2020 Kenzie Davidson. All rights reserved.
//
//  Based mostly on YouTube video by Brian Advent

import Foundation

// constant catch for error conditions in the json load/decode
enum StudentError: Error{
    case noDataAvailable
    case canNotProcessData
}

struct StudentRequest {
    let resourceURL:URL
    init() {
        // change to whatever your api requires
        let resourceString = "http://localhost:80"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        // resourceURL is now ready to use in URLSession
        self.resourceURL = resourceURL
        
    }
    // getStudents will open session with API and decode the result in to student structures
    // Result is an array of StudentDetail class objects
    
    func getStudents(completion: @escaping(Result<[StudentDetail], StudentError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL){ data, _, _ in
        guard let jsonData = data else {
            completion(.failure(.noDataAvailable))
            return
        }
            // no error when hitting api! yay!
        do {
            let decoder = JSONDecoder()
            //print(jsonData)
            let studentsResponse = try decoder.decode(Students.self, from: jsonData)
            let studentDetails = studentsResponse.students
            //print("in function getStudents")
            //print(studentDetails)
            // return studentDetails to caller on Success (as it returns data to the caller upon successful completion)
            completion(.success(studentDetails))
        } catch {
            completion(.failure(.canNotProcessData))
        }
        }
        // without this nothing works...
    dataTask.resume()
   
    }
    
}
