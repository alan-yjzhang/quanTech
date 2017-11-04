//
//  Course.swift
//  quanTech
//
//  Created by Alan Zhang on 11/4/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation

class Course: NSObject
{
    static let courseIconList : [String] = ["course_1", "course_2", "course_3", "course_4", "course_5", "course_6", "course_7", "course_8"]
    var title : String?
    var shortTitle : String?
    var iconName : String?
    var courseId : String?
    var section : String?
    var scheduleId : String?
    var schoolCode : String?
    var teacherId : String?
    var teacherName : String?
    var schoolName : String?
    var homeRoom : String?
    var credits : Int = 0
    var studentNum : Int = 0
    
}
