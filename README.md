# LepiterBuildingBlocs

A collection of community-built tools and utilities to add additional functionality & super-powers to Lepiter snippets & pages in [Glamorous Toolkit](https://gtoolkit.com/).

# Installation

```Smalltalk
Metacello new
    baseline: 'LepiterBuildingBlocs';
    repository: 'github://botwhytho/LepiterBuildingBlocs:main/src';
    load.
```

# Usage

For now, add an `Element` snippet to a Lepiter page and run either of the two commands below:
- `LepiterBuildingBlocs fileSelector`
  - This will add a `BrFileSelector` element that binds it's currently selected folder to a shared variable that can be used from other snippets. The variable name can be changed.
- `LepiterBuildingBlocs template`
  - Adds a simple UI that can clone the current page, thus turning it into a sort of template.

More building blocks coming soon!
