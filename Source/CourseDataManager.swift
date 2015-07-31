//
//  CourseDataManager.swift
//  edX
//
//  Created by Akiva Leffert on 5/6/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

private let CourseOutlineModeChangedNotification = "CourseOutlineModeChangedNotification"
private let CurrentCourseOutlineModeKey = "OEXCurrentCourseOutlineMode"

private let DefaultCourseMode = CourseOutlineMode.Video

public class CourseDataManager: NSObject, CourseOutlineModeControllerDataSource {
    
    private let interface : OEXInterface?
    private let networkManager : NetworkManager?
    private var outlineQueriers : [String:CourseOutlineQuerier] = [:]
    private var discussionTopicManagers : [String:DiscussionTopicsManager] = [:]
    
    public init(interface : OEXInterface?, networkManager : NetworkManager?) {
        self.interface = interface
        self.networkManager = networkManager
        
        super.init()
        
        NSNotificationCenter.defaultCenter().oex_addObserver(self, name: OEXSessionEndedNotification) { (_, observer, _) -> Void in
            observer.outlineQueriers = [:]
            observer.discussionTopicManagers = [:]
            NSUserDefaults.standardUserDefaults().setObject(DefaultCourseMode.rawValue, forKey: CurrentCourseOutlineModeKey)
        }
    }
    
    public func querierForCourseWithID(courseID : String) -> CourseOutlineQuerier {
        if let querier = outlineQueriers[courseID] {
            return querier
        }
        else {
            let querier = CourseOutlineQuerier(courseID: courseID, interface : interface, networkManager : networkManager)
            outlineQueriers[courseID] = querier
            return querier
        }
    }
    
    public func discussionTopicManagerForCourseWithID(courseID : String) -> DiscussionTopicsManager {
        if let manager = discussionTopicManagers[courseID] {
            return manager
        }
        else {
            let manager = DiscussionTopicsManager(courseID: courseID, networkManager: self.networkManager)
            discussionTopicManagers[courseID] = manager
            return manager
        }
    }
    
    public var currentOutlineMode : CourseOutlineMode {
        get {
            return CourseOutlineMode(rawValue: NSUserDefaults.standardUserDefaults().stringForKey(CurrentCourseOutlineModeKey) ?? "") ?? DefaultCourseMode
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: CurrentCourseOutlineModeKey)
            NSNotificationCenter.defaultCenter().postNotificationName(CourseOutlineModeChangedNotification, object: nil)
        }
    }
    
    func freshOutlineModeController() -> CourseOutlineModeController {
        return CourseOutlineModeController(dataSource : self)
    }
    
    public var modeChangedNotificationName : String {
        return CourseOutlineModeChangedNotification
    }
}
