#!/usr/bin/env swift
import EventKit
import Foundation

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let args = CommandLine.arguments
let command = args.count > 1 ? args[1] : "help"

func requestAccess(completion: @escaping (Bool) -> Void) {
    store.requestFullAccessToReminders { granted, error in
        completion(granted)
    }
}

func listLists() {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        let calendars = store.calendars(for: .reminder)
        for cal in calendars {
            print("📋 \(cal.title)")
        }
        semaphore.signal()
    }
    semaphore.wait()
}

func showReminders(listName: String?) {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        var calendars = store.calendars(for: .reminder)
        if let name = listName {
            calendars = calendars.filter { $0.title.lowercased() == name.lowercased() }
        }
        
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: calendars
        )
        
        store.fetchReminders(matching: predicate) { reminders in
            if let reminders = reminders, !reminders.isEmpty {
                for r in reminders.prefix(30) {
                    let list = r.calendar?.title ?? "?"
                    print("• \(r.title ?? "Sin título") [\(list)]")
                }
                if reminders.count > 30 {
                    print("... y \(reminders.count - 30) más")
                }
            } else {
                print("✨ No hay recordatorios pendientes")
            }
            semaphore.signal()
        }
    }
    semaphore.wait()
}

func todayReminders() {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: today,
            ending: tomorrow,
            calendars: calendars
        )
        
        store.fetchReminders(matching: predicate) { reminders in
            if let reminders = reminders, !reminders.isEmpty {
                for r in reminders {
                    let list = r.calendar?.title ?? "?"
                    print("📅 \(r.title ?? "Sin título") [\(list)]")
                }
            } else {
                print("✨ No hay recordatorios para hoy")
            }
            semaphore.signal()
        }
    }
    semaphore.wait()
}

func weekReminders() {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        let today = Calendar.current.startOfDay(for: Date())
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: today,
            ending: weekEnd,
            calendars: calendars
        )
        
        store.fetchReminders(matching: predicate) { reminders in
            if let reminders = reminders, !reminders.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                for r in reminders {
                    let list = r.calendar?.title ?? "?"
                    let dateStr = r.dueDateComponents?.date.map { formatter.string(from: $0) } ?? "?"
                    print("📅 \(r.title ?? "Sin título") [\(list)] - \(dateStr)")
                }
            } else {
                print("✨ No hay recordatorios para esta semana")
            }
            semaphore.signal()
        }
    }
    semaphore.wait()
}

func overdueReminders() {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        let distantPast = Date.distantPast
        let now = Date()
        
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: distantPast,
            ending: now,
            calendars: calendars
        )
        
        store.fetchReminders(matching: predicate) { reminders in
            if let reminders = reminders, !reminders.isEmpty {
                for r in reminders {
                    let list = r.calendar?.title ?? "?"
                    print("⚠️ \(r.title ?? "Sin título") [\(list)]")
                }
            } else {
                print("✨ No hay recordatorios vencidos")
            }
            semaphore.signal()
        }
    }
    semaphore.wait()
}

func addReminder(title: String, listName: String) {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        guard let calendar = calendars.first(where: { $0.title.lowercased() == listName.lowercased() }) else {
            print("❌ Lista '\(listName)' no encontrada")
            semaphore.signal()
            return
        }
        
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.calendar = calendar
        
        do {
            try store.save(reminder, commit: true)
            print("✅ Añadido: \(title) [\(listName)]")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        semaphore.signal()
    }
    semaphore.wait()
}

func addReminderWithDate(title: String, listName: String, dateString: String) {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        guard let calendar = calendars.first(where: { $0.title.lowercased() == listName.lowercased() }) else {
            print("❌ Lista '\(listName)' no encontrada")
            semaphore.signal()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            print("❌ Formato de fecha inválido. Usa: yyyy-MM-dd HH:mm")
            semaphore.signal()
            return
        }
        
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.calendar = calendar
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        reminder.addAlarm(EKAlarm(absoluteDate: date))
        
        do {
            try store.save(reminder, commit: true)
            print("✅ Añadido: \(title) [\(listName)] - \(dateString)")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        semaphore.signal()
    }
    semaphore.wait()
}

func completeReminder(title: String) {
    requestAccess { granted in
        guard granted else { print("❌ No access"); semaphore.signal(); return }
        
        let calendars = store.calendars(for: .reminder)
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: calendars
        )
        
        store.fetchReminders(matching: predicate) { reminders in
            guard let reminders = reminders else { semaphore.signal(); return }
            
            if let reminder = reminders.first(where: { ($0.title ?? "").lowercased().contains(title.lowercased()) }) {
                reminder.isCompleted = true
                do {
                    try store.save(reminder, commit: true)
                    print("✅ Completado: \(reminder.title ?? title)")
                } catch {
                    print("❌ Error: \(error.localizedDescription)")
                }
            } else {
                print("❌ No se encontró: \(title)")
            }
            semaphore.signal()
        }
    }
    semaphore.wait()
}

func printHelp() {
    print("""
    🐙 Apple Reminders CLI (Swift/EventKit)
    
    Comandos:
      lists                    - Listar todas las listas
      show [lista]             - Mostrar recordatorios (opcional: de una lista)
      today                    - Recordatorios para hoy
      week                     - Recordatorios de esta semana
      overdue                  - Recordatorios vencidos
      add "tarea" "lista"      - Añadir recordatorio
      add "tarea" "lista" "yyyy-MM-dd HH:mm" - Añadir con fecha
      complete "tarea"         - Marcar como completado
    
    Ejemplos:
      reminders.swift lists
      reminders.swift show "Household"
      reminders.swift today
      reminders.swift add "Comprar leche" "Household"
      reminders.swift add "Llamar doctor" "Diligencias" "2026-01-20 09:00"
    """)
}

// Main
switch command {
case "lists":
    listLists()
case "show":
    let listName = args.count > 2 ? args[2] : nil
    showReminders(listName: listName)
case "today":
    todayReminders()
case "week":
    weekReminders()
case "overdue":
    overdueReminders()
case "add":
    if args.count >= 4 {
        let title = args[2]
        let list = args[3]
        if args.count >= 5 {
            addReminderWithDate(title: title, listName: list, dateString: args[4])
        } else {
            addReminder(title: title, listName: list)
        }
    } else {
        print("Uso: add \"tarea\" \"lista\" [\"fecha\"]")
    }
case "complete":
    if args.count >= 3 {
        completeReminder(title: args[2])
    } else {
        print("Uso: complete \"tarea\"")
    }
default:
    printHelp()
}
