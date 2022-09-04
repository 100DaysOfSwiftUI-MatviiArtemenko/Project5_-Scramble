//
//  ContentView.swift
//  Project5_ Scramble
//
//  Created by admin on 11.08.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var rotationAmount = 0.0
    
    let color : UIColor = UIColor(red: 0.45, green: 0.5, blue: 0.89, alpha: 0.6)
    let listRowBackground = Color(red: 0.86, green: 0.72, blue: 0.56)
    let buttonColor = Color(red: 0.04, green: 0.14, blue: 0.24)
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                            TextField("Enter your word", text: $newWord)
                                .autocapitalization(.none)
                    }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).square")
                                Text(word)
                            }
                            .shadow(radius: 6, x: -3, y: 5)
                        }
                        .listRowBackground(listRowBackground)
                        .listStyle(.insetGrouped)
                    }
        
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = color
                }
            }
            .onSubmit(usedWords.count == 4 ? startNewGame : addNewWord)
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Continue"){}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                rotationAmount += 360
                            }
                            withAnimation() {
                                startGame()
                                usedWords.removeAll()
                                newWord = ""
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(Color("restartButtonColor"))
                            .rotation3DEffect(.degrees(rotationAmount), axis: (x: 0, y: 0, z: 1))
                    }
                    .shadow(radius: 1)
                }
            }
            
        }
    }
    func startNewGame() {
        if usedWords.count == 4 {
            addNewWord()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation() {
                    startGame()
                    usedWords.removeAll()
                    newWord = ""
                }
                errorTitle = "Great job!"
                errorMessage = "Lets start over one more time"
                showingError = true
            }
        }
        
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isReal(word: answer) else {
            wordError(title: "Error", message: "Not a real word")
            newWord = ""
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Error", message: "Used this word before")
                newWord = ""
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Error", message: "Could not use this word")
                newWord = ""
            return
        }
        withAnimation() {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let wordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: wordsUrl) {
                let allWords = startWord.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "elephant"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
