//
//  WeightProgressChart.swift
//  Workout
//
//  Created by Sarah Clark on 2/22/25.
//

// WeightProgressChart.swift
import Charts
import SwiftUI

struct WeightProgressChart: View {
    let exerciseSetSummaries: [ExerciseSetSummary]
    let exerciseName: String

    private var weightData: [(date: Date, value: Double)] {
        exerciseSetSummaries
            .filter { $0.exerciseSet?.exercise?.name == exerciseName }
            .compactMap { summary -> (date: Date, value: Double)? in // Explicitly specify return type as optional tuple
                guard let date = summary.completedAt ?? summary.startedAt else { return nil }
                guard let weightFloat = summary.weightUsed ?? summary.exerciseSet?.weight else { return nil }
                guard let weight = weightFloat.doubleValue else { return nil }
                return (date: date, value: Double(weight))
            }
            .sorted { $0.date < $1.date } // Sort by date
    }

    var body: some View {
        if !weightData.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Weight Progress (lbs)")
                    .font(.headline)
                    .padding(.horizontal)

                Chart {
                    ForEach(weightData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Weight", dataPoint.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .symbol(Circle())
                        .symbolSize(30)
                        .foregroundStyle(Gradient(colors: [.red, .red.opacity(0.5)]))

                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Weight", dataPoint.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Gradient(colors: [.red.opacity(0.2), .red.opacity(0.05)]))
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...maxValue(weightData))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))")
                            }
                        }
                    }
                }
                .padding()
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }

    private func maxValue(_ data: [(date: Date, value: Double)]) -> Double {
        data.map { $0.value }.max() ?? 100.0 // Default to 100 if no data
    }
}

// MARK: - Previews for WeightProgressChart
#Preview("Light Mode") {
    let sampleExercise = Exercise.sample(id: "ex1", name: "Pushups")
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
    WeightProgressChart(exerciseSetSummaries: sampleSummaries, exerciseName: "Pushups")
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let sampleExercise = Exercise.sample(id: "ex1", name: "Pushups")
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
    WeightProgressChart(exerciseSetSummaries: sampleSummaries, exerciseName: "Pushups")
        .preferredColorScheme(.dark)
}
