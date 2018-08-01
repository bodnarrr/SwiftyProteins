//
//  TableSceneViewController.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/28/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import UIKit

class TableSceneViewController: UIViewController {

    let model = TableSceneVewModel()

    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        getProteinsList()
    }

    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    private func getProteinsList() {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            if let fileContent = try? String(contentsOfFile: path) {
                fileContent.enumerateLines(invoking: { [weak self] (line, _) in
                    self?.model.proteinsList.append(line)
                })
            }
        } else {
            assert(true, "File Not Found. WTF?")
        }
    }
	
}

// MARK: - TableView delegate functions
extension TableSceneViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return model.proteinsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProteinCell", for: indexPath) as! ProteinCell
        cell.proteinNameLabel.text = model.proteinsList[indexPath.row]
        cell.activityIndicator.isHidden = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProteinCell", for: indexPath) as! ProteinCell
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        sleep(1)
        let proteinName = model.proteinsList[indexPath.row]
        ApiManager.shared.getModelFromAPI(proteinName) { [weak self] (receivedData) in
            if let data = receivedData {
                self?.model.parseReceivedData(data)
//                self?.performSegue(withIdentifier: "segueToProteinView", sender: self)
                self?.performSegue(withIdentifier: "segueToProteinARView", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ProteinViewSceneController {
            viewController.model.proteins = model.selectedProtein
        } else if let viewController = segue.destination as? ProteinARViewController {
            viewController.model.proteins = model.selectedProtein
        }
    }
}

// MARK: - SearchBar delegate functions
extension TableSceneViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
