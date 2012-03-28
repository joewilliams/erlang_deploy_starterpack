# Erlang release deploy example Chef cookbook

This is meant to be an example cookbook on how to deploy a tarball based Erlang release.

Requirements:

* A Chef server unless you plan to use Chef Solo
* Erlang release tarball available at an http endpoint
* Edits to the cookbook to match the name of your release
** Look for all the locations in the source for "example", including directory and/or file names
