//
//  JoViewController.swift
//  JoGallery
//
//  Created by django on 3/2/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import JoRefresh

class JoViewController: UIViewController {
    
    let tableView: UITableView = UITableView()
    
    var number: Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc func loadData() {
        print(#function)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.number = 3
            self.tableView.reloadData()
            self.tableView.joRefresh.endRefreshing()
        }
    }
    
    @objc func moreDate() {
        print(#function)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.number += Int(arc4random() % 5) + 3
            self.tableView.reloadData()
            self.tableView.joRefresh.endRefreshing()
        }
    }
}

// MARK: UITableViewProtocol

extension JoViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return number;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))!
        cell.textLabel?.text = "\(indexPath)"
        return cell
    }
}

// MARK: Setup

extension JoViewController {
    
    fileprivate func setup() {
        setupVariable()
        setupUI()
        prepareLaunch()
    }
    
    private func setupVariable() {
        
    }
    
    private func prepareLaunch() {
        
    }
    
    private func setupUI() {
        title = "JoRefresh"
        view.backgroundColor = .white
        
        setupTableView()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        tableView.frame = view.bounds
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset.top = 100
//        tableView.contentInset.bottom = 20
        tableView.joRefresh.header = JoRefreshHeaderControl()
        tableView.joRefresh.footer = JoRefreshFooterControl()
        tableView.joRefresh.tailer = JoRefreshTailerControl()
        tableView.joRefresh.footerActiveMode = .toBottom
        tableView.joRefresh.header?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.joRefresh.footer?.addTarget(self, action: #selector(moreDate), for: .valueChanged)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        view.addSubview(tableView)
    }
}

