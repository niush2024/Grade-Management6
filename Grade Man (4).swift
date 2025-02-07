import Foundation

// MARK: - Data Structures
struct Student {
    let name: String
    var grades: [Double] // Changed to `var` to allow updates
}

// MARK: - Core Functions
func loadStudents() -> [Student] {
    guard let filePath = Bundle.main.path(forResource: "students", ofType: "csv") else {
        print("CSV file not found!")
        return []
    }
    
    do {
        let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
        var students = [Student]()
        let lines = csvData.components(separatedBy: .newlines)
        
        for line in lines {
            let components = line.components(separatedBy: ",")
            guard components.count >= 11 else { continue }
            
            let name = components[0].trimmingCharacters(in: .whitespaces)
            let grades = components[1...10].compactMap {
                Double($0.trimmingCharacters(in: .whitespaces))
            }
            
            guard grades.count == 10 else { continue }
            students.append(Student(name: name, grades: grades))
        }
        
        return students
    } catch {
        print("Error reading CSV file: \(error)")
        return []
    }
}

func calculateAverage(grades: [Double]) -> Double {
    return grades.reduce(0, +) / Double(grades.count)
}

// MARK: - Input Handling
func getMenuChoice() -> Int {
    while true {
        print("\nEnter your choice (1-10): ", terminator: "")
        if let input = readLine(), let choice = Int(input), (1...10).contains(choice) {
            return choice
        }
        print("Invalid option. Please enter a number between 1 and 10.")
    }
}

func getStudentName(students: [Student]) -> String {
    while true {
        print("\nWhich student would you like to choose?")
        guard let name = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        
        if students.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            return name
        }
        print("Student '\(name)' does not exist. Please try again.")
    }
}

// MARK: - Extra Credit: Update Grade
func updateGrade(for student: inout Student) {
    while true {
        print("\nWhich assignment would you like to update (1-10):")
        guard let input = readLine(), let assignment = Int(input), (1...10).contains(assignment) else {
            print("Invalid assignment. Please enter a number between 1 and 10.")
            continue
        }
        
        print("\nEnter the new grade for assignment #\(assignment):")
        guard let newGradeInput = readLine(), let newGrade = Double(newGradeInput) else {
            print("Invalid grade. Please enter a number.")
            continue
        }
        
        student.grades[assignment - 1] = newGrade
        print("\nGrade updated successfully!")
        print("\(student.name)'s new grades: \(student.grades.map { String(format: "%.1f", $0) }.joined(separator: ", "))")
        return
    }
}

// MARK: - Feature Functions
func displayStudentGrade(students: [Student]) {
    let name = getStudentName(students: students)
    guard let student = students.first(where: { $0.name.lowercased() == name.lowercased() }) else { return }
    
    let average = calculateAverage(grades: student.grades)
    print("\n\(student.name)'s grade in the class is \(String(format: "%.2f", average))")
}

func displayAllGradesForStudent(students: [Student]) {
    let name = getStudentName(students: students)
    guard let student = students.first(where: { $0.name.lowercased() == name.lowercased() }) else { return }
    
    print("\n\(student.name)'s grades for this class are:")
    let gradesString = student.grades.map { String(format: "%.1f", $0) }.joined(separator: ", ")
    print(gradesString)
}

func displayAllGradesAllStudents(students: [Student]) {
    for student in students {
        let gradesString = student.grades.map { String(format: "%.1f", $0) }.joined(separator: ", ")
        print("\n\(student.name) grades are: \(gradesString)")
    }
}

func calculateClassAverage(students: [Student]) -> Double {
    let averages = students.map { calculateAverage(grades: $0.grades) }
    return averages.reduce(0, +) / Double(averages.count)
}

func handleAssignmentAverage(students: [Student]) {
    while true {
        print("\nWhich assignment would you like to get the average of (1-10):")
        guard let input = readLine(), let assignment = Int(input), (1...10).contains(assignment) else {
            print("Invalid assignment. Please enter a number between 1 and 10.")
            continue
        }
        
        let index = assignment - 1
        let grades = students.compactMap { $0.grades.indices.contains(index) ? $0.grades[index] : nil }
        let average = grades.reduce(0, +) / Double(grades.count)
        
        print("\nThe average for assignment #\(assignment) is \(String(format: "%.1f", average))")
        return
    }
}

func findLowestGrade(students: [Student]) -> (name: String, average: Double) {
    guard let minStudent = students.min(by: { calculateAverage(grades: $0.grades) < calculateAverage(grades: $1.grades) }) else {
        return ("", 0.0)
    }
    return (minStudent.name, calculateAverage(grades: minStudent.grades))
}

func findHighestGrade(students: [Student]) -> (name: String, average: Double) {
    guard let maxStudent = students.max(by: { calculateAverage(grades: $0.grades) < calculateAverage(grades: $1.grades) }) else {
        return ("", 0.0)
    }
    return (maxStudent.name, calculateAverage(grades: maxStudent.grades))
}

func handleFilterByGradeRange(students: [Student]) {
    func getValidDouble(prompt: String) -> Double {
        while true {
            print(prompt)
            guard let input = readLine(), let value = Double(input) else {
                print("Invalid input. Please enter a number.")
                continue
            }
            return value
        }
    }
    
    let low = getValidDouble(prompt: "\nEnter the low range:")
    let high = getValidDouble(prompt: "\nEnter the high range:")
    
    guard low <= high else {
        print("Invalid range: low must be ≤ high")
        return
    }
    
    print()
    for student in students {
        let average = calculateAverage(grades: student.grades)
        if average >= low && average <= high {
            print("\(student.name): \(String(format: "%.1f", average))")
        }
    }
}

// MARK: - Main Program Logic
var students = loadStudents()
var shouldQuit = false

while !shouldQuit {
    print("""
    \nWelcome to the Grade Manager!
    
    What would you like to do? (Enter the number):
    1. Display grade of a single student
    2. Display all grades for a student
    3. Display all grades of ALL students
    4. Find the average grade of the class
    5. Find the average grade of an assignment
    6. Find the lowest grade in the class
    7. Find the highest grade of the class
    8. Filter students by grade range
    9. Update a student's grade
    10. Quit
    """)
    
    switch getMenuChoice() {
    case 1:
        displayStudentGrade(students: students)
    case 2:
        displayAllGradesForStudent(students: students)
    case 3:
        displayAllGradesAllStudents(students: students)
    case 4:
        let average = calculateClassAverage(students: students)
        print("\nThe class average is: \(String(format: "%.2f", average))")
    case 5:
        handleAssignmentAverage(students: students)
    case 6:
        let (name, average) = findLowestGrade(students: students)
        print("\n\(name) has the lowest grade: \(String(format: "%.2f", average))")
    case 7:
        let (name, average) = findHighestGrade(students: students)
        print("\n\(name) has the highest grade: \(String(format: "%.2f", average))")
    case 8:
        handleFilterByGradeRange(students: students)
    case 9:
        let name = getStudentName(students: students)
        if let index = students.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
            updateGrade(for: &students[index])
        }
    case 10:
        print("\nHave a great rest of your day!")
        shouldQuit = true
    default:
        break
    }
}
