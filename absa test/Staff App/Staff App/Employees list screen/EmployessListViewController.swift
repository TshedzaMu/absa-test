//  EmployessListViewController.swift
//  Staff App
//
//  Created by Tshedza Musandiwa on 2024/05/23.
//

import UIKit

class EmployessListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet private var employeesListTableView: UITableView!
    @IBOutlet private weak var employeeSearchBar: UISearchBar!
    
    private lazy var viewModel = EmployessListViewModel()
    weak var delegate: EmployeeSelectionDelegate?
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No employees found"
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupNoResultsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onEmployeesFetched = { [weak self] in
            self?.stopActivityIndicator()
            self?.updateNoResultsLabelVisibility()
            self?.employeesListTableView.reloadData()
        }
        
        viewModel.onFetchFailed = { [weak self] errorMessage in
            self?.stopActivityIndicator()
            self?.showErrorAlert(message: errorMessage)
        }
        
        startActivityIndicator()
        viewModel.getEmployeeList()
    }
    
    private func setupSearchBar() {
        employeeSearchBar.delegate = self
    }
    
    private func setupNoResultsLabel() {
        view.addSubview(noResultsLabel)
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateNoResultsLabelVisibility() {
        noResultsLabel.isHidden = viewModel.employeeListNumber > 0
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.employeeListNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PROFILE_CELL", for: indexPath) as! ProfileViewTableViewCell
        guard let view = EmployeeView.loadView() else { return UITableViewCell() }
        if let employeeInfo = viewModel.employeeList?[indexPath.row],
           let firstName = employeeInfo.first_name,
           let lastName = employeeInfo.last_name {
            
            view.setupView(name: "\(firstName) \(lastName)",
                           email: employeeInfo.email ?? "",
                           urlString: employeeInfo.avatar ?? "")
        }
        cell.contentView.addSubview(view)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let employeeInfo = viewModel.employeeList?[indexPath.row] {
            delegate?.didSelectEmployee(employeeInfo)
            dismiss(animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterEmployeeList(with: searchText)
        updateNoResultsLabelVisibility()
        employeesListTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterEmployeeList(with: "")
        searchBar.resignFirstResponder()
        updateNoResultsLabelVisibility()
        employeesListTableView.reloadData()
    }
}
