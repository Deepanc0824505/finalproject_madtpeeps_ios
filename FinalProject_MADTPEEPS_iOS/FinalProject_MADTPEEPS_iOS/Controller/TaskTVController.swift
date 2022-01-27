//
//  TaskTVController.swift
//  FinalProject_MADTPEEPS_iOS
//
//  Created by MADT Peeps on 2022-01-27.
//

import UIKit
import CoreData

class TaskTVController: UITableViewController {
    var tasks = [Task]()
    var sortByDate = false
    var sortByName = false
    var predicate:NSPredicate? = nil
    var selectedCategory : Category? {
        didSet {
            loadTasks()
        }
    }
    
    var delete: Bool = false
    
    // create the context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "task_cell")

        navigationItem.title = selectedCategory?.catName
    }
    
    //MARK : - TableView Reload Data After Add Tasks
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tasks.removeAll()
        self.tableView.reloadData()
        sortByDate = true
        sortByName = true
        loadTasks()
    }
    
    @IBAction func buttonSortByDate(_ sender: UIBarButtonItem) {
        sortByDate = true
        sortByName = false
        loadTasks()
    }
    
    @IBAction func buttonAtoZ(_ sender: UIBarButtonItem) {
        sortByDate = false
        sortByName = true
        loadTasks()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "task_cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "task_cell")


        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.taskTitle
        cell.textLabel?.textColor = .black
        
        cell.detailTextLabel?.text = task.taskStartDate
        cell.detailTextLabel?.textColor = .darkGray
        //print(note.noteCurrentDate)
        
        if(task.isCompleted){
            cell.detailTextLabel?.text = "Completed"
            cell.detailTextLabel?.textColor = .green

        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(task: tasks[indexPath.row])
            saveTasks()
            tasks.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /// delete tasks from context
    /// - Parameter note: note defined in Core Data
    func deleteTask(task: Task) {
        context.delete(task)
        
    }

    
    /// Save tasks into core data
    func saveTasks() {
        do {
            try context.save()
        } catch {
            print("Error saving the tasks \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Core data interaction functions
    
    /// load tasks deom core data
    /// - Parameter predicate: parameter comming from search bar - by default is nil
    private func loadTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let folderPredicate = NSPredicate(format: "category.catName=%@", selectedCategory!.catName!)
        
        if(sortByName){
            request.sortDescriptors = [NSSortDescriptor(key: "taskTitle", ascending: true)]
        }
        if(sortByDate){
            request.sortDescriptors = [NSSortDescriptor(key: "taskStartDate", ascending: true)]
        }
     
     
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
    
        do {
            tasks = try context.fetch(request)
            
        } catch {
            print("Error loading tasks \(error.localizedDescription)")
        }
        
        tableView.reloadData()
        predicate = nil
    }
}
