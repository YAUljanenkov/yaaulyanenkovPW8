//
//  SearchViewController.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 07.03.2022.
//

import UIKit

class SearchViewController: MoviesViewController {
    
    let search = UISearchController()
    var session: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Введите название фильма"
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.title = "Search"
        tabBarController?.navigationItem.searchController = search
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = search.searchBar.text, !text.isEmpty else {
            return
        }
        self.loadMovies(query: text)
    }
    
    internal func loadMovies(query: String) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/search/movie")
        components?.queryItems = [
            URLQueryItem(name:"api_key", value: apiKey),
            URLQueryItem(name:"query", value: query),
            URLQueryItem(name:"language", value: "ru-ru"),
        ]
        guard let url = components?.url else {
            return
        }
        print(url)
        session?.cancel()
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
        
        session?.resume()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.search.searchBar.endEditing(true)
    }
}

