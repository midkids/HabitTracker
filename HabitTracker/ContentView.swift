//
//  ContentView.swift
//  HabitTracker
//
//  Created by Myron Snelson on 6/27/26.
//

import SwiftUI



/*
// Storing user settings with UserDefaults
//
// UserDefaults can store integers, strings, Booleans, and more
// The simplest way to read and write a small of data
// is through user defaults
// It is a great way to keep user preferences
// Storing too many user defaults will slow the
// loading of your app
// Should store no more than 512 KB
// Their values are automatically loaded when our app starts
//   so try not to save too much
// Should store no more than 512 KB
// IMPORTANT: UserDefaults uses strings for its key names.

struct ContentView: View {
    
//    @State private var tapCount = 0
    
    // If the key cannot be found (as in the first time
    // the app runs), the value of Tap defaults to 0
    // because it is an integer
    // Booleans default to false
    // iOS buffers writing default values and
    // it can take a few seconds to write all the user defaults
    // However, in theory, nothing will ever be lost
//    @State private var tapCount =
//     UserDefaults.standard.integer(forKey: "Tap")
    
    // IMPORTANT: App storage is a MUCH better choice
    // than user defaults (user defaults actually works
    // by using app storage)
    // When the value of tapCount changes,
    //   SwiftUI will reinvoke the body property automatically
    //   This makes sure the user interface always
    //   reflects the latest value
    // The default value is used if there is no value set
    @AppStorage("tapCount") private var tapCount = 0
    
    var body: some View {
        Button("Tap Count: \(tapCount)") {
            tapCount += 1
            // Standard is the built in instance of User Defaults
            // that is attached to our apps (can create your own)
            // Single set method and
            // It can store integers, strings, booleans
            // Must give a string name (e.g. "Tap")
            // to the value we are writing
            UserDefaults.standard.set(tapCount, forKey: "Tap")
        }
    }
}
 */

/*
// Archiving Swift objects with Codable
//
// For complex data types such as
//   custom Swift types
// Here we have simple text, but could also have
//   other simple types (e.g. integers, booleans, doubles,
//   arrays, and dictionaries)
// IMPORTANT: use protocol Codable
//   which is responsible for archiving and unarchiving data
//   that means it can convert objects like this one
//   into plain text and back again
// NEW TYPE: JSON - JavaScript Object Notation
// is the most common type used with Codable
// Our expense items are ready to be stored
struct User: Codable {
    let firstName: String
    let lastName: String
}

struct ContentView: View {
    @State private var user = User(firstName: "Taylor", lastName: "Swift")
    var body: some View {
        Button("Save User") {
            // The value of the data variable
            // is encoded in type Data
            // that can hold any type of data
            // object -> JSON binary data format type Data
            // To do JSON -> object, we would use JSONDecoder
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(user) {
                
                UserDefaults.standard.set(data, forKey: "UserData")
            }
        }
      
    }
}
*/


// The actual iExpense project
// - Building a list we can delete from
// - Working with identifiable items in SwiftUI
// - Sharing an observed object with a new view
// - Making changes permanent with UserDefaults
// - Final polish
//
// Making the struct conform to the protcol Identifiable
// Lets SwiftUI know this data can be uniquely identifed
// Identifiable requires a property named id that makes
// the struct unique
// IMPORTANT: the JSON encoder can only be used
//   to encode objects that conform to the
//   Codeable protocol - added Codeable to HabitItem struct
// If we add Codable conformance to a type,
//   Swift can generate archiving and unarchiving code for us.
// This only works if all the properties inside the type also conform to Codable
// UUID already conforms to Codable
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

struct ContentView: View {
    // Using @State here is just to keep the object alive
    //   It is the @Observable macro that notices changes
    //   and notifies SwiftUI views to update themselves
    // IMPORTANT: Both the ContentView and the AddView
    //   will share the same list of expense items
    @State private var habits = Habits()
    
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
                                Text(item.title)
                                //                            Text(item.description)
                                Spacer()
                                Text("Streak:")
                                    .font(.headline)
                                Text("\(item.streak)")
                                Spacer()
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

