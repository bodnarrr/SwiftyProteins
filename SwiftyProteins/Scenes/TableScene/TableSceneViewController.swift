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
		model.copyAllToFiltered()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let cells = tableView.visibleCells as! [ProteinCell]
		for cell in cells {
			cell.activityIndicator.isHidden = true
			cell.activityIndicator.stopAnimating()
			cell.isSelected = false
		}
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
		
		let cell = tableView.cellForRow(at: indexPath) as! ProteinCell
		cell.activityIndicator.isHidden = false
		DispatchQueue.main.async {
			cell.activityIndicator.startAnimating()
		}

		let proteinName = model.filteredProteinList[indexPath.row]
		ApiManager.shared.getModelFromAPI(proteinName) { [weak self] (receivedData) in
			if let data = receivedData {
				self?.model.parseReceivedData(data)
				self?.performSegue(withIdentifier: "segueToProteinView", sender: self)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewController = segue.destination as? ProteinViewSceneController {
			viewController.model.protein = model.selectedProtein
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
