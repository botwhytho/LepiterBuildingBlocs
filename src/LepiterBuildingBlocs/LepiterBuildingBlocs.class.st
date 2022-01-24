Class {
	#name : #LepiterBuildingBlocs,
	#superclass : #BlElement,
	#category : #LepiterBuildingBlocs
}

{ #category : #accessing }
LepiterBuildingBlocs class >> initialize [

	super initialize.

	(Smalltalk hasClassNamed: #GtCoderEvaluationAnnouncement) ifTrue: [ 
		| ast codeUpdated |
		ast := (GtCoderEvaluationAnnouncement
		        >> #isRequestedByElementOrItsChild:) ast.
		codeUpdated := (ast allChildren select: #isMessage) anySatisfy: [ 
			               :each | 
			               #( #coderViewModel #snippetViewModel ) includes:
				               each selector ].
		codeUpdated ifFalse: [ 
			| link |
			link := MetaLink new
				        metaObject: self;
				        selector: #isRequestedByElementOrItsChild:patch:;
				        control: #instead;
				        arguments: #( arguments #receiver ).
			ast link: link ] ]
]

{ #category : #accessing }
LepiterBuildingBlocs class >> isRequestedByElementOrItsChild: arguments patch: aReceiver [

	"Return true if the evaluation ws requested by a given visual element or any of its children"

	<return: #Boolean>
	| anElement object |
	anElement := arguments first.
	object := aReceiver.

	object requesterObject == anElement ifTrue: [ ^ true ].

	object requesterObject == anElement snippetViewModel coderViewModel 
		ifTrue: [ ^ true ].

	(object requesterObject isKindOf: BlElement) ifFalse: [ ^ false ].

	^ object requesterObject hasParent: anElement
]
