//
//  BlockListVC.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import UIKit

class BlockListVC: UIViewController {
    
    //MARK: - View
    let loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.style = .large
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    //MARK: - Variables
    var dataSource: [BlackListItem]?
    
    //MARK: - VC cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        configureUI()
        
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "BlockListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "BlockListItemTableViewCell")
        
        DispatchQueue.main.async {
            self.featchList()
        }
    }
    
    func featchList() {
            self.loaderView.isHidden = false
             Networking.shared.fetchBlackListItems(completion: { items, erro in
                if let safeItems = items {
                    self.dataSource = safeItems
                    self.reload()
                } else {
                    DispatchQueue.main.async {
                    self.showError()
                    }
                }
                 DispatchQueue.main.async {
                
                     self.loaderView.isHidden = true
                 }
                
            })
    }
    
    func reload() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func showError() {
        let alert = UIAlertController(title: "Networking error.", message: "Featching blacklist error.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.featchList()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func configureUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .plain, target: self, action: #selector(addTapped))
        
        // Setup tableView
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Setup tableView
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Setup tableView
        loaderView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor)
        ])
    }
    
    @objc func addTapped() {
        let alert = UIAlertController(title: "Додати елемент", message: "Введіть назву компоненту", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Додати", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let text = alert.textFields![0].text ?? ""
            Networking.shared.addBlackListItem(with: text) { [weak self] ok, error in
                guard let self = self else { return }
                if let ok = ok {
                    self.featchList()
                } else {
                    print("Look at blackLists-adding")
                }
            }
            self.featchList()
        }))
        present(alert, animated: true)
    }
}


extension BlockListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let _ = dataSource else { return }
            let test = self.dataSource!.remove(at: indexPath.row)
            tableView.reloadData()
            
            Networking.shared.removeBlackListItem(by: String(indexPath.row)) { [weak self] ok, error in
                guard let self = self else { return }
                if let ok = ok {
                    self.featchList()
                } else {
                    print("Look at blackLists-removing")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListItemTableViewCell", for: indexPath) as! BlockListItemTableViewCell
        cell.configure(with: dataSource[indexPath.row].name)
        return cell
    }
}
