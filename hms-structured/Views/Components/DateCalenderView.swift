//
//  DateCalendarView.swift
//  Patient
//
//  Created by SHHH!! private on 25/04/24.
//

import SwiftUI

class BookingCal: ObservableObject {
    @Published var index: Int = 0
    @Published var date: Date = Date()
}

let bookingCal : BookingCal = BookingCal()

struct DateCalendarView: View {
    @Binding var selectedDate: Date
    //    #A1A8B0
    @State private var dayColor:Color = Color(red: 161/255, green: 168/255, blue: 176/255)
    //     #101623
    @State private var dateColor:Color = Color(red: 16/255, green: 22/255, blue: 35/255)
    
    func dateGetter(index : Int) -> Date{
        return Calendar.current.date(byAdding: .day, value: index, to: Date())!
    }
    @State private var bgColor:Color = Color(red: 242/255, green: 242/255, blue: 242/255)
    @State private var symptomsColor:Color = Color(red: 157/255, green: 159/255, blue: 159/255)
    @State private var timeArray:[String] = ["10:00","10:30","11:00","11:30","12:00","5:00","5:30","6:00","6:30","7:00"]
    
    @State private var headingColor:Color = Color(red: 28/255, green: 28/255, blue: 28/255)
    
    
    
    func getDay(date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: date)
    }
    func getDate(date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    @ObservedObject var indexDate = bookingCal
    let columns : [GridItem] = [GridItem(.fixed( 2)),
                                GridItem(.flexible())
    ]
    @StateObject var temp = BookingCal()
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false){
            HStack{
                ForEach(0..<7){ i in
                    
                    let date = dateGetter(index: i)
                    if i != indexDate.index{
                        Button {
                            withAnimation {
                                indexDate.index = i
                            }
                            temp.date = date
                            indexDate.date = date
                            selectedDate = date
                            print(temp.date)
                            
                        } label: {
                            VStack{
                                Text((getDay(date: date)))
                                    .font(Font.custom("SF Pro Display Regular", size: 16))
                                    .foregroundColor(dayColor)
                                
                                
                                Text((getDate(date: date)))
                                    .font(Font.custom("SF Pro Display ", size: 18))
                                    .foregroundColor(dateColor)
                            }.frame(alignment: .center)
                                .padding(.leading)
                            
                                .background{
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width:64,height: 80)
                                        .foregroundColor(.white)
                                        .padding(.leading)
                                }
                                .padding()
                        }
                        
                    }
                    else{
                        Button {
                            withAnimation {
                                indexDate.index = i
                                indexDate.date = date
                            }
                            
                        } label: {
                            VStack{
                                Text((getDay(date: date)))
                                    .font(Font.custom("SF Pro Display Regular", size: 16))
                                    .foregroundColor(.white)
                                
                                Text((getDate(date: date)))
                                    .font(Font.custom("SF Pro Display ", size: 18))
                                    .foregroundColor(.white)
                            }.frame(alignment: .center)
                                .padding(.leading)
                                .background{
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width:64,height: 80)
                                        .foregroundColor(.blue)
                                        .padding(.leading)
                                }
                                .padding()
                        }
                    }
                }
            }
            .frame(height: 85)
            .padding(.bottom)
            .padding(.trailing,16)
        }
        
        
    }
}
struct YourView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a placeholder Binding<Date>
        let selectedDate = Binding<Date>(
            get: { Date() },
            set: { _ in }
        )
        
        // Use the placeholder Binding<Date> in the preview
        DateCalendarView(selectedDate: selectedDate)
            .previewLayout(.sizeThatFits)
    }
}
struct WeekValue: Identifiable {
    var id: Int
    var date: [Date]
}
class WeekStore: ObservableObject {
    // Combined of all Weeks
    @Published var allWeeks: [WeekValue] = []
    
    // Current chosen date indicator
    @Published var currentDate: Date = Date()
    
    // Index indicator
    @Published var currentIndex: Int = 0
    @Published var indexToUpdate: Int = 0
    
    // Array of Weeks
    @Published var currentWeek: [Date] = []
    @Published var nextWeek: [Date] = []
    @Published var previousWeek: [Date] = []
    
    // Initial append of weeks
    init() {
        fetchCurrentWeek()
        fetchPreviousNextWeek()
        appendAll()
    }
    
    func appendAll() {
        var newWeek = WeekValue(id: 0, date: currentWeek)
        allWeeks.append(newWeek)
        
        newWeek = WeekValue(id: 2, date: nextWeek)
        allWeeks.append(newWeek)
        
        newWeek = WeekValue(id: 1, date: previousWeek)
        allWeeks.append(newWeek)
    }
    
    func update(index: Int) {
        var value: Int = 0
        if index < currentIndex {
            value = 1
            if indexToUpdate == 2 {
                indexToUpdate = 0
            } else {
                indexToUpdate = indexToUpdate + 1
            }
        } else {
            value = -1
            if indexToUpdate == 0 {
                indexToUpdate = 2
            } else {
                indexToUpdate = indexToUpdate - 1
            }
        }
        currentIndex = index
        addWeek(index: indexToUpdate, value: value)
    }
    
    func addWeek(index: Int, value: Int) {
        allWeeks[index].date.removeAll()
        var calendar = Calendar(identifier: .gregorian)
        let today = Calendar.current.date(byAdding: .day, value: 7 * value , to: self.currentDate)!
        self.currentDate = today
        
        calendar.firstWeekday = 7
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                allWeeks[index].date.append(weekday)
            }
        }
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDate, inSameDayAs: date)
    }
    
    func dateToString(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func fetchCurrentWeek() {
        let today = currentDate
        var calendar = Calendar(identifier: .gregorian)
        
        calendar.firstWeekday = 7
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                currentWeek.append(weekday)
            }
        }
    }
    
    func fetchPreviousNextWeek() {
        nextWeek.removeAll()
        
        let nextWeekToday = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 7
        
        let startOfWeekNext = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: nextWeekToday))!
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeekNext) {
                nextWeek.append(weekday)
            }
            
        }
        
        previousWeek.removeAll()
        let previousWeekToday = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        
        let startOfWeekPrev = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: previousWeekToday))!
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeekPrev) {
                previousWeek.append(weekday)
            }
        }
    }
}

