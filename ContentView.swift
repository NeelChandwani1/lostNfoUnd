

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State private var lostItems: [LostItem] = []
    @State private var searchQuery: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showLoginView: Bool = false
    @State private var showSignUpView: Bool = false
    @State private var notificationContent: String = ""

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

                VStack {
                    if isLoggedIn {
                        // Main app content
                        VStack(spacing: 20) {
                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(northeasternGray)
                                TextField("Search", text: $searchQuery)
                                    .foregroundColor(northeasternBlack)
                                if !searchQuery.isEmpty {
                                    Button(action: {
                                        searchQuery = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(northeasternGray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(northeasternWhite)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .padding(.horizontal)

                            if lostItems.isEmpty {
                                Text("No lost items found.")
                                    .foregroundColor(northeasternGray)
                                    .padding()
                            } else {
                                List(filteredItems) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundColor(northeasternBlack)
                                        Text(item.description)
                                            .font(.subheadline)
                                            .foregroundColor(northeasternGray)
                                        Text("Location: \(item.location)")
                                            .font(.caption)
                                            .foregroundColor(northeasternRed)
                                        Text("Status: \(item.status)")
                                            .font(.caption)
                                            .foregroundColor(item.status == "found" ? .green : northeasternRed)
                                    }
                                    .padding()
                                    .background(northeasternWhite)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .padding(.vertical, 5)
                                }
                                .listStyle(PlainListStyle())
                            }

                            Button("Retrieve Lost Items") {
                                fetchLostItems()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(northeasternRed)
                            .foregroundColor(northeasternWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)

                            NavigationLink(destination: ReportItemView()) {
                                Text("Report Lost Item")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(northeasternRed)
                                    .foregroundColor(northeasternWhite)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)

                            Button("Logout") {
                                do {
                                    try Auth.auth().signOut()
                                    isLoggedIn = false
                                    print("User logged out successfully.")
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(northeasternBlack)
                            .foregroundColor(northeasternWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .padding()
                        .navigationTitle("Lost and Found")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Lost and Found")
                                    .font(.headline)
                                    .foregroundColor(northeasternRed)
                            }
                        }
                    } else {
                        // Show login/sign-up options
                        VStack(spacing: 20) {
                            Image("northeastern_logo") // Add Northeastern logo asset
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(.bottom, 20)

                            Button("Login") {
                                showLoginView = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(northeasternRed)
                            .foregroundColor(northeasternWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)

                            Button("Sign Up") {
                                showSignUpView = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(northeasternBlack)
                            .foregroundColor(northeasternWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .sheet(isPresented: $showLoginView) {
                            LoginView(onLoginSuccess: {
                                isLoggedIn = true
                                requestNotificationPermission()
                                if let userId = Auth.auth().currentUser?.uid {
                                    saveFCMTokenToFirestore(userId: userId)
                                }
                            })
                        }
                        .sheet(isPresented: $showSignUpView) {
                            SignUpView(onSignUpSuccess: {
                                isLoggedIn = true
                                requestNotificationPermission()
                                if let userId = Auth.auth().currentUser?.uid {
                                    saveFCMTokenToFirestore(userId: userId)
                                }
                            })
                        }
                    }

                    // Display notification content
                    if !notificationContent.isEmpty {
                        Text("New Notification: \(notificationContent)")
                            .foregroundColor(northeasternRed)
                            .padding()
                    }
                }
            }
            .onAppear {
                checkAuthStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NotificationReceived"))) { notification in
                if let message = notification.userInfo?["message"] as? String {
                    notificationContent = message
                }
            }
        }
    }

    // MARK: - Helper Functions

    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            print("User is already logged in: \(user.email ?? "No email")")
            isLoggedIn = true
        } else {
            print("No user is logged in.")
            isLoggedIn = false
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }

    func saveFCMTokenToFirestore(userId: String) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                return
            }
            guard let token = token else {
                print("No FCM token available")
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(userId).setData(["fcmToken": token], merge: true) { error in
                if let error = error {
                    print("Error saving FCM token: \(error)")
                } else {
                    print("FCM token saved successfully!")
                }
            }
        }
    }

    var filteredItems: [LostItem] {
        if searchQuery.isEmpty {
            return lostItems
        } else {
            return lostItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchQuery) ||
                item.description.localizedCaseInsensitiveContains(searchQuery) ||
                item.location.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    func fetchLostItems() {
        let db = Firestore.firestore()
        db.collection("lostItems").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            if let documents = snapshot?.documents {
                self.lostItems = documents.map { document in
                    let id = document.documentID
                    let name = document["name"] as? String ?? "Unknown"
                    let description = document["description"] as? String ?? "No description"
                    let location = document["location"] as? String ?? "Unknown location"
                    let status = document["status"] as? String ?? "lost"
                    let reportedBy = document["reportedBy"] as? String ?? ""
                    print("Fetched item: \(name), ID: \(id)")
                    return LostItem(id: id, name: name, description: description, location: location, status: status, reportedBy: reportedBy)
                }
                print("Fetched \(self.lostItems.count) documents")
            } else {
                print("No documents found")
            }
        }
    }
}
