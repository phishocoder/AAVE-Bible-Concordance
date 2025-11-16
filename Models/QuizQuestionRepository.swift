import Foundation

/// Single source of truth for the “Who Said That?!” quiz.
final class QuizQuestionRepository {
    static let shared = QuizQuestionRepository()
    
    private let questions: [QuizQuestion]
    private var lastSelectionIDs: [UUID] = []
    
    private init() {
        self.questions = QuizQuestionRepository.buildQuestionBank()
    }
    
    func fetchRandomQuestions(count: Int) -> [QuizQuestion] {
        let actualCount = min(count, questions.count)
        guard actualCount > 0 else { return [] }
        
        var shuffled = questions.shuffled()
        var attempts = 0
        while attempts < 5 && shuffled.prefix(actualCount).map(\.id) == lastSelectionIDs {
            shuffled.shuffle()
            attempts += 1
        }
        
        let selection = Array(shuffled.prefix(actualCount))
        lastSelectionIDs = selection.map(\.id)
        return selection
    }
}

private extension QuizQuestionRepository {
    static func buildQuestionBank() -> [QuizQuestion] {
        let raw: [(quote: String, options: [String], correctIndex: Int, reference: String)] = [
            // ORIGINAL SET
            ("Am I my brother's keeper?", ["Cain", "Abel", "Seth", "Noah"], 0, "Genesis 4:9"),
            ("As for me and my house, we will serve the Lord.", ["Joshua", "Moses", "David", "Elijah"], 0, "Joshua 24:15"),
            ("The Lord is my shepherd; I shall not want.", ["David", "Asaph", "Solomon", "Isaiah"], 0, "Psalm 23:1"),
            ("You must be born again.", ["Jesus", "John the Baptist", "Peter", "Paul"], 0, "John 3:7"),
            ("I can do all things through Christ who strengthens me.", ["Paul", "Peter", "James", "John"], 0, "Philippians 4:13"),
            ("Unless I see the nail marks... I will not believe.", ["Thomas", "Peter", "Andrew", "Philip"], 0, "John 20:25"),
            ("Throw me into the sea and it will become calm.", ["Jonah", "Paul", "Peter", "Noah"], 0, "Jonah 1:12"),
            ("Here am I! Send me.", ["Isaiah", "Samuel", "Moses", "Jeremiah"], 0, "Isaiah 6:8"),
            ("Speak, Lord, for your servant is listening.", ["Samuel", "David", "Elisha", "Gideon"], 0, "1 Samuel 3:10"),
            ("If I perish, I perish.", ["Esther", "Ruth", "Deborah", "Mary"], 0, "Esther 4:16"),
            ("Choose this day whom you will serve.", ["Joshua", "Moses", "Nehemiah", "Ezra"], 0, "Joshua 24:15"),
            ("What you meant for evil, God meant for good.", ["Joseph", "Daniel", "Job", "Mordecai"], 0, "Genesis 50:20"),
            ("Lord, to whom shall we go? You have the words of life.", ["Peter", "John", "James", "Andrew"], 0, "John 6:68"),
            ("I am the voice of one crying in the wilderness.", ["John the Baptist", "Isaiah", "Elijah", "Micah"], 0, "John 1:23"),
            ("We ought to obey God rather than men.", ["Peter", "Paul", "Stephen", "Barnabas"], 0, "Acts 5:29"),
            ("My Lord and my God!", ["Thomas", "Peter", "Mary Magdalene", "James"], 0, "John 20:28"),
            ("Let us rise up and build.", ["Nehemiah", "Ezra", "Zerubbabel", "Haggai"], 0, "Nehemiah 2:18"),
            ("If I have found favor, let me test the fleece once more.", ["Gideon", "Samson", "Jephthah", "Saul"], 0, "Judges 6:39"),
            ("Our God is able to deliver us... but even if he does not, we will not bow.", ["Shadrach, Meshach, and Abednego", "Daniel", "Mordecai", "Elijah"], 0, "Daniel 3:17-18"),
            ("Your people shall be my people, and your God my God.", ["Ruth", "Esther", "Hannah", "Mary"], 0, "Ruth 1:16"),
            ("I am the Lord's servant. May it be to me as you have said.", ["Mary", "Elizabeth", "Anna", "Martha"], 0, "Luke 1:38"),
            ("Silver and gold have I none, but what I do have I give you.", ["Peter", "Paul", "Stephen", "Philip"], 0, "Acts 3:6"),
            ("Man shall not live by bread alone.", ["Jesus", "Moses", "Elijah", "Isaiah"], 0, "Matthew 4:4"),
            ("Lord, open his eyes so he may see.", ["Elisha", "Elijah", "Samuel", "Nathan"], 0, "2 Kings 6:17"),
            ("I am doing a great work and cannot come down.", ["Nehemiah", "Ezra", "Moses", "Paul"], 0, "Nehemiah 6:3"),
            ("Give me this mountain!", ["Caleb", "Joshua", "Gideon", "Barak"], 0, "Joshua 14:12"),
            ("My heart and flesh may fail, but God is the strength of my heart.", ["Asaph", "David", "Habakkuk", "Jeremiah"], 0, "Psalm 73:26"),
            ("I know that my Redeemer lives.", ["Job", "David", "Isaiah", "Paul"], 0, "Job 19:25"),
            ("Let everything that has breath praise the Lord!", ["David", "Asaph", "Jehoshaphat", "Hezekiah"], 0, "Psalm 150:6"),
            ("Lord, if it's really you, tell me to come to you, walking on the water.", ["Peter", "Andrew", "Philip", "Thomas"], 0, "Matthew 14:28"),
            ("Don't urge me to leave you or turn back from following you.", ["Ruth", "Naomi", "Orpah", "Esther"], 0, "Ruth 1:16"),
            
            // 50-QUESTION EXPANSION
            ("The Lord will fight for you; you need only to be still.", ["Moses", "Joshua", "Aaron", "Samuel"], 0, "Exodus 14:14"),
            ("But as for you, be strong and do not give up.", ["Azariah", "Ezra", "Nehemiah", "Hezekiah"], 0, "2 Chronicles 15:7"),
            ("Here I am; you called me.", ["Samuel", "Gideon", "Jacob", "Isaiah"], 0, "1 Samuel 3:5"),
            ("Create in me a clean heart, O God.", ["David", "Solomon", "Asaph", "Ethan"], 0, "Psalm 51:10"),
            ("Let me die with the Philistines!", ["Samson", "Saul", "David", "Jephthah"], 0, "Judges 16:30"),
            ("Speak now, for your servant has heard.", ["Samuel", "Elijah", "Elisha", "Jeremiah"], 0, "1 Samuel 3:10"),
            ("Who am I, Lord God, and what is my family?", ["David", "Solomon", "Gideon", "Samuel"], 0, "1 Chronicles 17:16"),
            ("The Lord gave, and the Lord has taken away.", ["Job", "David", "Noah", "Moses"], 0, "Job 1:21"),
            ("How long will you waver between two opinions?", ["Elijah", "Elisha", "Nathan", "Micah"], 0, "1 Kings 18:21"),
            ("Here I am; you may send me to the king.", ["Nehemiah", "Ezra", "Daniel", "Mordecai"], 0, "Nehemiah 2:5"),
            ("I am not eloquent... I am slow of speech.", ["Moses", "Jeremiah", "Ezekiel", "Amos"], 0, "Exodus 4:10"),
            ("As for you, you meant evil against me, but God meant it for good.", ["Joseph", "Daniel", "Job", "Mordecai"], 0, "Genesis 50:20"),
            ("I will go out and fight this Philistine.", ["David", "Jonathan", "Samson", "Saul"], 0, "1 Samuel 17:32"),
            ("Don't call me Naomi... call me Mara.", ["Naomi", "Ruth", "Orpah", "Esther"], 0, "Ruth 1:20"),
            ("Where you go, I will go.", ["Ruth", "Esther", "Naomi", "Hannah"], 0, "Ruth 1:16"),
            ("Let us test and examine our ways.", ["Jeremiah", "Habakkuk", "Daniel", "Micah"], 0, "Lamentations 3:40"),
            ("I am the God of your father.", ["God (to Moses)", "Elijah", "Isaiah", "Jacob"], 0, "Exodus 3:6"),
            ("Do not be afraid; am I in the place of God?", ["Joseph", "Daniel", "Moses", "Jacob"], 0, "Genesis 50:19"),
            ("Give your servant a discerning heart.", ["Solomon", "David", "Samuel", "Hezekiah"], 0, "1 Kings 3:9"),
            ("But as for me, my feet had almost slipped.", ["Asaph", "David", "Solomon", "Job"], 0, "Psalm 73:2"),
            ("Whom shall I send?", ["God (to Isaiah)", "Elijah", "Jeremiah", "Samuel"], 0, "Isaiah 6:8"),
            ("Do not let your hearts be troubled.", ["Jesus", "Peter", "John", "James"], 0, "John 14:1"),
            ("I am not ashamed of the gospel.", ["Paul", "Peter", "James", "Silas"], 0, "Romans 1:16"),
            ("Lord, increase our faith!", ["The apostles", "Peter", "Paul", "Thomas"], 0, "Luke 17:5"),
            ("What is truth?", ["Pilate", "Herod", "Caiaphas", "Nicodemus"], 0, "John 18:38"),
            ("My soul magnifies the Lord.", ["Mary", "Elizabeth", "Anna", "Martha"], 0, "Luke 1:46"),
            ("Salvation belongs to the Lord!", ["Jonah", "David", "Moses", "Elijah"], 0, "Jonah 2:9"),
            ("I am innocent of this man's blood.", ["Pilate", "Herod", "Caiaphas", "Judas"], 0, "Matthew 27:24"),
            ("What shall we do, brothers?", ["The crowd at Pentecost", "Disciples", "Pharisees", "Sadducees"], 0, "Acts 2:37"),
            ("Your sins are forgiven.", ["Jesus", "Peter", "Paul", "John"], 0, "Luke 7:48"),
            ("Surely this man was the Son of God!", ["Roman centurion", "Peter", "Joseph of Arimathea", "Pilate"], 0, "Mark 15:39"),
            ("My grace is sufficient for you.", ["God (to Paul)", "Jesus", "Peter", "Gabriel"], 0, "2 Corinthians 12:9"),
            ("Lord, teach us to pray.", ["The disciples", "Peter", "James", "John"], 0, "Luke 11:1"),
            ("Repent, for the kingdom of heaven is near.", ["John the Baptist", "Jesus", "Peter", "Paul"], 0, "Matthew 3:2"),
            ("Here am I; you called me. What do you want?", ["Samuel", "Jacob", "Moses", "Gideon"], 0, "1 Samuel 3:8"),
            ("Lord, remember me when You come into Your kingdom.", ["Thief on the cross", "Peter", "John", "Thomas"], 0, "Luke 23:42"),
            ("Why have you deceived me?", ["Jacob", "Esau", "Laban", "Abraham"], 0, "Genesis 29:25"),
            ("How can this be?", ["Mary", "Sarah", "Rebecca", "Hannah"], 0, "Luke 1:34"),
            ("Lord, I believe; help my unbelief!", ["Father of the possessed boy", "Peter", "Thomas", "Paul"], 0, "Mark 9:24"),
            ("Come now, let us reason together.", ["God (through Isaiah)", "Jeremiah", "Ezekiel", "Micah"], 0, "Isaiah 1:18"),
            ("Speak to the rock before their eyes.", ["God (to Moses)", "Aaron", "Joshua", "Samuel"], 0, "Numbers 20:8"),
            ("You are the man!", ["Nathan", "Samuel", "Elijah", "John the Baptist"], 0, "2 Samuel 12:7"),
            ("I am the bread of life.", ["Jesus", "Peter", "John", "Paul"], 0, "John 6:35"),
            ("Lord, save me!", ["Peter", "Jonah", "David", "Paul"], 0, "Matthew 14:30"),
            ("My punishment is more than I can bear.", ["Cain", "Esau", "Saul", "Ahab"], 0, "Genesis 4:13"),
            ("He must become greater; I must become less.", ["John the Baptist", "Peter", "Paul", "Andrew"], 0, "John 3:30"),
            ("What is this you have done?", ["God (to Eve)", "Adam", "Cain", "Abel"], 0, "Genesis 3:13"),
            ("I am about to go the way of all the earth.", ["David", "Joshua", "Solomon", "Moses"], 0, "1 Kings 2:2"),
            ("Truly this is the Prophet who is to come into the world.", ["The crowd", "Peter", "Andrew", "Nicodemus"], 0, "John 6:14"),
            ("Lord, if You are willing, You can make me clean.", ["Leper", "Blind man", "Centurion", "Bartimaeus"], 0, "Matthew 8:2")
        ]
        
        return raw.map {
            QuizQuestion(
                quote: $0.quote,
                options: $0.options,
                correctIndex: $0.correctIndex,
                reference: $0.reference
            )
        }
    }
}
