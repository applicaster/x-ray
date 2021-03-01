//
//  LoggerViewControllerBase.swift
//  Xray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

public enum LoggerViewType {
    case undefined
    case logger
    case networkRequests
}

public class LoggerViewControllerBase: UIViewController {
    private let screenIdentifier = "LoggerScreen"
    var className: String = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetFilterBarButtonItem: UIBarButtonItem!

    public weak var activeSink: BaseSink?

    // Original data source returned from sink
    var originalDataSource: [Event] = []

    // Filtered models by filter DataSortFilterModel
    var filteredDataSource: [Event] = []

    // Filtered models by filter DataSortFilterModel and log type buttons
    var filteredDataSourceByType: [Event] = []

    var filterModels: [DataSortFilterModel] = []

    var formatter: EventFormatterProtocol?
    var asynchronously: Bool {
        get {
            return false
        }
        set(newValue) {
        }
    }
    
    var sortParams: [Int: Bool] = [:]
    var loggerType: LoggerViewType = .undefined
    
    let dateFormatter = DateFormatter()
    public var format = "yyyy-MM-dd HH:mm:ssZ"

    deinit {
        activeSink = nil
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        className = "\(type(of: self))"
        
        xibSetup()
        filtersSetup()
        initilizeSortData()
        collectionViewSetup()
        prepareLogger()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func filtersSetup() {
        filterModels = DataSortFilterHelper.dataFromUserDefaults(source: className)
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.view.bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        self.view = view
    }

    func prepareLogger() {
        //override in child classes
    }
    
    func getSortParams() -> [Int: Bool] {
        //override in child classes
        return [:]
    }
    
    func getCellIdentifier() -> String {
        //override in child classes
        return "undefined"
    }
    
    func initilizeSortData() {
        //override in child classes
        sortParams = getSortParams()
    }

    func collectionViewSetup() {
        let bundle = Bundle(for: type(of: self))

        collectionView?.register(UINib(nibName: getCellIdentifier(),
                                       bundle: bundle),
                                 forCellWithReuseIdentifier: getCellIdentifier())
    }

    //override in child classes
    func loadViewFromNib() -> UIView? {
        let nibName = className
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }

    func dateStringFromEvent(event: Event) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(event.timestamp))
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    @IBAction func exportData(_ sender: UIBarButtonItem) {
        Reporter.requestSendEmail()
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        let presenter = UIApplication.shared.keyWindow?.rootViewController
        presenter?.presentedViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func presentFilterViewController(_ sender: UIBarButtonItem) {
        let filterViewController = FilterViewController(nibName: "FilterViewController",
                                                        bundle: Bundle(for: type(of: self)))
        filterViewController.filterModels = filterModels
        filterViewController.delegate = self
        navigationController?.pushViewController(filterViewController,
                                                 animated: true)
    }

    @IBAction func resetFilter(_ sender: UIBarButtonItem) {
        applyNewFilters(newData: [])
    }

    func applyNewFilters(newData: [DataSortFilterModel]) {
        if filterModels != newData {
            filterModels = newData
            DataSortFilterHelper.saveDataToUserDefaults(source: className, dataToSave: filterModels)
            filterDataSource()
            collectionView.reloadData()
            if self.filteredDataSourceByType.count > 0 {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                 at: .top,
                                                 animated: false)
            }
        }
    }

    func filterDataSource() {
        resetFilterBarButtonItem.isEnabled = filterModels.count > 0
        filteredDataSource = DataSortFilterHelper.filterDataSource(filterData: filterModels,
                                                                   allEvents: originalDataSource)
        filteredDataSourceByType = filterDataSourceByType()
    }

    func filterDataSourceByType() -> [Event] {
        //override in child classes
        return []
    }
}

extension LoggerViewControllerBase: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedLoggerViewController(nibName: "DetailedLoggerViewController",
                                                                  bundle: bundle)
        let event = filteredDataSourceByType[indexPath.row]
        detailedViewController.event = event
        detailedViewController.loggerType = loggerType
        detailedViewController.dateString = dateStringFromEvent(event: event)
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
    }
}

extension LoggerViewControllerBase: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredDataSourceByType.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: getCellIdentifier(),
                                                      for: indexPath) as? LoggerCellProtocol
        let event = filteredDataSourceByType[indexPath.row]
        let formattedDate = dateStringFromEvent(event: event)
        cell?.updateCell(event: event,
                        dateString: formattedDate)

        return cell as! UICollectionViewCell
    }
}

extension LoggerViewControllerBase: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 120)
    }
}

extension LoggerViewControllerBase: FilterViewControllerDelegate {
    func userDidSaveNewFilterData(filterModels: [DataSortFilterModel]) {
        applyNewFilters(newData: filterModels)
    }
}
