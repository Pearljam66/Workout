//
//  GoalGaugeSection.swift
//  Workout
//
//  Created by Sarah Clark on 2/22/25.
//

import SwiftUI

struct ExerciseGoals: Codable {
    var weight: Double
    var reps: Int
    var duration: Int

    static let defaultGoals = ExerciseGoals(weight: 0.0, reps: 0, duration: 0)
}

struct GoalGaugeSection: View {
    @Binding var exercise: Exercise
    @Binding var showEditSheet: Bool
    let weightGradient = Gradient(colors: [.lightPink, .brightCoralRed, .pink])
    let repsGradient = Gradient(colors: [.lightYellow, .yellow, .darkYellow])
    let durationGradient = Gradient(colors: [.lightGreen, .brightLimeGreen, .green])
    let exerciseSetSummaries: [ExerciseSetSummary]

    @AppStorage("exerciseGoals") private var exerciseGoalsData: Data = Data()

    // Current max values of each that the client has achieved.
    @State private var currentMaxWeight: Double = 0.0
    @State private var currentMaxReps: Int = 0
    @State private var currentMaxDuration: Int = 0

    // Current percentages for each.
    @State private var goalWeightProgress: Int = 0
    @State private var goalRepsProgress: Int = 0
    @State private var goalDurationProgress: Int = 0

    // Local state for editing
    @State private var localGoalWeight: Double = 0.0
    @State private var localGoalReps: Int = 0
    @State private var localGoalDuration: Int = 0

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .padding(.trailing, -5)
                Text("PERFORMANCE GOALS")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                Spacer()
                Button(action: {
                    showEditSheet.toggle()
                }, label: {
                    Text("Edit")
                })
            }
            .padding(.horizontal, 10)
            .padding(.top, 40)

            HStack(spacing: 40) {
                VStack(spacing: 10) {
                    Gauge(value: currentMaxWeight, in: 0...localGoalWeight) {
                    } currentValueLabel: {
                        Text("\(goalWeightProgress)%")
                            .font(.headline)
                    } minimumValueLabel: {
                        Text("0")
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("\(Int(localGoalWeight))")
                            .font(.caption2)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(weightGradient)
                    .scaleEffect(1.5)
                    Text("Weight (lbs)")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .lineLimit(1)
                }

                VStack(spacing: 10) {
                    Gauge(value: Double(currentMaxReps), in: 0...Double(localGoalReps)) {
                        Text("Reps")
                    } currentValueLabel: {
                        Text("\(goalRepsProgress)%")
                            .font(.headline)
                    } minimumValueLabel: {
                        Text("0")
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("\(localGoalReps)")
                            .font(.caption2)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(repsGradient)
                    .scaleEffect(1.5)
                    Text("Reps")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }

                VStack(spacing: 10) {
                    Gauge(value: Double(currentMaxDuration), in: 0...Double(localGoalDuration)) {
                        Text("Duration")
                    } currentValueLabel: {
                        Text("\(goalDurationProgress)%")
                            .font(.headline)
                    } minimumValueLabel: {
                        Text("0")
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("\(localGoalDuration)")
                            .font(.caption2)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(durationGradient)
                    .scaleEffect(1.5)
                    Text("Duration (min)")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
            }
            .padding(.bottom, 20)
            .padding(.top, 50)
            .padding(.horizontal, 20)
            .background(glassBackground)
            .padding(.bottom, 10)
            .padding(.top, -10)
            .sheet(isPresented: $showEditSheet) {
                EditExerciseGoalsSheet(
                    exercise: $exercise,
                    showEditSheet: $showEditSheet,
                    goalWeight: $localGoalWeight,
                    goalReps: $localGoalReps,
                    goalDuration: $localGoalDuration,
                    onSave: saveGoals
                )
            }
            .onAppear {
                loadGoals()
                let sets = exerciseSetSummaries.compactMap { $0.exerciseSet }
                if let maxWeight = getMaxWeightForExercise(exercise, in: sets) {
                    currentMaxWeight = Double(maxWeight)
                }
                if let maxReps = getMaxRepsForExercise(from: exerciseSetSummaries) {
                    currentMaxReps = maxReps
                }
                if let maxTime = getMaxDurationForExercise(exercise, in: sets) {
                    currentMaxDuration = maxTime
                }
                updateProgressValues()
            }
            .onChange(of: exercise) { loadGoals() }
        }
    }

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.black.opacity(0.1), lineWidth: 1)
                    .blur(radius: 1)
                    .mask(RoundedRectangle(cornerRadius: 15).fill(.black))
            }
            .padding(.top, 10)
    }

    private func updateProgressValues() {
        goalWeightProgress = localGoalWeight > 0 ? Int((currentMaxWeight / localGoalWeight) * 100) : 0
        goalRepsProgress = localGoalReps > 0 ? Int((Double(currentMaxReps) / Double(localGoalReps)) * 100) : 0
        goalDurationProgress = localGoalDuration > 0 ? Int((Double(currentMaxDuration) / Double(localGoalDuration)) * 100) : 0
    }

    private func loadGoals() {
        if let data = try? JSONDecoder().decode([String: ExerciseGoals].self, from: exerciseGoalsData),
           let exerciseName = exercise.name,
           let goals = data[exerciseName] {
            localGoalWeight = goals.weight
            localGoalReps = goals.reps
            localGoalDuration = goals.duration
        } else {
            localGoalWeight = 0.0
            localGoalReps = 0
            localGoalDuration = 0
        }
        updateProgressValues()
    }

    private func saveGoals() {
        var goalsDict: [String: ExerciseGoals]
        if let existingData = try? JSONDecoder().decode([String: ExerciseGoals].self, from: exerciseGoalsData) {
            goalsDict = existingData
        } else {
            goalsDict = [:]
        }

        if let exerciseName = exercise.name {
            goalsDict[exerciseName] = ExerciseGoals(
                weight: localGoalWeight,
                reps: localGoalReps,
                duration: localGoalDuration
            )
            if let data = try? JSONEncoder().encode(goalsDict) {
                exerciseGoalsData = data
            }
        }
    }

    func getMaxWeightForExercise(_ exercise: Exercise, in sets: [ExerciseSet]) -> Float? {
        sets
            .filter { $0.exercise?.id == exercise.id }
            .compactMap { $0.weight }
            .max()
    }

    func getMaxRepsForExercise(from summaries: [ExerciseSetSummary]) -> Int? {
        summaries
            .filter { $0.exerciseSet?.exercise?.id == exercise.id }
            .compactMap { $0.repsCompleted }
            .max()
    }

    func getMaxDurationForExercise(_ exercise: Exercise, in sets: [ExerciseSet]) -> Int? {
        sets
            .filter { $0.exercise?.id == exercise.id }
            .compactMap { $0.duration }
            .max()
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    @Previewable @State var sampleExercise = Exercise.sample(id: "ex1", name: "Pushups")
    @Previewable @State var showEditSheet = false
    @Previewable @State var goalWeight: Double = 50.0
    @Previewable @State var goalReps: Int = 20
    @Previewable @State var goalDuration: Int = 90

    let sampleSummaries = [
        ExerciseSetSummary.sample(
            id: "1",
            exerciseSetID: "set1",
            workoutSummaryID: nil,
            startedAt: Date().addingTimeInterval(-86400 * 2),
            completedAt: Date().addingTimeInterval(-86400 * 2),
            timeSpentActive: 60,
            weight: 20.0,
            repsReported: 10,
            exerciseSet: ExerciseSet.sample(id: "set1", exercise: sampleExercise)
        ),
        ExerciseSetSummary.sample(
            id: "2",
            exerciseSetID: "set2",
            workoutSummaryID: nil,
            startedAt: Date().addingTimeInterval(-86400),
            completedAt: Date().addingTimeInterval(-86400),
            timeSpentActive: 60,
            weight: 25.0,
            repsReported: 12,
            exerciseSet: ExerciseSet.sample(id: "set2", exercise: sampleExercise)
        ),
        ExerciseSetSummary.sample(
            id: "3",
            exerciseSetID: "set3",
            workoutSummaryID: nil,
            startedAt: Date(),
            completedAt: Date(),
            timeSpentActive: 60,
            weight: 30.0,
            repsReported: 15,
            exerciseSet: ExerciseSet.sample(id: "set3", exercise: sampleExercise)
        )
    ]

    return GoalGaugeSection(
        exercise: $sampleExercise,
        showEditSheet: $showEditSheet,
        exerciseSetSummaries: sampleSummaries
    )
    .preferredColorScheme(.light)
    .frame(width: 400, height: 200)
    .padding()
}

#Preview("Dark Mode") {
    @Previewable @State var sampleExercise = Exercise.sample(id: "ex1", name: "Pushups")
    @Previewable @State var showEditSheet = false
    @Previewable @State var goalWeight: Double = 50.0
    @Previewable @State var goalReps: Int = 20
    @Previewable @State var goalDuration: Int = 90

    let sampleSummaries = [
        ExerciseSetSummary.sample(
            id: "1",
            exerciseSetID: "set1",
            workoutSummaryID: nil,
            startedAt: Date().addingTimeInterval(-86400 * 2),
            completedAt: Date().addingTimeInterval(-86400 * 2),
            timeSpentActive: 60,
            weight: 20.0,
            repsReported: 10,
            exerciseSet: ExerciseSet.sample(id: "set1", exercise: sampleExercise)
        ),
        ExerciseSetSummary.sample(
            id: "2",
            exerciseSetID: "set2",
            workoutSummaryID: nil,
            startedAt: Date().addingTimeInterval(-86400),
            completedAt: Date().addingTimeInterval(-86400),
            timeSpentActive: 60,
            weight: 25.0,
            repsReported: 12,
            exerciseSet: ExerciseSet.sample(id: "set2", exercise: sampleExercise)
        ),
        ExerciseSetSummary.sample(
            id: "3",
            exerciseSetID: "set3",
            workoutSummaryID: nil,
            startedAt: Date(),
            completedAt: Date(),
            timeSpentActive: 60,
            weight: 30.0,
            repsReported: 15,
            exerciseSet: ExerciseSet.sample(id: "set3", exercise: sampleExercise)
        )
    ]

    return GoalGaugeSection(
        exercise: $sampleExercise,
        showEditSheet: $showEditSheet,
        exerciseSetSummaries: sampleSummaries
    )
    .preferredColorScheme(.dark)
    .frame(width: 400, height: 200)
    .padding()
}
