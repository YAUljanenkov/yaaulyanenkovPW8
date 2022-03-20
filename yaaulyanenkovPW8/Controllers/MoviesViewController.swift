//
//  ViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 06.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    internal let tableView = UITableView()
    internal let apiKey = "2791350a2e73deb10f1b5d47997132f0"
    internal var movies:[Movie] = [] {
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
        
        if type(of: self) == MoviesViewController.self {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.loadMovies()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Movies list"
        tabBarController?.navigationItem.searchController = nil
    }
    
    internal func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pin(to: view)
        tableView.reloadData()
    }
    
    internal func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ruRu") else {
            return assertionFailure("Some problem with url")
        }
        
        let session = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any],
                  let results = dict["results"] as? [[String: Any]]
            else {
                return assertionFailure("Some problem with mapping")
            }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as? String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title ?? "", posterPath: imagePath)
            }
            self.movies = movies
            self.loadImagesForMovies(movies) { movies in
                self.movies = movies
            }
        }
        
        session.resume()
    }
    
    func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        for movie in movies {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                movie.loadPoster { _ in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(movies)
        }
    }
}


extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}
