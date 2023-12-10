
import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableview.delegate=self
        self.tableview.dataSource=self
        self.tableview.rowHeight = 100.0
    }

}


extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddLocationController.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = AddLocationController.items[indexPath.row].name
        
        print(AddLocationController.items[indexPath.row].name)
        
        cell.detailTextLabel?.text = "\(AddLocationController.items[indexPath.row].temp) C"
        cell.imageView?.contentMode = .scaleToFill
        DispatchQueue.main.async{
            cell.imageView?.sd_setImage(with: URL(string: AddLocationController.items[indexPath.row].icon), placeholderImage: UIImage(named: "placeholder.png"))
        }
        return cell 
    }
}


