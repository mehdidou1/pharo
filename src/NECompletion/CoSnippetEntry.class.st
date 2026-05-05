Class {
	#name : 'CoSnippetEntry',
	#superclass : 'CoEntry',
	#category : 'NECompletion-Model',
	#package : 'NECompletion',
	#tag : 'Model'
}

{ #category : 'private' }
CoSnippetEntry >> browseCompletionItem [
	self
]

{ #category : 'accessing' }
CoSnippetEntry >> createDescription [
	
	^ CoEntryDescription 
		label: 'Snippet replacement' title: (self propertyAt: #shortString) , ' into ' description: self contents
]

{ #category : 'accessing' }
CoSnippetEntry >> rawLabel [
	^ 'snippet'
]

{ #category : 'private' }
CoSnippetEntry >> shortString: aString [ 
	
	self propertyAt: #shortString put: aString
]
