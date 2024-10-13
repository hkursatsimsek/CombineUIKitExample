//
//  ViewController.swift
//  CombineUIKitExample
//
//  Created by Kürşat Şimşek on 12.10.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {
    // MARK: Properties
    private var tableView = UITableView()
    private var posts:[Post] = []
    private var cancellables = Set<AnyCancellable>()
    private var searchTextPublisher = PassthroughSubject<String, Never>()

    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Search Posts"
        
        return view
    }()
    
    private lazy var fetchButton: UIButton = {
        let view = UIButton(configuration: .filled())
        
        view.configuration?.baseBackgroundColor = .systemBlue
        view.configuration?.baseForegroundColor = .white
        view.configuration?.cornerStyle = .medium
        view.setTitle("Get Posts From API", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addAction(.init(handler: { _ in
            self.fetchButtonTapped()
        }), for: .touchUpInside)
        
        return view
    }()
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Arama metni her değiştiğinde Combine üzerinden veriyi işliyoruz
        searchTextPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 500ms bekleyerek API isteğini geciktiriyoruz
            .removeDuplicates() // Aynı arama metni tekrar edilirse istek yapmıyoruz
            .sink(receiveValue: { [weak self] searchTerm in
                self?.searchPosts(query: searchTerm)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        view.addSubview(fetchButton)
        NSLayoutConstraint.activate([
            fetchButton.heightAnchor.constraint(equalToConstant: 50),
            fetchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            fetchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            fetchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        view.addSubview(searchBar)
        searchBar.delegate = self
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
        ])
    }
    
    private func fetchPosts() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data } // Gelen veriyi alıyoruz
            .decode(type: [Post].self, decoder: JSONDecoder()) // JSON'dan Post tipine çeviriyoruz
            .receive(on: DispatchQueue.main) // Sonucu ana thread'e yönlendiriyoruz ki UI güncellenebilsin
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Veri başarıyla alındı.")
                case .failure(let error):
                    print("Hata oluştu: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] posts in
                self?.posts = posts
                self?.tableView.reloadData()
            })
            .store(in: &cancellables) // Aboneliği saklıyoruz, iptal edilebilir hale getiriyoruz
    }
    
    @objc private func fetchButtonTapped() {
        fetchPosts()
    }
    
    private func searchPosts(query: String) {
        guard !query.isEmpty else { return }
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?title_like=\(query)")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Arama tamamlandı.")
                case .failure(let error):
                    print("Hata oluştu: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] posts in
                self?.posts = posts
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
    }
}

// MARK: UITableView Delegate & Datasource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell {
            let post = posts[indexPath.row]
            cell.configure(with: post)
            
            return cell
        } else {
            fatalError()
        }
    }
}

// MARK: - Post Model
struct Post: Codable {
    let id: Int
    let title: String
    let body: String
}

//MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextPublisher.send(searchText) // Her metin değişikliğinde Combine Publisher'ı tetikliyoruz
    }
}
