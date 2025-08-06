import SwiftUI

struct ContentView: View {
    @AppStorage("caloricGoal") private var caloricGoal: String = ""
    @AppStorage("bodyWeight") private var bodyWeight: String = ""
    @AppStorage("useMetric") private var useMetric: Bool = false

    @State private var foodCalories: String = ""
    @State private var foodProtein: String = ""

    @State private var result: String = ""
    @State private var rangeText: String = ""

    @State private var saveMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // --- User Config Section ---
                    Text("User Configuration")
                        .font(.headline)

                    TextField("Daily Caloric Goal (kcal)", text: $caloricGoal)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Body Weight (\(useMetric ? "kg" : "lbs"))", text: $bodyWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle("Use Metric (kg)", isOn: $useMetric)

                    Button("Save Settings") {
                        saveMessage = "✅ Settings saved!"
                        hideKeyboard()
                    }
                    .padding(.top, 4)

                    if let message = saveMessage {
                        Text(message)
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    Divider().padding(.vertical)

                    // --- Food Input Section ---
                    Text("Food Item Input")
                        .font(.headline)

                    TextField("Food Calories", text: $foodCalories)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Protein (grams)", text: $foodProtein)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Evaluate Food") {
                        evaluateFood()
                        hideKeyboard()
                    }
                    .foregroundColor(.blue)
                    .padding(.top)

                    Divider().padding(.vertical)

                    // --- Result Section ---
                    Text("Can I eat it?")
                        .font(.headline)

                    if !rangeText.isEmpty {
                        Text(rangeText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Text(result)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("💪Protein Efficiency")
        }
    }

    func evaluateFood() {
        guard let goal = Double(caloricGoal), goal > 0,
              let weight = Double(bodyWeight), weight > 0,
              let foodCal = Double(foodCalories), foodCal > 0,
              let foodProt = Double(foodProtein), foodProt >= 0 else {
            result = "❌ Invalid input"
            rangeText = ""
            return
        }

        let weightInLbs = useMetric ? weight * 2.20462 : weight

        let minProtG = weightInLbs * 0.8
        let maxProtG = weightInLbs * 1.2

        let minProtCals = minProtG * 4
        let maxProtCals = maxProtG * 4

        let minPercent = minProtCals / goal
        let maxPercent = maxProtCals / goal

        let foodProtCals = foodProt * 4
        let foodPercent = foodProtCals / foodCal

        rangeText = String(format: "Target Protein: %.1f–%.1f%%", minPercent * 100, maxPercent * 100)

        if foodPercent < minPercent {
            result = "❌ Too low in protein"
        } else if foodPercent > maxPercent {
            result = "⚠️ Above recommended range"
        } else {
            result = "✅ Meets protein target"
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
