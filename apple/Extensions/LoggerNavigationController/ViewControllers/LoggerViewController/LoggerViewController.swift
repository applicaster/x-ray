//
//  LoggerViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class LoggerViewController: UIViewController {
    private let cellIdentifier = "LoggerCell"
    private let screenIdentifier = "LoggerScreen"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortLogsView: SortLogsView!
    @IBOutlet weak var resetFilterBarButtonItem: UIBarButtonItem!

    private(set) weak var inMemorySink: InMemory?

    // Original data source returned from sink
    var originalDataSource: [Event] = []

    // Filtered models by filter DataSortFilterModel
    var filteredDataSource: [Event] = []

    // Filtered models by filter DataSortFilterModel and log type buttons
    var filteredDataSourceByType: [Event] = []

    var filterModels: [DataSortFilterModel] = DataSortFilterHelper.dataFromUserDefaults()

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
        inMemorySink = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        initilizeSortData()
        collectionViewSetup()
        prepareLogger()
    }

//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.estimatedItemSize = CGSize(width: self.collectionView.frame.size.width, height: 200)
//            layout.invalidateLayout()
//        }
//
//    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.view.bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        self.view = view
    }

    func prepareLogger() {
        title = "Logger Screen"

        let inMemorySink = Xray.sharedInstance.getSink("InMemorySink") as? InMemory
        self.inMemorySink = inMemorySink
        if let events = inMemorySink?.events {
            originalDataSource = events
            filterDataSource()
//            collectionView.reloadData()
        }
    }

    func collectionViewSetup() {
        let bundle = Bundle(for: type(of: self))

        collectionView?.register(UINib(nibName: cellIdentifier,
                                       bundle: bundle),
                                 forCellWithReuseIdentifier: cellIdentifier)
    }

    func loadViewFromNib() -> UIView? {
        let nibName = "LoggerViewController"
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
            DataSortFilterHelper.saveDataToUserDefaults(dataToSave: filterModels)
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

extension LoggerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

extension LoggerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredDataSourceByType.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                      for: indexPath) as! LoggerCell
        let event = filteredDataSourceByType[indexPath.row]
        let formattedDate = dateStringFromEvent(event: event)
        cell.updateCell(event: event,
                        dateString: formattedDate)

        return cell
    }
}

extension LoggerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 120)
    }
}

extension LoggerViewController: SortLogsViewDelegate {
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

extension LoggerViewController: FilterViewControllerDelegate {
    func userDidSaveNewFilterData(filterModels: [DataSortFilterModel]) {
        applyNewFilters(newData: filterModels)
    }
}
