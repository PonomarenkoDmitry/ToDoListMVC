//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Дмитрий Пономаренко on 10.10.22.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var listItem = [List]()

    var selectedCategory: Category? {
        didSet {
            loadItems ()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let item = listItem[indexPath.row]
        
        cell.textLabel?.text = item.tittle
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Table view delegate 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listItem[indexPath.row].done = !listItem[indexPath.row].done
        
        saveItem()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(listItem[indexPath.row])
            listItem.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveItem()
            tableView.reloadData()
        }
    }
        
    //MARK: - Data manipulation method
    
    func loadItems(with request: NSFetchRequest<List> = List.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            listItem = try context.fetch(request)
        } catch {
            print("Error loading list \(error)")
        }
        tableView.reloadData()
    }
    
    func saveItem() {
        
        do {
            try context.save()
        } catch {
            print("Error saving item \(error) ")
        }
        
             tableView.reloadData()
        
    }
    //MARK: - Add new item
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        var textFieldItem = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
       
            let newItem = List(context: self.context)
            newItem.tittle = textFieldItem.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.listItem.append(newItem)
            print(self.listItem.count)
            self.saveItem()
            
        }
        
        alert.addTextField { field in
            textFieldItem = field
            textFieldItem.placeholder = "Add new item"
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}
