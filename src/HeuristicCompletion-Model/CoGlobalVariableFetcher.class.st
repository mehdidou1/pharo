"
I am a fetcher looking for globals in an environment.
"
Class {
	#name : 'CoGlobalVariableFetcher',
	#superclass : 'CoGlobalFetcher',
	#instVars : [
		'completionClass'
	],
	#category : 'HeuristicCompletion-Model-Fetchers',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Fetchers'
}

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> completionClass: aClass [
	completionClass := aClass
]

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> entriesDo: aBlock [

	self systemNavigation
		allGlobalNamesStartingWith: filter completionString
		do: [ :e |
				aBlock value: ((CoGlobalEntry contents: e node: astNode)
						 fetcherName: self class name;
						 yourself) ]
		caseSensitive: NECPreferences caseSensitive
]

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> inferPrefix [ 
	| prefixes |
	prefixes := Dictionary new.
	completionClass package definedClasses do: [ :cls | 
			|prefix|
		prefix := self inferPrefixFromClass: cls name. 
			prefix = '' 
				ifFalse: [ prefixes at: prefix put: (( prefixes at: prefix ifAbsent: [ 0 ] ) + 1)]
		 ]
]

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> inferPrefixFromClass: aClassName [
    | seenLowercase |
    seenLowercase := false.

    1 to: aClassName size do: [ :index |
        | char |
        char := aClassName at: index.

        char isLowercase ifTrue: [
            seenLowercase := true
        ].

        (char isUppercase and: [ seenLowercase and: [ index > 1 ] ]) ifTrue: [
            ^ aClassName copyFrom: 1 to: index - 1
        ].
    ].

    ^ ''
]
