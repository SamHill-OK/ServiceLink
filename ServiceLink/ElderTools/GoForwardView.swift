//
//  GoForwardView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct GoForwardView: View {

    @ObservedObject var vm: ElderToolsViewModel

    var body: some View {
        Text("Go Forward (Coming Soon)")
            .navigationTitle("Go Forward Follow-Up")
            .padding()
    }
}
