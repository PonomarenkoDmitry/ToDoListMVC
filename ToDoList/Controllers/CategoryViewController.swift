//
//  ViewController.swift
//  ToDoList
//
//  Created by Дмитрий Пономаренко on 10.10.22.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    @IBOutlet var categoryTableView: UITableView!
    
    var categoryList = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadCategories()
        // Do any additional setup after loading the view.
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToListVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryList[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categoryList[indexPath.row])
            categoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            save()
            tableView.reloadData()
        }
    }
    
    //MARK: - Data manipulation 
    
    func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryList = try context.fetch(request)
        } catch {
            print("Error loading category \(error)")
        }
        tableView.reloadData()
    }
    
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Add new category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            self.categoryList.append(newCategory)
            self.save()
        }
        alert.addAction(action)
        
        alert.addTextField { field in
           textField = field
           textField.placeholder = "Add New Category"
        }
        
        present(alert, animated: true)
        
    }
}
