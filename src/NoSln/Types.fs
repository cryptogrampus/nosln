﻿namespace rec NoSln

open System

type Map<'K,'V> = System.Collections.Immutable.ImmutableDictionary<'K,'V>

// Simplified tree structure representing a solution file

type Solution =
    {
        id : Guid
        folders : Map<string, Folder>
        projects : Project list
    }

type Folder =
    {
        id : Guid
        name  : string
        folders : Map<string, Folder>
        projects : Project list
        files : File list
    }

type Project =
    {
        id : Guid
        name : string
        path : string // sln relative path
        fullPath : string // fully qualified filesystem path
        logicalPath : string list // logical solution path
    }

type File =
    {
        id : string
        path : string // sln relative path
        fullPath : string // fully qualified filesystem path
        logicalPath : string list // logical solution path
    }

/// NoSln configuration type

type Configuration =
    {
        baseDirectory : string
        targetSolutionFile : string
        targetSolutionDir : string

        projectIncludes : string list
        projectExcludes : string list
        fileIncludes : string list
        fileExcludes : string list        

        noFiles : bool
        includeTransitiveProjects : bool
        useAbsolutePaths : bool
        flattenProjects : bool
        start : bool
        quiet : bool
    }