//
//  JetAppItem+Presets.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import Foundation

extension JetAppItem {
    public static let companyApps: [JetAppItem] = [
        JetAppItem(
            name: "TimeStamp",
            localIconName: "TimeStamp_icon",
            actionURL: URL(string: "https://apps.apple.com/app/timestamp-id")!
        ),
        JetAppItem(
            name: "TimeProof",
            localIconName: "TimeProof_icon",
            actionURL: URL(string: "JetTimeProof://")!,
            fallbackURL: URL(string: "https://apps.apple.com/us/app/jet-camera-timeproof-camera/id6755984821")!,
            showsDisclosureIndicator: false
        ),
        JetAppItem(
            name: "JetFax",
            localIconName: "JetFax_icon",
            actionURL: URL(string: "https://apps.apple.com/app/fax-id")!
        ),
        JetAppItem(
            name: "Alarm",
            localIconName: "Alarm_icon",
            actionURL: URL(string: "https://apps.apple.com/app/alarm-id")!
        ),
        JetAppItem(
            name: "FindMe",
            localIconName: "findMe_icon",
            actionURL: URL(string: "https://apps.apple.com/app/findme-id")!
        ),
        JetAppItem(
            name: "JetScan",
            localIconName: "JetScan_icon",
            actionURL: URL(string: "https://apps.apple.com/app/scan-id")!
        )
    ]
}
