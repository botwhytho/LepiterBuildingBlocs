Extension { #name : #BrGlamorousVectorIcons }

{ #category : #'*LepiterBuildingBlocs' }
BrGlamorousVectorIcons class >> noteCopy [
	| noteOutline noteContent |
	noteOutline := [ BlElement new
			size: 16 @ 16;
			outskirts: BlOutskirts centered;
			geometry: (BlSvgPath new
					svg: 'M 15 5.1426 C 15 3.81638 14.8222 3.6523 13.52342 2.3398 L 13.5097 2.32622 C 12.20406 1 12.19048 1 10.85054 1 C 9.06638 1 1 1 1 1 L 1 15 L 15 15 L 15 5.1426 Z M 15 5.07428 C 15 3.81638 14.98628 3.81638 12.19048 3.81638 L 12.19048 3.81638 C 12.19048 1.01372 12.19048 1 10.93258 1'
					viewbox: (0 @ 0 extent: 16 @ 16));
			border: (BlBorder builder
					paint: Color black;
					width: 1;
					capRound;
					build) ] asStencil.
	noteContent := [ BlElement new
			size: 16 @ 16;
			geometry: (BlSvgPath new
					svg: 'M 5 4 L 11 4 M 5 6 L 11 6 M 5 8 L 11 8 M 5 10 L 11 10 M 5 12 L 11 12'
					viewbox: (0 @ 0 extent: 16 @ 16));
			outskirts: BlOutskirts centered;
			border: (BlBorder builder
					paint: Color black;
					width: 0.5;
					capSquare;
					joinRound;
					build) ] asStencil.

	^ [ BlElement new
		size: 21 @ 21;
		addChildren: {noteOutline asElement.
				noteOutline asElement
					background: Color white;
					transformDo: [ :t | t translateBy: 5 @ 5 ].
				noteContent asElement transformDo: [ :t | t translateBy: 5 @ 5 ]} ]
		asStencil
]
