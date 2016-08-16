//
//  FiltersViewController.swift
//  Yelp
//
//  Created by tianhe_wang on 8/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

enum FilterSectionIdentifier : String {
    case Deal = "Deal"
    case SortBy = "Sort By"
    case Distance = "Distance"
    case Category = "Category"
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {


    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?

    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()

    let sections: [FilterSectionIdentifier] = [.Deal, .SortBy, .Distance, .Category]
    let distanceOptions = [0.3, 1, 5, 20]
    let sortOptions:[String] = ["Best Match", "Distance", "Rating"]
    let distanceOptionsText = ["0.3 mi", "1 mi", "5 mi", "20 mi"]
//    let cellIdentifierForFilter: [FilterSectionIdentifier : String] = [.Deal : "SwitchCell", .SortBy : "RadioCell", .Distance : "RadioCell", .Category : "SwitchCell"]

    let numberOfCategoriesWithoutExpansion = 3

    // states
    var expanded: [FilterSectionIdentifier : Bool] = [.Deal : false, .SortBy : false, .Distance : false, .Category : false]
    var dealsFilterOn: Bool = false
    var categoryStates = [Int:Bool]()
    // why not var sortMode: String = sortOptions[0]
    var selectedSortIndex: YelpSortMode? = .BestMatched
    var selectedDistanceIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        categories = yelpCategories()
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        filters["deal"] = dealsFilterOn
        filters["sortMode"] = selectedSortIndex?.rawValue
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRowsInSection = 0
        let filter = sections[section]
        switch filter {
        case .Deal:
            numOfRowsInSection = 1
        case .SortBy:
            numOfRowsInSection = expanded[filter] == true ? sortOptions.count : 1
        case .Distance:
            numOfRowsInSection = expanded[filter] == true ? distanceOptions.count : 1
        case .Category:
            numOfRowsInSection = expanded[filter] == true ? categories.count + 1: numberOfCategoriesWithoutExpansion + 1
        }
        return numOfRowsInSection
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case FilterSectionIdentifier.Deal:
            return getDealCell(indexPath)
        case FilterSectionIdentifier.SortBy:
            return getSortByCell(indexPath)
        case FilterSectionIdentifier.Distance:
            return getDistanceCell(indexPath)
        case FilterSectionIdentifier.Category:
            return getCategoryCell(indexPath)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].rawValue
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]
        if section == FilterSectionIdentifier.SortBy {
            if expanded[FilterSectionIdentifier.SortBy] == true {
                selectedSortIndex = YelpSortMode(rawValue: indexPath.row)
            }
            expanded[FilterSectionIdentifier.SortBy] = !expanded[FilterSectionIdentifier.SortBy]!
        } else if section == FilterSectionIdentifier.Distance {
            if expanded[FilterSectionIdentifier.Distance] == true {
                selectedDistanceIndex = indexPath.row
            }
            expanded[FilterSectionIdentifier.Distance] = !expanded[FilterSectionIdentifier.Distance]!
        }
        else if section == FilterSectionIdentifier.Category {
            // why has to be != true, instead of !
            if expanded[FilterSectionIdentifier.Category] != true && (indexPath.row == numberOfCategoriesWithoutExpansion) {
                expanded[FilterSectionIdentifier.Category] = true
            } else if expanded[FilterSectionIdentifier.Category] == true && (indexPath.row == categories.count) {
                expanded[FilterSectionIdentifier.Category] = false
            }
        }
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
    }

    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        let section = sections[indexPath.section]
        if section == FilterSectionIdentifier.Category {
            categoryStates[indexPath.row] = value
        } else if section == FilterSectionIdentifier.Deal {
            dealsFilterOn = value
        }
    }



    private func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"]
        ]
    }

    private func getDealCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        cell.delegate = self
        cell.onSwitch.on = dealsFilterOn
        cell.switchLabel.text = "Offering a Deal"
        return cell
    }

    private func getCategoryCell(indexPath: NSIndexPath) -> UITableViewCell {
        if expanded[FilterSectionIdentifier.Category] == true || indexPath.row < numberOfCategoriesWithoutExpansion {
            if indexPath.row == categories.count {
                let cell = UITableViewCell()
                cell.textLabel!.text = "See Less"
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                cell.onSwitch.on = categoryStates[indexPath.row] ?? false
                return cell
            }
        } else {
            let cell = UITableViewCell()
            cell.textLabel!.text = "See More"
            return cell
        }
    }

    private func getSortByCell(indexPath: NSIndexPath) -> RadioCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RadioCell") as! RadioCell
        cell.accessoryType = .None
        if expanded[FilterSectionIdentifier.SortBy] == true {
            cell.textLabel?.text = sortOptions[indexPath.row]
            if indexPath.row == selectedSortIndex?.rawValue {
                cell.accessoryType = .Checkmark
            }
        } else {
            cell.textLabel?.text = sortOptions[(selectedSortIndex?.rawValue)!]
            cell.accessoryType = .Checkmark
        }
        return cell
    }

    private func getDistanceCell(indexPath: NSIndexPath) -> RadioCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RadioCell") as! RadioCell
        cell.accessoryType = .None
        if expanded[FilterSectionIdentifier.Distance] == true {
            cell.textLabel?.text = distanceOptionsText[indexPath.row]
            if indexPath.row == selectedDistanceIndex {
                cell.accessoryType = .Checkmark
            }
        } else {
            cell.textLabel?.text = distanceOptionsText[selectedDistanceIndex]
            cell.accessoryType = .Checkmark
        }
        return cell
    }
}
