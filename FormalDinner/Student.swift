//
//  Student.swift
//  FormalDinner
//
//

import UIKit


// this structure mimics the python api, but doesn't include a couple of the fields. I'm only interested
// in the list of students... shows that the swift structures don't have to match the API exactly, just
// the names

struct Students: Decodable{
    var students:[StudentDetail]
}

struct StudentDetail: Decodable {
    var assignment: String = ""
    var assignmentType: String = ""
    var fname: String = ""
    var id: Int = 0
    var lname: String = ""
}
