//
//  ContentView.swift
//  Word Scramble
//
//  Created by Myat Thu Ko on 5/17/20.
//  Copyright © 2020 Myat Thu Ko. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var totalCount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.orange, .yellow, .pink]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.vertical)
                    .overlay(
                        VStack {
                            TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(10)
                                .autocapitalization(.none)
                            
                            List(usedWords, id: \.self) {
                                Image(systemName: "\($0.count).circle")
                                Text($0)
                            }
                        .padding(10)
                        }
                )
                    .navigationBarTitle(rootWord)
                    .navigationBarItems(leading:
                        HStack(spacing: 150){
                            Button(action: startGame) {
                                Text("Restart")
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .border(Color.black, width: 5)
                            }
                            Text("Total Score: \(totalCount)")
                        })
                    .onAppear(perform: startGame)
                    .alert(isPresented: $showError) {
                        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original...")
            return 
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recorgnized", message: "You can't just make them up, you know...")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not real", message: "This is not a real word...")
            return 
        }
        
        totalCount += newWord.count
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        
        newWord = ""
        totalCount = 0
        usedWords = [String]()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("There is an error loading start.txt.")
    }
    
    func isOriginal(word: String) -> Bool {
        var original = true
        
        if (usedWords.contains(word) || word == rootWord) {
            original = false
        }
        
        return original
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
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
        
        var isValid = true
        var isLessThan3 = false
        if word.count < 2 {
            isLessThan3 = true
        }
        
        if (misspelledRange.location != NSNotFound || isLessThan3 == true) {
            isValid = false
        }
        
        return isValid
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
