//
//  ContentView.swift
//  Week 6
//
//  Created by Ruby Lee on 11/6/25.
//

import SwiftUI

struct BloomTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var emoji: String
    var isDone: Bool
    var dateKey: String  // "YYYY-MM-DD" for grouping by day
    
    init(title: String, emoji: String, isDone: Bool = false, date: Date = .now) {
        self.id = UUID()
        self.title = title
        self.emoji = emoji
        self.isDone = isDone
        self.dateKey = Self.key(for: date)
    }
    
    static func key(for date: Date) -> String {
        let c = Calendar.current
        let comp = c.dateComponents([.year, .month, .day], from: date)
        let y = comp.year ?? 0, m = comp.month ?? 0, d = comp.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}

// MARK: - ContentView
struct ContentView: View {
    // Store everything in UserDefaults
    @AppStorage("bloom_tasks_json") private var tasksJSON: String = "[]"
    @AppStorage("bloom_rest_today") private var isRestDay: Bool = false
    
    @State private var tasks: [BloomTask] = []
    @State private var showNewTask = false
    @State private var newTitle = ""
    @State private var newEmoji = "🌱"
    
    private var todayKey: String { BloomTask.key(for: .now) }
    private var todaysTasks: [BloomTask] { tasks.filter { $0.dateKey == todayKey } }
    private var completedCount: Int { todaysTasks.filter { $0.isDone }.count }
    
    private let emojiOptions = ["🌱","🌼","🌸","🍀","🪴","🌻","🌷","🍃"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Rest day banner
                if isRestDay {
                    HStack(spacing: 12) {
                        Text("🫖")
                        VStack(alignment: .leading) {
                            Text("Rest day").font(.headline)
                            Text("Goals paused. Be gentle today.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(.mint.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
                
                // Tiny “garden” header
                HStack {
                    Text("Today’s Garden")
                        .font(.headline)
                    Spacer()
                    Text(gardenEmoji(for: completedCount))
                        .font(.title2)
                        .accessibilityLabel("Garden state")
                }
                .padding(.horizontal)
                
                // Task list
                List {
                    ForEach(todaysTasks) { task in
                        HStack(spacing: 12) {
                            Text(task.emoji).font(.title3)
                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundStyle(task.isDone ? .secondary : .primary)
                            Spacer()
                            Button {
                                toggle(task)
                            } label: {
                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(task.isDone ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                
                // Add new task button
                Button {
                    newTitle = ""
                    newEmoji = "🌱"
                    showNewTask = true
                } label: {
                    Label("New task", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.green.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Bloom")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isRestDay.toggle()
                    } label: {
                        Label("Rest", systemImage: isRestDay ? "bed.double.fill" : "bed.double")
                    }
                }
            }
        }
        .onAppear(perform: load)
        .sheet(isPresented: $showNewTask) { newTaskSheet }
    }
    
    // MARK: - New Task Sheet
    private var newTaskSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(.secondary.opacity(0.3))
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            
            Text("New Task").font(.title3).bold()
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                TextField("Write a simple title…", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pick an emoji")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(emojiOptions, id: \.self) { em in
                                Button {
                                    newEmoji = em
                                } label: {
                                    Text(em).font(.title2)
                                        .padding(8)
                                        .background(newEmoji == em ? .green.opacity(0.2) : .clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Button {
                addTask()
            } label: {
                Label("Add", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.bottom, 16)
        .presentationDetents([.height(280), .medium])
    }
    
    // MARK: - Actions
    private func addTask() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var all = tasks
        all.append(BloomTask(title: trimmed, emoji: newEmoji, date: .now))
        tasks = all
        save()
        showNewTask = false
    }
    
    private func toggle(_ task: BloomTask) {
        guard isRestDay == false else { return } // paused on rest day
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isDone.toggle()
            save()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        // Map to today’s array indices, then remove matching IDs from master list
        let todayIDs = todaysTasks.enumerated().filter { offsets.contains($0.offset) }.map { $0.element.id }
        tasks.removeAll { todayIDs.contains($0.id) }
        save()
    }
    
    // MARK: - Persistence
    private func load() {
        if let data = tasksJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([BloomTask].self, from: data) {
            self.tasks = decoded
        } else {
            self.tasks = []
        }
        
        // Ensure existing tasks for prior days keep their dateKey,
        // new tasks today will use today's key.
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(tasks),
           let text = String(data: data, encoding: .utf8) {
            tasksJSON = text
        }
    }
    
    // MARK: - Garden emoji
    private func gardenEmoji(for count: Int) -> String {
        if isRestDay { return "🫖" }
        switch count {
        case 0:  return "🌱"
        case 1...2: return "🌼"
        default: return "🌷"
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

