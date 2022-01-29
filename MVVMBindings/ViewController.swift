//
//  ViewController.swift
//  MVVMBindings
//
//  Created by Ashwin  on 29/01/22.
//

import UIKit

//Observable
class Observable<T> {
    var value: T? {
        didSet {
            listeners.forEach {
                $0(value)
            }
        }
    }
    
    
    init(_ value: T?) {
        self.value = value
    }
    
    private var listeners: [((T?) -> Void)] = []
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listeners.append(listener)
    }
}

//Model

struct User: Codable {
    let name: String
}
//ViewModels
 
struct UserListViewModel {
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel {
    
    let name: String
}

//Controller

class ViewController: UIViewController, UITableViewDataSource {
    
    private var viewModel: UserListViewModel = UserListViewModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        viewModel.users.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        fetch()
    }

    func fetch() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let data = data else { return }
            do{
                let userModels = try JSONDecoder().decode([User].self, from: data)
                
                self.viewModel.users.value = userModels.compactMap({
                    
                    UserTableViewCellViewModel(name: $0.name)
                })
            }
            catch {
                
            }
        }
        task.resume()
    }

}

