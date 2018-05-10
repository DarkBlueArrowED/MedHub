//
//  MedInfoFilter.swift
//  Medical Hub
//
//  Created by Walter Bassage on 27/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import Foundation


class MedInfoFilter {
    
    
    let medInfoCollection: MedInfoCollection?
    
    var filteredMedData = [String]()
    
    var wordSets = [String: Set<String>]()
    var languages = [String: String]()
    
    var searchString = "" {
        didSet {
            
            if searchString == "" {
                filteredMedData = self.medInfoCollection!.medData!
            }else{
                extractWordSetsAndLanguages()
                filterMedData()
            }
            
        }
    }
    
    
    init(medInfoCollection: MedInfoCollection?) {
        self.medInfoCollection = medInfoCollection
        
    }
    
    
    fileprivate func setOfWords(string: String, language: inout String?) -> Set<String> {
        var wordSet = Set<String>()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .language], options: 0)
        let range = NSRange(location: 0, length: string.utf16.count)
        
        tagger.string = string
        
        if let language = language {
            let orthography = NSOrthography.defaultOrthography(forLanguage: language)
            tagger.setOrthography(orthography, range: range)
        }else{
            language = tagger.dominantLanguage
        }
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitWhitespace, .omitPunctuation]){
            tag, tokenRange, _ in
            
            let token = (string as NSString).substring(with: tokenRange)
            wordSet.insert(token.lowercased())
            
            if let lemma = tag?.rawValue {
                wordSet.insert(lemma.lowercased())
            }
            
        }
        
        return wordSet
    }
    
    fileprivate func extractWordSetsAndLanguages() {
        var newWordSets = [String: Set<String>]()
        var newLanguages = [String: String]()
        
        
        if let medData = medInfoCollection?.medData {
            for entry in medData {
                if let wordSet = wordSets[entry] {
                    
                    newWordSets[entry] = wordSet
                    newLanguages[entry] = languages[entry]
                } else {
                    
                    var language: String?
                    let wordSet = setOfWords(string: entry, language: &language)
                    newWordSets[entry] = wordSet
                    newLanguages[entry] = language
                }
            }
        }
        
        wordSets = newWordSets
        languages = newLanguages
    }
    
    fileprivate func filterMedData() {
        var language: String?
        var filterSet = setOfWords(string: searchString, language: &language)
        
        for existingLanguage in Set<String>(languages.values) {
            
            language = existingLanguage
            filterSet = filterSet.union(setOfWords(string: searchString, language: &language))
        }
        
        filteredMedData.removeAll()
        
        if let medData = medInfoCollection?.medData {
            if filterSet.isEmpty {
                filteredMedData.append(contentsOf: medData)
            } else {
                for medInfo in medData {
                    
                    guard let wordSet = wordSets[medInfo], !wordSet.intersection(filterSet).isEmpty else { continue }
                    filteredMedData.append(medInfo)
                }
            }
        }
        
        
    }
    
}
