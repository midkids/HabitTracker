//
//  AddView.swift
//  HabitTracker
//
//  Created by Myron Snelson on 6/27/26.
//

 import SwiftUI
 
 struct AddView: View {
 
 // IMPORTANT: This app was changed for
 // Challenge #1 in Project 9, Day 4
 // This is the Navigation App project
 // Changes were made to use NavigationLink
 // rather that a sheet to show the AddView
 // The original code was saved in a project
 // named iExpenseOriginal
 
 
 // Reads the dismiss value from the environment
 // Need this statement to dismiss add expense
 // screen when the time is right
 // It controls the views environment
 // The isPresented parameter,
 //   which references the showingAddExpense variable
 //   is linked to the environment
 //   and is automatically turned to false
 //   when the AdView view is dismissed
 // IMPORTANT: We do not have to specify type
 // It will call the dismiss function
 //   to dismiss the AddView view
 @Environment(\.dismiss) var dismiss
 
 @State private var title = ""
 @State private var description = ""
 @State private var number = 0
 
 // The AddView expects to be made with
 // an Habits object that is shared with it
 // upon instantiation
 // IMPORTANT: Both views will share the same
 // observable class
 // (made observable in ContentView)
 // RESULT: both view will watch for changes
 // IMPORTANT: Both the ContentView and the AddView
 //   will share the same list of habit items
 var habits: Habits
 
 var body: some View {
 Form {
 TextField("Title", text: $title)
 TextField("Description", text: $description)
 Text("Number \(number)")
 .keyboardType(.decimalPad)
 }
 .navigationTitle("Add new habit")
 .toolbar {
 // Added tool bar items to allow
 // save or cancel
 ToolbarItem(placement: .confirmationAction) {
 Button("Save") {
 let item = HabitItem(title: title, description: description, number: number)
 habits.items.append(item)
 // Returns to the expense list after saving.
 dismiss()
 }
 }
 ToolbarItem(placement: .cancellationAction) {
 Button("Cancel") {
 dismiss()
 }
 }
 }
 // Hid back button to force user to make a choice
 //  whether to save or cancel the AddView screen
 .navigationBarBackButtonHidden()
 }
 }
 
 #Preview {
 // Our expenses will be a new Expenses object
 // That works because:
 // it is just for preview purposes
 AddView(habits: Habits())
 }

