"
I am a fetcher looking for globals in an environment.
"
Class {
	#name : 'CoGlobalVariableFetcher',
	#superclass : 'CoGlobalFetcher',
	#category : 'HeuristicCompletion-Model-Fetchers',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Fetchers'
}

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> completionClass: aClass [
	"we do not use this information but other alternatives such as the CoPackageGlobalVariable needs the completion class to start with."
	
]

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> entriesDo: aBlock [
    self systemNavigation
        allGlobalNamesStartingWith: filter completionString
        do: [ :e | | prefix |
            prefix := self inferPrefixFrom: e.

            aBlock value: (
                (NECPrefixExpandableGlobalEntry
                    contents: e
                    node: astNode
                    implicitPrefix: prefix)
                        fetcherName: self class name;
                        yourself)
        ]
        caseSensitive: NECPreferences caseSensitive
]

{ #category : 'enumerating' }
CoGlobalVariableFetcher >> inferPrefixFrom: aString [
    2 to: aString size do: [ :i |
        (aString at: i) isUppercase ifTrue: [
            ^ aString copyFrom: 1 to: i - 1
        ]
    ].
    ^ ''
]
