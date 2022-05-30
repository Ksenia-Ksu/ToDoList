

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: Constants.TextForAlerts.alertAddCategoryAction, message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.TextForAlerts.alertAddCategoryAction
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: Constants.TextForAlerts.addCategoryAction, style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategory()
        }
        
        let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.categoryCellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.segueFromCategoryToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.segueFromCategoryToItems {
            let destinationVC = segue.destination as! ToDoListViewController
            if let index = tableView.indexPathForSelectedRow?.row {
                destinationVC.selectedCategory = categories[index]
                
            }
        }
        
    }
    
    //MARK: - Saving and loading data methods
    
    func saveCategory() {
        
        do {
            try context.save()
        } catch  {
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch  {
            print("Error loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Swipe actions - delete and edit
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let category = categories[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.TextForSwipes.delete) { _, _, _ in
            
            self.context.delete(category)
            self.categories.remove(at: indexPath.row)
            self.saveCategory()
        }
        
        let editAction = UIContextualAction(style: .normal, title: Constants.TextForSwipes.edit) { _, _, _ in
            
            let alert = UIAlertController(title: Constants.TextForSwipes.editCategory, message: "", preferredStyle: .alert)
            
            var textField = UITextField()
            
            alert.addTextField { (alertTextField)  in
                textField = alertTextField
                textField.text = category.name
                
            }
            
            let updateAction = UIAlertAction(title: Constants.TextForAlerts.save, style: .default) { action in
                
                self.categories[indexPath.row].name = textField.text
                self.saveCategory()
                
            }
            
            let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }
    
}



