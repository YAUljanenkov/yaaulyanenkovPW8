//
//  ViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 06.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    private let tableView = UITableView()
    private let apiKey = "2791350a2e73deb10f1b5d47997132f0"
    private var movies:[Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies()
        }
    }
    
    
    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pin(to: view)
        tableView.reloadData()
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ruRu") else {
            return
        }
        
        let session = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any],
                  let results = dict["results"] as? [[String: Any]]
            else {
                return
            }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as? String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title, posterPath: imagePath, poster: nil)
            }
            print(movies)
        }
        
        session.resume()
    }
}


extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MovieView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}
