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
    var proteinViewControllerModel: ProteinViewSceneModel?

	@IBOutlet weak var tabBar: UITabBar!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        getProteinsList()
        model.copyAllToFiltered()
		if let items = tabBar.items {
			tabBar.selectedItem = items[0]
		}
		self.title = "Proteins"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cells = tableView.visibleCells as! [ProteinCell]
        for cell in cells {
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.isSelected = false
        }
		tableView.allowsSelection = true
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

        return model.filteredProteinList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProteinCell", for: indexPath) as! ProteinCell
        cell.proteinNameLabel.text = model.filteredProteinList[indexPath.row]
        cell.activityIndicator.isHidden = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.allowsSelection = false
        let cell = tableView.cellForRow(at: indexPath) as! ProteinCell
        cell.activityIndicator.isHidden = false
		cell.activityIndicator.startAnimating()
        let proteinName = model.filteredProteinList[indexPath.row]
        ApiManager.shared.getModelFromAPI(proteinName) { [weak self] (receivedData) in
            if let data = receivedData {
                DispatchQueue.global(qos: .background).async {
                    self?.proteinViewControllerModel = ProteinViewSceneModel(data: data)
                    DispatchQueue.main.async { [weak self] in
						guard let items = self?.tabBar.items else { return }
						if self?.tabBar.selectedItem == items[0] {
							self?.performSegue(withIdentifier: "segueToProteinView", sender: self)
                        } else {
                            self?.performSegue(withIdentifier: "segueToProteinARView", sender: self)
                        }
                    }
                }
			} else {
				let alert = UIAlertController(title: "No internet connection!", message: "Check your connection and try again", preferredStyle: .alert)
				let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
					cell.activityIndicator.isHidden = true
					cell.activityIndicator.stopAnimating()
					cell.isSelected = false
					self?.tableView.allowsSelection = true
				})
				alert.addAction(alertAction)
				self?.present(alert, animated: true)
				
			}
        }
    }
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ProteinViewSceneController {
            viewController.model = proteinViewControllerModel
        } else if let viewController = segue.destination as? ProteinARViewController {
            viewController.model = proteinViewControllerModel
        }
    }
}

// MARK: - SearchBar delegate functions
extension TableSceneViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            model.copyAllToFiltered()
            tableView.reloadData()
            return
        }
        model.filterProteins(searchText)
        tableView.reloadData()
    }
}
