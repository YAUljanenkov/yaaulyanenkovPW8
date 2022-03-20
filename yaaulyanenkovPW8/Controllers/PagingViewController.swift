//
//  PagingViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 20.03.2022.
//

import UIKit

class PagingViewController: UIViewController, UITableViewDelegate {

    internal let tableView = UITableView()
    internal let apiKey = "2791350a2e73deb10f1b5d47997132f0"
    internal var segmentedControl: UISegmentedControl?
    internal var session: URLSessionDataTask?
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
        configurePagingButtons()
        loadMovies()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Paging movies"
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
        var components = URLComponents(string: "https://api.themoviedb.org/3/discover/movie")
        var index = segmentedControl?.selectedSegmentIndex ?? 0
        if index < 0 {
            index = 0
        }
        components?.queryItems = [
            URLQueryItem(name:"api_key", value: apiKey),
            URLQueryItem(name:"language", value: "ru-ru"),
            URLQueryItem(name:"language", value: "ru-ru"),
            URLQueryItem(name:"page", value: segmentedControl?.titleForSegment(at: index) ?? "1"),
        ]
        guard let url = components?.url else {
            return
        }
        
        self.session?.cancel()
        session = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
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
            self.movies = movies
            self.loadImagesForMovies(movies) { movies in
                self.movies = movies
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
    
    func configurePagingButtons() {
        segmentedControl = UISegmentedControl(items: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
        segmentedControl?.backgroundColor = .white
        guard let segmentedControl = segmentedControl else {
            return
        }

        view.addSubview(segmentedControl)
        segmentedControl.pin(to: view, [.left, .right], 10)
        segmentedControl.pin(to: view, [.bottom], 30)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.loadMovies()
    }
}


extension PagingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}
