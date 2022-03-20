//
//  PaginationViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 20.03.2022.
//


import UIKit

class PaginationViewController: UIViewController, UITableViewDelegate {
    
    internal let tableView = UITableView()
    internal let apiKey = "2791350a2e73deb10f1b5d47997132f0"
    internal var session: URLSessionDataTask?
    internal var pageCount = 1 {
        didSet {
            print("called did set")
            self.loadMovies()
        }
    }
    internal var movies:[Movie] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        loadMovies()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Pagination"
        tabBarController?.navigationItem.searchController = nil
    }
    
    internal func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pin(to: view)
        tableView.reloadData()
    }
    
    internal func loadMovies() {
        var components = URLComponents(string: "https://api.themoviedb.org/3/discover/movie")
        components?.queryItems = [
            URLQueryItem(name:"api_key", value: apiKey),
            URLQueryItem(name:"language", value: "ru-ru"),
            URLQueryItem(name:"language", value: "ru-ru"),
            URLQueryItem(name:"page", value:  "\(pageCount)"),
        ]
        guard let url = components?.url else {
            return
        }
        
        self.session?.cancel()
        session = URLSession.shared.dataTask(with: URLRequest(url: url)) {[weak self] data, _, _ in
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any],
                  let results = dict["results"] as? [[String: Any]]
            else {
                return
            }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as? String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title ?? "", posterPath: imagePath)
            }
            self?.movies.append(contentsOf: movies)
            self?.loadImagesForMovies(self?.movies ?? movies) { movies in
                self?.movies = movies
            }
        }
        
        self.session?.resume()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 2 == movies.count {
            pageCount += 1
        }
    }
}


extension PaginationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}

