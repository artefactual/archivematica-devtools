Archivematica devtools
======================

This repository contains a set of development tools for use with the [Archivematica](http://archivematica.org/) digital preservation system.
These development tools are primarily used in debugging and developing Archivematica systems.
In the past, these tools were contained in the primary Archivematica repository; they have been split out into a separate repository to make them easier to use with packaged Archivematica installations.
While these are primarily intended for use in development, Archivematica systems administrators may find them useful in debugging Archivematica installations.

USAGE
-----

A tool called `am` is provided as a launcher for the different tools in this package. To call a tool, run `am toolname`, e.g. `am linktool`.
All of the available tools can be listed by running `am ls-tools`.
More detailed documentation is available in the `am` manpage.
Manpages are available for certain tools provided in this package as well.

REQUIREMENTS
------------

### Build

* [ronn](http://rtomayko.github.io/ronn/) (installed via Rubygems, or ruby-ronn in Ubuntu/Debian)

### Runtime

* Python 2.7
* Active Archivematica installation with an installed, accessible database

INSTALLATION
------------

A makefile is provided; `make install` will build the package and install to /usr/local.
The prefix can be customized by passing the `PREFIX` make variable (for instance, `make install PREFIX=/opt/archivematica`), and the tool installation directory can be changed by passing the `libexecdir` make variable.

TOOLS PROVIDED
--------------

* linktool: Assists in generating SQL to create new microservice chainlinks, or to access information about links in the database.
* graph-links: Generate a graph of all microservice chainlinks in an Archivematica database.
* create-many-transfers: Stress test an Archivematica instance by starting many transfers at once.
* extract-mets-files-from-aips: Extract METS files from all AIPs in a given path.
* gearman-info: Lists all running Gearman workers.
* mcp-rpc-cli: Simple commandline interface to monitor running Archivematica tasks and select processing choices.
* rebuild-elasticsearch tools: Various tools to rebuild specific Elasticsearch indices.
* reindex-aip-data: Delete and recreate the AIP index, reindexing all existing records.
  This can be used to migrate data when an incompatible schema change occurs.
* reindex-backlogged-transfers: Seeds the Storage Service with information about all transfers in the transfer backlog.
* stress-test-aip-indexing: Stress test Elasticsearch AIP indexing by repeatedly indexing test data.
* sword-diagnose: Attempt to detect any issues in AtoM/SWORD configuration when setting up DIP upload to an AtoM instance.

### graph-links

graph-links creates an SVG graph of the workflow in Archivematica. For more information on how this workflow is implemented, see the [MCP docs](https://wiki.archivematica.org/MCP) or the [MCP task type docs](https://wiki.archivematica.org/MCP/TaskTypes).

Each node represents one MicroServiceChainLinks entry, and points to the node that runs after it.  Nodes that are the start of a MicroServiceChain are bordered in gold, all other nodes are bordered in black. Each node contains 3 lines of information:

```
{MicroServiceChainLink.pk} TasksConfigs.description
(TaskTypes.description) TasksConfigs.taskTypePKReference
[StandardTasksConfigs.execute or TasksConfigsSetUnitVariable.variable, TasksConfigsSetUnitVariable.variableValue] MicroServiceChainLinks.microserviceGroup
```

Or, more readably:

```
{MicroServiceChainLink UUID} Name of the node
(task type description) UUID of the task-type-specific DB row
[script executed] microservice group
```

Edges are labelled with the user choice or exit code that connects those nodes, if applicable.  The edge color represents how the nodes are linked.

* Black: "normal" progress
  * Source: `MicroServiceChainLinks.pk`
  * Destination: `MicroServiceChainLinks.defaultNextChainLink` or `MicroServiceChainLinksExitCodes.nextMicroServiceChainLink`
* Red: Exit code greater than zero
  * Source: `MicroServiceChainLinksExitCodes.exitCode`
  * Destination: `MicroServiceChainLinksExitCodes.nextMicroServiceChainLink`
* Green: User selection
  * Source: `MicroServiceChainChoice.choiceAvailableAtLink`
  * Destination: `MicroServiceChains.startingLink`
* Cyan: WatchedDirectories
  * Source: `MicroServiceChainLinks.pk` where the `StandardTasksConfig` has `execute` as `move` and the watched directory path in the `arguments`
  * Destination: `WatchedDirectories.chain`
* Orange: Unit variables
  * Source: `MicroServiceChainLinks.pk` where taskType is 'linkTaskManagerUnitVariableLinkPull' (`c42184a3-1a7f-4c4d-b380-15d8d97fdd11`)
  * Destination: `TasksConfigsUnitVariableLinkPull.variableValue` or `TasksConfigsUnitVariableLinkPull.defaultMicroServiceChainLink`.  The variable name and value is printed in the node that set it.
* Brown: Magic Links
  * Source: `MicroServiceChainLinks.pk` where taskType is 'goto magic link' (`6fe259c2-459d-4d4b-81a4-1b9daf7ee2e9`)
  * Destination: `Transfer.magicLink`. This is set by the most recent 'assign magic link' (`3590f73d-5eb0-44a0-91a6-5b2db6655889`)
