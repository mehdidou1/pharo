"
By default I do not nothing. I'm the NullObject of the fetcher hierarchy.
"
Class {
	#name : 'CoEmptyFetcher',
	#superclass : 'CoFetcher',
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'enumerating' }
CoEmptyFetcher >> entriesDo: aBlock [

	"Nothing"
]

{ #category : 'enumerating' }
CoEmptyFetcher >> fuzzyEntriesDo: aBlock [

	self entriesDo: aBlock
]

{ #category : 'testing' }
CoEmptyFetcher >> isEmptyCompletionFetcher [

	^ true
]
