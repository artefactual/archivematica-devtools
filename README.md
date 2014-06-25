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
* rebuild-elasticsearch tools: Various tools to rebuild specific Elasticsearch indices.
* stress-test-aip-indexing: Stress test Elasticsearch AIP indexing by repeatedly indexing test data.
* sword-diagnose: Attempt to detect any issues in AtoM/SWORD configuration when setting up DIP upload to an AtoM instance.
