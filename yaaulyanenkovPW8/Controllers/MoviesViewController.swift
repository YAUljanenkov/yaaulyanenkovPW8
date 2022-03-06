//
//  ViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 06.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }
    
    
    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pin(to: view)
        tableView.reloadData()
    }
}


extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MovieView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
