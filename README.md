Purpose
=======

The saloon-site repository is what you need to get a site skeleton with all the
needed files and start developing your own product using saloon-core
minimalistic web framework, not caring about the Cowboy internals or even how
Saloon works.

Installation
============

Clone the repository then ```make init```.

This command will initialize node with name ```saloon_demo```, download
dependencies and compile everything.

The installation is local.

Release
=======

```make release``` will make a bundle that can easily be deployed on a
same-architecture host system by copying the release over.
