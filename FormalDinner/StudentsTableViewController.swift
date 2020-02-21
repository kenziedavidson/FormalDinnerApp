//
//  ViewController.swift
//  FormalDinner
//


import UIKit


class StudentsTableViewController: UITableViewController, UISearchBarDelegate {
    
    // ensure searchbar is connected (the circle on margin is filled in) if not, drag to element in storyboard!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // listOfStudents contains all students from the python API call
    var listOfStudents = [StudentDetail]()
    // subsetOfStudents contains the (potentially) filtered list of students based upon search bar input
    var subsetOfStudents = [StudentDetail]()

    // viewDidLoad will make the only call to the python API to populate both listOfStudents and subsetOfStudents
    override func viewDidLoad() {
        super.viewDidLoad()
        // housekeeping to connect to UI
        tableView.dataSource = self
        // title doesn't display anywhere...?
        self.title = "Cate Formal Dinner Assignment"
        searchBar.delegate = self
        searchBar.placeholder = "Search by name or assignment..."
        
        let studentRequest = StudentRequest()
        
        // call python api and return student data object
        studentRequest.getStudents {  [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let students):
                //list of students is full list, subset at this point is full list. may be filtered by search
                self?.listOfStudents = students
                self?.subsetOfStudents = students
                DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.navigationItem.title = "\(self!.subsetOfStudents.count) Students found"
                }
            }
        }

    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView( _ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return subsetOfStudents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var student:StudentDetail
        student = subsetOfStudents[indexPath.row]
        tCell.textLabel?.text = student.assignment
        tCell.detailTextLabel?.text = student.lname + "," + student.fname

        return tCell

        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
            // When user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
        
         if searchText != "", searchText.count > 0 {
            // test all 3 collection items for matching with search by concatenating them together in the filter function call
            subsetOfStudents = listOfStudents.filter {
                return ($0.lname + $0.fname + $0.assignment).range(of: searchText, options: .caseInsensitive) != nil
            }
            tableView.reloadData()
        }
        }
    
    // what if user filters the list, but then wants to see entire list again? add cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
    
    // when cancel is pressed, repopulate table view with entire list of students
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            subsetOfStudents = listOfStudents
            tableView.reloadData()
    }
    
   func tableView(tableView: UITableView, titleForHeaderInSection section:Int) -> String?
   {
     return "Cate Formal Dinner Assignment"
   }
}
 

