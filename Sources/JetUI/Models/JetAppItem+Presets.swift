//
//  JetAppItem+Presets.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import Foundation

extension JetAppItem {
    @MainActor
    public static let companyApps: [JetAppItem] = [
        JetAppItem(
            name: "TimeStamp",
            localIconName: "TimeStamp_icon", // 确保这些图片都在 JetUI 的 Resources 文件夹里
            actionURL: URL(string: "https://apps.apple.com/app/timestamp-id")!
        ),
        JetAppItem(
            name: "TimeProof",
            localIconName: "TimeProof_icon",
            actionURL: URL(string: "https://apps.apple.com/app/timeproof-id")!
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
