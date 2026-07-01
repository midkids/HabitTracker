//
//  ContentView.swift
//  HabitTracker
//
//  Created by Myron Snelson on 6/27/26.
//

import SwiftUI

// This project is from the challenges of
// Day 47. It was based on the iExpense app,
// but with elements of the Navigation added
// to it. For detailed explanations of the
// HabitTracker app logic, you may need to
// reference these two apps.

struct HabitItem: Identifiable, Codable {
    // This will make a unique id for every entry in the array
    // Had to make id a var to get rid of warning
    // saying it will not be decoded because it has
    // an initial value which is not overwritable by codable
    // However, this is actually the behavior we want
    // SwiftUI is just trying to be helpful in case
    // you did want to make this oject work with JSON
    var id = UUID()
    let title: String
    let description: String
    var streak: Int
}

// Classes with the observable protocol
//  can be used in more than one SwiftUI view
//  and all of those views will be updated
//  when the relevant properties of the object changes
@Observable
class Habits {
    var items = [HabitItem]() {
        didSet {
            // To correctly save our items correctly:
            // 1) make a JSON encoder
            // 2) encode the items variable
            // IMPORTANT: this encoder can only be used
            //   to encode objects that conform to the
            //   Codeable protocol - added Codeable to HabitItem struct
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    // custom initializer
    init() {
        // To load our items correctly:
        // 1) check to see if UserDefaults is there for key "Items"
        // 2) if it is there, try to decode the UserDefaults data
        //    into an array of HabitItems
        //    The .self is needed because SwiftUI needs to know
        //    we are referring to the type HabitItem itself
        //    That is, give me an array of HabitItems as a type
        // 3) store the loaded data into items property of
        //    the Habits class
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([HabitItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        // If either of the two actions above fail
        // make items an empty array
        items = []
    }
}

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    let description: String
    var body: some View {
        Text("Description:")
            .font(.title)
        Text(description)
        Spacer()
        Button("Dismiss") {
            dismiss()
        }
    }
}

struct ContentView: View {
    // Using @State here is just to keep the object alive
    //   It is the @Observable macro that notices changes
    //   and notifies SwiftUI views to update themselves
    // IMPORTANT: Both the ContentView and the AddView
    //   will share the same list of expense items
    @State private var habits = Habits()
    @State private var selectedHabit: HabitItem?
    
    var body: some View {
        NavigationStack {
            // This is a dynamic list. SwiftUI needs to know
            // how to identify each single view
            // inside there uniquely
            // so it can tell what view has changed
            // when the data changes
            List {
                // Could cause problems if title is not unique
                // It works in this case because we are deleting
                // a single specific row, one at a time
                // But many other cases, that extra information
                // will not be present causing our app to
                // behave strangely
                // ForEach(habits.items, id: \.title) {item in
                
                // Here is the fix because id will always
                // be unique
                // ForEach(habits.items, id: \.id) {item in
                
                // After adding Identifiable protocol
                // to the HabitItem struct,
                // we no longer need to have an id in
                // our ForEach
                ForEach(habits.items) {item in
                    // Very common layout
                    // Title and subtitle on left
                    // More information on right
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Habit:")
                                    .font(.headline)
                                Button(item.title) {
                                    selectedHabit = item
                                }
                                .foregroundStyle(.blue)
                                .underline()
                                .buttonStyle(.plain)
                
                                
                                Spacer()
                                Text("Streak:")
                                    .font(.headline)
                                Text("\(item.streak)")
                                Button("+") {
                                    // This line finds the real habit
                                    //  inside the habits.items array.
                                    // Because each HabitItem has a unique
                                    //  id, this finds the correct array
                                    //  position
                                    // firstIndex(where:) looks through each
                                    //  element in habits.items. For each
                                    //  HabitItem, Swift runs the closure.
                                    //  So $0.id means “the id of the habit
                                    // currently being checked.”
                                    if let index = habits.items.firstIndex(where: { $0.id == item.id }) {
                                        habits.items[index].streak += 1
                                    }
                                }
                                // This modifier to NOT use the default
                                // behavior of a button in a list
                                // (default: user can tap anywhere in row
                                // to activate button behavior)
                                .buttonStyle(.bordered)
                            }
                        }
                }
                // The onDelete modifier exists only on ForEach
                // allows swipe left to delete an item
                .onDelete(perform: removeItems)
            }
            .sheet(item: $selectedHabit) { habit in
                DetailView(description: habit.description)
            }
            .navigationTitle("HabitTracker")
            // Add habits by navigating to the AddView.
            .toolbar {
                NavigationLink {
                    // Here we are sharing the habits object
                    // from the ContentView with the AddView
                    // IMPORTANT: Both views will share the same
                    // observable class
                    // RESULT: both view will watch for changes
                    AddView(habits: habits)
                } label: {
                    Label("Add Habit", systemImage: "plus")
                }
            }
        }
    }
    
    // IndexSet is a sorted set of integers
    // It is used for deleting views from a ForEach view
    //   amongst other things
    func removeItems(at offsets: IndexSet) {
        habits.items.remove(atOffsets: offsets)
    }
}


#Preview {
    ContentView()
}

