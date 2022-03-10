//
//  TeamListViewModel.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/13.
//

import Foundation
import ContactKit
import CoreKit_IM

public class TeamListViewModel {
    var contactRepo = ContactRepo()
    public var teamList = [Team]()
    func getTeamList() -> [Team]? {
        teamList = contactRepo.getTeamList()
        return teamList
    }
}
