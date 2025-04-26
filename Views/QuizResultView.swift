//
//  QuizResultView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int

    private var badgeTitle: String {
        let percentage = Double(score) / Double(totalQuestions)
        
        switch percentage {
        case 0.9...1.0:
            return "Bible Scholar"
        case 0.7..<0.9:
            return "Faithful Reader"
        case 0.5..<0.7:
            return "Sunday School Veteran"
        case 0.2..<0.5:
            return "Growing Believer"
        default:
            return "Spiritual Amnesia"
        }
    }

    private var roastMessage: String {
        let percentage = Double(score) / Double(totalQuestions)
        
        switch percentage {
        case 0.9...1.0:
            return "You really *in* your Word. Walking commentary type energy. ✨"
        case 0.7..<0.9:
            return "You in there! Couple refreshers away from Bible beast mode. 📚"
        case 0.5..<0.7:
            return "You remember some... but them midweek classes lookin’ dusty. ⛪"
        case 0.2..<0.5:
            return "Hey, progress not perfection! Dust that Bible off, fam. 🧹"
        default:
            return "I'm not saying you forgot everything... but umm... maybe open that Bible app today. Just maybe. 🙃"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .bold()
            
            Text("Score: \(score)/\(totalQuestions)")
                .font(.title2)
                .padding(.bottom, 10)

            Text(badgeTitle)
                .font(.title)
                .bold()
                .foregroundColor(.purple)
            
            Text(roastMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: LeaderboardView()) {
                Text("View Leaderboard")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)

            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.first?.rootViewController?.dismiss(animated: true)
                }
            }) {
                Text("Play Again")
                    .padding()
            }
        }
        .padding()
        .onAppear {
            if let userID = FirebaseAuthManager.shared.userID {
                QuizScoreLogger.shared.logScore(userID: userID, score: score)
            }
        }
    }
}
