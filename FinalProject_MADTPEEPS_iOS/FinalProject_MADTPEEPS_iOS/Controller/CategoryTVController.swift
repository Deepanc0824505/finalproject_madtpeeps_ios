//
//  CategoryTVController.swift
//  FinalProject_MADTPEEPS_iOS
//
//  Created by MADT Peeps on 2022-01-27.
//
import Foundation
import CoreData
import UIKit

class CategoryTVController: UITableViewController {
    
    // create a categories array to populate the table
    var categories = [Category]()
    
    // create a context to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        loadCategories()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

   @IBAction func addCategoriesClick(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "Enter a Category Name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let categoryNames = self.categories.map {$0.catName?.lowercased()}
            guard !categoryNames.contains(textField.text?.lowercased()) else {self.showAlert(); return}
            let newCategory = Category(context: self.context)
            newCategory.catName = textField.text!
            self.categories.append(newCategory)
            self.saveCategory()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // change the color of the cancel button action
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "category name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    /// show alert when the name of the folder is taken
    func showAlert() {
        let alert = UIAlertController(title: "Category Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category_cell", for: indexPath)
        let catName = categories[indexPath.row].catName
        cell.textLabel?.text = catName
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .darkGray
        cell.detailTextLabel?.text = "\(categories[indexPath.row].tasks?.count ?? 0)"
       // cell.imageView?.image = UIImage(systemName: "folder")
        cell.selectionStyle = .none
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let folderPredicate = NSPredicate(format: "category.catName=%@", catName!)
        
        request.predicate = folderPredicate
        
        var tasks = [Task]()
        var taskCompleted = 0
        do {
            tasks = try context.fetch(request)
            for task in tasks {
                if task.isCompleted {
                    taskCompleted += 1
                }
            }
            if taskCompleted == tasks.count && tasks.count != 0 {
                cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
                cell.imageView?.tintColor = .green
            } else {
                cell.imageView?.image = UIImage(systemName: "folder")
                cell.imageView?.tintColor = .brown
            }
            
            
        } catch {
            print("Error loading tasks \(error.localizedDescription)")
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteCategory(category:  categories[indexPath.row])
            saveCategory()
            categories.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                let title = categories[indexPath.row].catName
                var textField = UITextField()
                let alert = UIAlertController(title: "Edit Category", message: "Enter a Category Name", preferredStyle: .alert)
                let addAction = UIAlertAction(title: "Update", style: .default) { (action) in
                    let categoryNames = self.categories.map {$0.catName?.lowercased()}
                    guard !categoryNames.contains(textField.text?.lowercased()) else {self.showAlert(); return}
                    self.categories[indexPath.row].catName = textField.text!
                    self.editCategory(category: self.categories[indexPath.row], title:title!)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                // change the color of the cancel button action
                cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
                
                alert.addAction(addAction)
                alert.addAction(cancelAction)
                alert.addTextField { (field) in
                    textField = field
                    textField.text = title
                }
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - core data interaction methods
    
    /// load categories  from core data
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    /// save Categories into core data
    func saveCategory() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the category \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(category: Category) {
        context.delete(category)
    }
    
    func editCategory(category: Category, title:String) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let folderPredicate = NSPredicate(format: "catName=%@", title)
        request.predicate = folderPredicate
        do {
            categories = try context.fetch(request)
            if(categories.count > 0){
                let category1 = categories[0]
                category1.catName = category.catName
            }
            saveCategory()
            loadCategories()
        } catch {
            print("Error loading tasks \(error.localizedDescription)")
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! TaskTVController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories[indexPath.row]
        }
    }


}
