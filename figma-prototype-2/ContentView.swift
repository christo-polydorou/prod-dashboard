//
//  ContentView.swift
//  figma-prototype-2
//
//  Created by Christo Polydorou on 11/17/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State public var showingAddItemSheet = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                       
                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
                        Text(item.task_name ?? "Unknown Task")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    TitleView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {showingAddItemSheet = true}) {
                        Label("Add Item", image: "CTA")
                    }
         
 //                    showingAddItemSheet = false
 //                    Button(action: addItem) {
 //                        Label("Add Item", systemImage: "plus")
 //                    }
                }
            }
            .sheet(isPresented: $showingAddItemSheet) {
                // Pass the binding to AddItemView
                AddItemView(showingAddItemSheet: $showingAddItemSheet)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddItemView: View {
   @Environment(\.managedObjectContext) var viewContext
   @Binding var showingAddItemSheet: Bool
   @State private var itemName: String = ""
   @State private var selectedDate: Date = Date()

   var body: some View {
       
       NavigationView {
           Form {
               Section(header: Text("Task Details")) {
                   TextField("Task name", text: $itemName)
                   DatePicker("Due Date", selection: $selectedDate, displayedComponents: .date)
               }

               Section {
                   Button("Save Item") {
                       addItem()
                   }
                   
               }
           }
           .navigationBarTitle("Add New Item", displayMode: .inline)
       }
   }
   
   private func addItem() {
       let newItem = Item(context: viewContext)
       newItem.task_name = itemName  // Assuming 'name' is a property of your Item entity
       newItem.timestamp = selectedDate  // Assuming 'timestamp' is another property

       do {
           try viewContext.save()
           showingAddItemSheet = false
           // You might want to dismiss the view or give feedback of success
       } catch {
           // Handle the error, such as showing an alert to the user
           print("Error saving the new item: \(error)")
       }
   }

   // Add methods if needed for adding an item
}

struct TitleView: View {
   var body: some View {
       VStack(alignment: .leading) {
           Text("Daily Tasks")
               .font(.largeTitle)
           Text(formattedDate())
               .font(.subheadline)
       }
       .padding(.top, 20)
   }
}

func formattedDate() -> String {
   let now = Date()
   let dateFormatter = DateFormatter()
   dateFormatter.dateFormat = "MMMM" // Month
   let month = dateFormatter.string(from: now)

   let calendar = Calendar.current
   let day = calendar.component(.day, from: now)

   let numberFormatter = NumberFormatter()
   numberFormatter.numberStyle = .ordinal
   let dayOrdinal = numberFormatter.string(from: NSNumber(value: day))!

   dateFormatter.dateFormat = "yyyy" // Year
   let year = dateFormatter.string(from: now)

   return "\(month) \(dayOrdinal), \(year)"
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
