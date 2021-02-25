//
//  LoggerViewBaseController.swift
//  Xray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

public class LoggerViewBaseController: UIViewController {
    private let cellIdentifier = "LoggerCell"
    private let screenIdentifier = "LoggerScreen"
    var className: String = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortLogsView: SortLogsView!
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
    var sortParams = SortLogsHelper.dataFromUserDefaults()
    var asynchronously: Bool {
        get {
            return false
        }
        set(newValue) {
        }
    }

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

    func collectionViewSetup() {
        let bundle = Bundle(for: type(of: self))

        collectionView?.register(UINib(nibName: cellIdentifier,
                                       bundle: bundle),
                                 forCellWithReuseIdentifier: cellIdentifier)
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
        return filteredDataSource.filter { (event) -> Bool in
            if let selected = sortParams[event.level.rawValue] {
                return selected
            }
            return false
        }
    }
}

extension LoggerViewBaseController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedLoggerViewController(nibName: "DetailedLoggerViewController",
                                                                  bundle: bundle)
        let event = filteredDataSourceByType[indexPath.row]
        detailedViewController.event = event
        detailedViewController.dateString = dateStringFromEvent(event: event)
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
    }
}

extension LoggerViewBaseController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredDataSourceByType.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                      for: indexPath) as! LoggerCell
        let event = filteredDataSourceByType[indexPath.row]
        let formattedDate = dateStringFromEvent(event: event)
        cell.updateCell(event: event,
                        dateString: formattedDate)

        return cell
    }
}

extension LoggerViewBaseController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 120)
    }
}

extension LoggerViewBaseController: SortLogsViewDelegate {
    func userPushButon(logType: LogLevel, selected: Bool) {
        sortParams[logType.rawValue] = selected
        SortLogsHelper.saveDataToUserDefaults(dataToSave: sortParams)
        reloadCollectionViewWithFilters()
    }

    func reloadCollectionViewWithFilters() {
        let newFilteredDataSource = filterDataSourceByType()
        if filteredDataSourceByType != newFilteredDataSource {
            filteredDataSourceByType = newFilteredDataSource
            collectionView.reloadData()
            if self.filteredDataSourceByType.count > 0 {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                 at: .top,
                                                 animated: false)
            }
        }
    }

    func initilizeSortData() {
        sortLogsView.delegate = self
        sortLogsView.initializeButtons(defaultStates: sortParams)
    }
}

extension LoggerViewBaseController: FilterViewControllerDelegate {
    func userDidSaveNewFilterData(filterModels: [DataSortFilterModel]) {
        applyNewFilters(newData: filterModels)
    }
}
