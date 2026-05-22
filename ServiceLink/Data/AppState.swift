//
//  AppState.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var session: ServiceLinkSession?

}
