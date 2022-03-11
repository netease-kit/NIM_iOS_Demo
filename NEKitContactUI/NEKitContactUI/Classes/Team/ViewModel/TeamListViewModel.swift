//
//  TeamListViewModel.swift
//  NEKitCoreIM
//
//  Created by yuanyuan on 2022/1/13.
//

import Foundation
import NEKitContact
import NEKitCoreIM

public class TeamListViewModel {
    var contactRepo = ContactRepo()
    public var teamList = [Team]()
    func getTeamList() -> [Team]? {
        teamList = contactRepo.getTeamList()
        return teamList
    }
}
