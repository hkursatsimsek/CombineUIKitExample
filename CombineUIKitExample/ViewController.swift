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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
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
