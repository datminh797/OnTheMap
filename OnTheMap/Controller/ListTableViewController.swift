//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import UIKit

class ListTableViewController: UITableViewController {
    @IBOutlet weak var studentTableView: UITableView!
    
    var myGuide: UIActivityIndicatorView!
    
    func getStudentsList() {
        showActivityIndicator()
        UdacityService.shared().getStudentLocations() {students, error in
            
            StudentsData.sharedInstance().students = students ?? []
            DispatchQueue.main.async {
                if error != nil {
                    self.showAlert(message: "Please try again later.", title: "Error")
                } else {
                    self.tableView.reloadData()
                }
                self.hideActivityIndicator()
            }
        }
    }
    
    override func viewDidLoad() {
        myGuide = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(myGuide)
        myGuide.bringSubviewToFront(self.view)
        myGuide.center = UIScreen.main.focusedView?.center ?? self.view.center
        showActivityIndicator()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStudentsList()
    }
    
    @IBAction func refreshList(_ sender: UIBarButtonItem) {
        getStudentsList()
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        showActivityIndicator()
        UdacityService.shared().logout {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let login = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                return
            }
            
            appDelegate.window?.rootViewController = login
            appDelegate.window?.makeKeyAndVisible()
            self.hideActivityIndicator()
        }
    }

   
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsData.sharedInstance().students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath)
        let student = StudentsData.sharedInstance().students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentsData.sharedInstance().students[indexPath.row]
        openLink(student.mediaURL ?? "")
    }

    func showActivityIndicator() {
        myGuide.isHidden = false
        myGuide.startAnimating()
    }
    
    func hideActivityIndicator() {
        myGuide.stopAnimating()
        myGuide.isHidden = true
    }
}
