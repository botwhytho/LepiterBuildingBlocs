Class {
	#name : #BaselineOfLepiterBuildingBlocs,
	#superclass : #BaselineOf,
	#category : #BaselineOfLepiterBuildingBlocs
}

{ #category : #baseline }
BaselineOfLepiterBuildingBlocs >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'LepiterBuildingBlocs' ]
]
