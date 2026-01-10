import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            OnboardingTokens.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                headerRow
                progressDots

                ScrollView {
                    VStack(spacing: 16) {
                        contentCard
                    }
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                }

                navigationRow
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    private var headerRow: some View {
        HStack {
            Spacer()
            if viewModel.currentStep == .welcome {
                Button("Skip") {
                    viewModel.completeOnboarding()
                    isPresented = false
                }
                .font(.subheadline)
                .foregroundStyle(OnboardingTokens.secondaryText)
                .padding(.trailing, 20)
            }
        }
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.steps.count, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.stepIndex ? OnboardingTokens.accent : Color.white.opacity(0.2))
                    .frame(width: index == viewModel.stepIndex ? 22 : 8, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.stepIndex)
            }
        }
        .padding(.horizontal, 20)
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.currentStep.title)
                .font(.title2)
                .fontWeight(.semibold)

            switch viewModel.currentStep {
            case .welcome:
                welcomeStep
            case .vibe:
                vibeStep
            case .tone:
                toneStep
            case .nudge:
                nudgeStep
            }
        }
        .homeCard()
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scripture in our voice. Real talk, no fluff.")
                .font(.body)
                .foregroundStyle(OnboardingTokens.secondaryText)

            Text("This space is for every background. Baptist, Pentecostal, Catholic, non-denom, deconstructing, or spiritual but not religious. You are welcome here.")
                .font(.body)
                .foregroundStyle(OnboardingTokens.secondaryText)
        }
    }

    private var vibeStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick the one that fits right now. You can change it later.")
                .font(.body)
                .foregroundStyle(OnboardingTokens.secondaryText)

            VStack(spacing: 10) {
                ForEach(FaithVibe.allCases) { vibe in
                    selectButton(
                        title: vibe.rawValue,
                        isSelected: viewModel.selectedVibe == vibe
                    ) {
                        viewModel.selectedVibe = vibe
                    }
                }
            }

            if let selected = viewModel.selectedVibe {
                Text(selected.welcomeCopy)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
            }
        }
    }

    private var toneStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("We can keep it light, go deep, or mix both.")
                .font(.body)
                .foregroundStyle(OnboardingTokens.secondaryText)

            VStack(spacing: 10) {
                ForEach(TonePreference.allCases) { tone in
                    selectButton(
                        title: tone.rawValue,
                        isSelected: viewModel.selectedTone == tone
                    ) {
                        viewModel.selectedTone = tone
                    }
                }
            }
        }
    }

    private var nudgeStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("A quick daily verse can keep the rhythm going.")
                .font(.body)
                .foregroundStyle(OnboardingTokens.secondaryText)

            VStack(spacing: 10) {
                selectButton(
                    title: "Enable notifications",
                    isSelected: viewModel.wantsNudge
                ) {
                    viewModel.wantsNudge = true
                }

                selectButton(
                    title: "Not right now",
                    isSelected: !viewModel.wantsNudge
                ) {
                    viewModel.wantsNudge = false
                }
            }
        }
    }

    private var navigationRow: some View {
        HStack {
            if viewModel.stepIndex > 0 {
                Button("Back") {
                    viewModel.goBack()
                }
                .font(.subheadline)
                .foregroundStyle(OnboardingTokens.secondaryText)
            }

            Spacer()

            Button(viewModel.stepIndex == viewModel.steps.count - 1 ? "Finish" : "Next") {
                if viewModel.stepIndex == viewModel.steps.count - 1 {
                    viewModel.completeOnboarding()
                    isPresented = false
                } else {
                    viewModel.goNext()
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(viewModel.canContinue ? OnboardingTokens.accent : Color.gray.opacity(0.4))
            )
            .disabled(!viewModel.canContinue)
        }
        .padding(.horizontal, 24)
    }

    private func selectButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? OnboardingTokens.accent : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(OnboardingTokens.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingFlowView(isPresented: .constant(true))
}
