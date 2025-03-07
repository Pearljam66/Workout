//
//  EditExerciseGoalsSheet.swift
//  Workout
//
//  Created by Sarah Clark on 2/22/25.
//

import SwiftUI

struct EditExerciseGoalsSheet: View {
    @Binding var exercise: Exercise
    @Binding var showEditSheet: Bool
    @Binding var goalWeight: Double
    @Binding var goalReps: Int
    @Binding var goalDuration: Int
    let onSave: () -> Void

    // MARK: - Main View
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Edit Goals")) {
                    HStack {
                        Text("Weight Goal (lbs)")
                        Spacer()
                        TextField("Weight", value: $goalWeight, formatter: decimalFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Reps Goal")
                        Spacer()
                        TextField("Reps", value: $goalReps, formatter: integerFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Text("Duration Goal (min)")
                        Spacer()
                        TextField("Duration", value: $goalDuration, formatter: integerFormatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Edit \(exercise.name ?? "Exercise") goals")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showEditSheet = false
                },
                trailing: Button("Save") {
                    onSave()
                    showEditSheet = false
                }
            )
        }
    }

    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }

    private var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    struct PreviewWrapper: View {
        @State private var sampleExercise = Exercise.sample(id: "ex1", name: "Bench Press")
        @State private var showSheet = true
        @State private var weight: Double = 100.0
        @State private var reps: Int = 10
        @State private var duration: Int = 60

        var body: some View {
            EditExerciseGoalsSheet(
                exercise: $sampleExercise,
                showEditSheet: $showSheet,
                goalWeight: $weight,
                goalReps: $reps,
                goalDuration: $duration,
                onSave: {
                    // Preview save action
                    print("Saved: Weight: \(weight), Reps: \(reps), Duration: \(duration)")
                }
            )
            .preferredColorScheme(.light)
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var sampleExercise = Exercise.sample(id: "ex1", name: "Bench Press")
        @State private var showSheet = true
        @State private var weight: Double = 100.0
        @State private var reps: Int = 10
        @State private var duration: Int = 60

        var body: some View {
            EditExerciseGoalsSheet(
                exercise: $sampleExercise,
                showEditSheet: $showSheet,
                goalWeight: $weight,
                goalReps: $reps,
                goalDuration: $duration,
                onSave: {
                    // Preview save action
                    print("Saved: Weight: \(weight), Reps: \(reps), Duration: \(duration)")
                }
            )
            .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}
