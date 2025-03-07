//
//  ReportItemView.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 3/3/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

import SwiftUI
import FirebaseFirestore

struct ReportItemView: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var showSuccessMessage: Bool = false
    @Environment(\.presentationMode) var presentationMode

    // Northeastern colors
    let northeasternRed = Color(red: 0.8, green: 0.0, blue: 0.0) // #CC0000
    let northeasternBlack = Color.black
    let northeasternGray = Color(red: 0.4, green: 0.4, blue: 0.4) // #666666
    let northeasternWhite = Color.white

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                northeasternWhite
                    .edgesIgnoringSafeArea(.all)

                Form {
                    Section(header: Text("Item Details")
                        .foregroundColor(northeasternRed)
                        .font(.headline)
                    ) {
                        TextField("Name", text: $name)
                            .foregroundColor(northeasternBlack)
                        TextField("Description", text: $description)
                            .foregroundColor(northeasternBlack)
                        TextField("Location", text: $location)
                            .foregroundColor(northeasternBlack)
                    }
                    .listRowBackground(northeasternWhite)

                    Section {
                        Button(action: {
                            reportItem()
                        }) {
                            Text("Report Item")
                                .font(.headline)
                                .foregroundColor(northeasternWhite)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                        .background(northeasternRed)
                        .cornerRadius(10)
                    }
                    .listRowBackground(northeasternWhite)
                }
                .background(northeasternWhite)
                .navigationTitle("Report Lost Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Report Lost Item")
                            .font(.headline)
                            .foregroundColor(northeasternRed)
                    }
                }
                .alert(isPresented: $showSuccessMessage) {
                    Alert(
                        title: Text("Success"),
                        message: Text("Item reported successfully!"),
                        dismissButton: .default(Text("OK")) {
                            // Dismiss the view after the user taps "OK"
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helper Functions

    func reportItem() {
        // Check if any field is empty
        if name.isEmpty || description.isEmpty || location.isEmpty {
            print("Please fill out all fields")
            return
        }

        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("lostItems").addDocument(data: [
            "name": name,
            "description": description,
            "location": location,
            "status": "lost",
            "reportedBy": userId
        ]) { error in
            if let error = error {
                print("Error reporting item: \(error)")
            } else {
                print("Item reported successfully!")
                // Show success message
                showSuccessMessage = true
                // Clear the form after reporting
                name = ""
                description = ""
                location = ""
            }
        }
    }
}
