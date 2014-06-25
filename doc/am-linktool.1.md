linktool(1) -- Insert new tasks in an Archivematica database
============================================================

## SYNOPSIS

linktool <command> [<args>]

## DESCRIPTION

linktool automates the process of creating new tasks in an Archivematica database.
Given a few pieces of information, it generates SQL statements which can be executed directly or added to one of Archivematica's mysql_dev files.
This is useful in development.

linktool ordinarily operates in an interactive mode, and prompts for additional information after being invoked with a command.
For non-interactive use, it's possible to pipe in newline-delimited data via stdin.

linktool outputs the generated SQL to stdout.

Note that generated SQL is intended for use with MySQL (the target database for Archivematica) and may not be compatible with other SQL databases.

## REQUIREMENTS

linktool requires an Archivematica database and an Archivematica installation to function.

## COMMANDS

  * `insertbefore`:
    Insert a new link before an existing link.

  * `insertafter`:
    Insert a new link before an existing link.

  * `linkfromjob`:
    Use task UUID to look up corresponding link's UUID.

  * `linkfromtask`:
    Use task UUID to look up corresponding link's UUID.

  * `info`:
    Show other links in the same microservice group.

  * `chaininfo`:
    Show other links in the same chain.

  * `next`:
    Show the UUID of the next link in the chain.

  * `previous`:
    Show the UUID of the previous link in the chain.
