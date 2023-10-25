# LepiterBuildingBlocs

A collection of community-built tools and utilities to add additional functionality & super-powers to Lepiter snippets & pages in [Glamorous Toolkit](https://gtoolkit.com/).

# Installation

```Smalltalk
[ EpMonitor current	disableDuring: [ Metacello new			baseline: 'LepiterBuildingBlocs';			repository: 'github://botwhytho/LepiterBuildingBlocs:main/src';			load ] ] forkAt: 29 named: #LepiterBuildingBlocs
```

To depend on this package add this to your baseline:
```Smalltalk
spec baseline: 'LepiterBuildingBlocs' with: [spec repository: 'github://botwhytho/LepiterBuildingBlocs:main/src']
```

# Usage

For now, add an `Element` snippet to a Lepiter page and run any of the commands below:
- `LepiterBuildingBlocs runSnippets`
  - This will add a UI that can run multiple snippets in a background process, sequentially, in the order they appear on the page. Good for when prototyping and you change the first snippet in a list and want to re-run sibling/child snippets. Also GREAT for when you have long-running snippets, even if just one, as this runs the code in the background so you can continue working in other tabs, inspectors, etc.
- `LepiterBuildingBlocs template`
  - This will add a simple UI that can clone the current page, thus turning it into a sort of template.
- `LepiterBuildingBlocs fileSelector`
  - This will add a `BrFileSelector` element that binds it's currently selected folder to a shared variable that can be used from other snippets. The variable name can be changed. This snippet is stateful and will serialize the new values once you change the folder or the variable name. These values will persist past a gtoolkit restart or upgrade.

More building blocks coming soon!
