//
//  TeamProvider.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/13.
//

import Foundation
import NIMSDK

public protocol TeamProviderDelegate: AnyObject {
    
}

public class TeamProvider {
    public static let shared = TeamProvider()
    private let mutiDelegate = MultiDelegate<TeamProviderDelegate>(strongReferences: false)

    private init(){}
    
    public func getTeamList() -> [Team] {
        var list: [Team] = []
        guard let teamList = NIMSDK.shared().teamManager.allMyTeams() else {
            return list
        }
        for team in teamList {
            list.append(Team(teamInfo: team))
        }
        return list
    }
    
    public func teamInfo(teamId: String?) -> Team? {
        if teamId == nil {
            return nil
        }
        return Team(teamInfo: NIMSDK.shared().teamManager.team(byId: teamId!))
    }
    
    public func superTeamInfo(teamId: String?) -> Team? {
        if teamId == nil {
            return nil
        }
        return Team(teamInfo: NIMSDK.shared().superTeamManager.team(byId: teamId!))
    }
    
//    MARK: Delegate
    public func addDelegate(delegate:TeamProviderDelegate) {
        mutiDelegate.addDelegate(delegate)
    }
    public func removeDelegate(delegate: TeamProviderDelegate) {
        mutiDelegate.removeDelegate(delegate)
    }
}
