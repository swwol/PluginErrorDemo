# MSPlugins

Local Swift Package Manager plugins.

## SwiftGen plugin

This is a variant of https://github.com/SwiftGen/SwiftGenPlugin that has been modified to support being used in Xcode projects

Included a bundled template MS-flat-swift5.stencil that makes the strings generated in the target an extension of an existing L10n enum rather than a new one. 

### example .yml:

```
output_dir: ${DERIVED_SOURCES_DIR}

 strings:
   inputs:
     - Localizable.strings
   outputs:
     - templateName: MS-flat-swift5
       output: Strings.generated.swift
       params:
         extends: MSStrings.L10n
```

## SwiftyMocky plugin

runs SwiftyMocky on target. 
Any package that you want to run this plugin on should have a file called 'swiftyMocky.yml' at its root

see readme in SwiftyMockyPlugin folder for info

## SwiftLint plugin

runs SwiftLint on all targets in package or Xcode project. 
But only lints modified files

see readme in SwiftLintPlugin folder for info
