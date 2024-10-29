//
//  ViewController.swift
//  RickAndMortyCoreData
//
//  Created by Ибрагим Габибли on 24.10.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        return tableView
    }()

    var characters = [Entity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        getCharacters()
    }

    private func setupNavigationBar() {
        title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CharacterTableViewCell.self,
                           forCellReuseIdentifier: CharacterTableViewCell.id)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func getCharacters() {
        self.characters = CoreDataManager.shared.fetchCharacters()

        guard self.characters.isEmpty else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }

        NetworkManager.shared.getCharacters { [weak self] result, error in
            if let error {
                print("Error getting characters: \(error)")
                return
            }

            guard let result else {
                return
            }

            var charactersToSave: [(character: Character, imageData: Data)] = []

            result.forEach { res in
                guard let url = URL(string: res.image) else {
                    print("Invalid URL for character image")
                    return
                }

                do {
                    let imageData = try Data(contentsOf: url)
                    charactersToSave.append((character: res, imageData: imageData))
                } catch {
                    print("Failed to load image data: \(error)")
                }
            }

            CoreDataManager.shared.saveCharacters(charactersToSave)

            DispatchQueue.main.async {
                self?.characters = CoreDataManager.shared.fetchCharacters()
                self?.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CharacterTableViewCell.id,
            for: indexPath) as? CharacterTableViewCell else {
            return UITableViewCell()
        }

        let character = characters[indexPath.row]

        guard let imageData = CoreDataManager.shared.fetchImageData(forCharacterId: character.id),
              let image = UIImage(data: imageData) else {
            return cell
        }

        cell.configure(with: character, image: image)

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        128
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
