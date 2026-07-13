//
//  JetAppItem+Presets.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import Foundation

extension JetAppItem {
    public static let timeStamp = JetAppItem(
        product: .timeStamp,
        name: "TimeStamp",
        actionTitle: "Open",
        actionBackgroundColorHex: 0xFFA800,
        actionTextColorHex: 0x000000,
        localIconName: "TimeStamp_icon",
        actionURL: URL(string: "JetCamera://")!,
        fallbackURL: URL(string: "https://apps.apple.com/us/app/stampcam-photo-video/id6747913178")!,
        showsDisclosureIndicator: false
    )

    public static let timeProof = JetAppItem(
        product: .timeProof,
        name: "TimeProof",
        actionTitle: "Open",
        actionBackgroundColorHex: 0x2786D5,
        actionTextColorHex: 0xFFFFFF,
        localIconName: "TimeProof_icon",
        actionURL: URL(string: "JetTimeProof://")!,
        fallbackURL: URL(string: "https://apps.apple.com/us/app/jet-camera-timeproof-camera/id6755984821")!,
        showsDisclosureIndicator: false
    )

    public static let jetFax = JetAppItem(
        product: .jetFax,
        name: "JetFax",
        actionTitle: "Open",
        actionBackgroundColorHex: 0x0A7AF5,
        actionTextColorHex: 0xFFFFFF,
        localIconName: "JetFax_icon",
        actionURL: URL(string: "jetfax://")!,
        fallbackURL: URL(string: "https://apps.apple.com/us/app/jet-fax-fax-from-iphone-free/id6752217283")!,
        showsDisclosureIndicator: false
    )

    public static let companyApps: [JetAppItem] = [
        .timeStamp,
        .timeProof,
        .jetFax,
        JetAppItem(
            name: "Alarm",
            actionTitle: "Open",
            localIconName: "Alarm_icon",
            actionURL: URL(string: "https://apps.apple.com/app/alarm-id")!
        ),
        JetAppItem(
            name: "FindMe",
            actionTitle: "Open",
            localIconName: "findMe_icon",
            actionURL: URL(string: "https://apps.apple.com/app/findme-id")!
        ),
        JetAppItem(
            name: "JetScan",
            actionTitle: "Open",
            localIconName: "JetScan_icon",
            actionURL: URL(string: "https://apps.apple.com/app/scan-id")!
        )
    ]
}
