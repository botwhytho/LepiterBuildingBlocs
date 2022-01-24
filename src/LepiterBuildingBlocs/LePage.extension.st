Extension { #name : #LePage }

{ #category : #'*LepiterBuildingBlocs' }
LePage >> duplicatePageWithNewName: aTitleString [

	| newPage uuidMapping |
	uuidMapping := Dictionary new.
	newPage := LePage named: aTitleString.
	self database addPage: newPage.
	self
		deep: [ :parent | parent children children ]
		do: [ :each |  ]
		relationDo: [ :from :to | 
			| attributesReloader newSnippet |
			newSnippet := to class new.
			uuidMapping at: to uid put: newSnippet.
			attributesReloader := LeContentAttributesReloader forContent: newSnippet.
			attributesReloader
				updateForMappings: attributesReloader relevantAttributeMappings
				fromContent: to.
			(from isKindOf: LePage)
				ifTrue: [ newPage addSnippet: newSnippet ]
				ifFalse: [ 
					| parentSnippet |
					parentSnippet := uuidMapping at: from uid.
					parentSnippet children children isEmpty
						ifTrue: [ parentSnippet addFirstSnippet: newSnippet ]
						ifFalse: [ parentSnippet addSnippet: newSnippet ] ] ].
	^ newPage
]
