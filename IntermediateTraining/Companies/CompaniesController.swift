//
//  ViewController.swift
//  IntermediateTraining
//
//  Created by Joffrey Fortin on 05/03/2018.
//  Copyright © 2018 myCode. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController {
    
    var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companies = CoreDataManager.shared.fetchCompanies()
        
        view.backgroundColor = UIColor.white        
        navigationItem.title = "Companies"
        tableView.backgroundColor = .darkBlue
        tableView.separatorColor = .white
        // The footer represents the rest of the table view. Remove lines from it
        tableView.tableFooterView = UIView() // blank UIView
        
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset)),
            UIBarButtonItem(title: "Do work", style: .plain, target: self, action: #selector(doWork))
        ]
        
        
        // registration of a cell class named "cellId"
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "cellId")
    }
    
    @objc private func handleReset() {
        print("Attempting to delete all core data obnects")
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do {
            try context.execute(batchDeleteRequest)
            
            var indexPathsToRemove = [IndexPath]()
            for (index, _) in companies.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
        } catch let delErr {
            print("Failed to delete objects for Core Data:", delErr)
        }
    }
    
    @objc func handleAddCompany() {
        let createCompanyController = CreateCompanyController()
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        createCompanyController.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func doWork() {
        print("Trying to do work...")
        // GCD - Grand Central Dispatch
        // to perform task in background
        DispatchQueue.global(qos: .background).async {
        }
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
            (0...20000).forEach { (value) in
                let company = Company(context: backgroundContext)
                print(value)
                company.name = String(value)
            }
            
            do {
                try backgroundContext.save()
            } catch let err {
                print("Failed to save:", err)
            }
        })
    }
    
}
