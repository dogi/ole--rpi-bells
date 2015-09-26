OLE raspberry pi bell
=====================

this repository contains various ways to create BeLL nations and/or communities for raspberry pi with [pirateship build](http://pirate.sh)

GIT
---
this BeLL's are live and are very interesting for developers to test there changes before commits and/or releases:
- [one live Nation](https://gist.github.com/dogi/9c37ca68982f488dd9b9)
- [one live Community](https://gist.github.com/dogi/a7d00eac2af80816d1de)

Release
-------
standard usecase
- [one Community](https://gist.github.com/dogi/7a3087fb0e3d026f4c04)
- (work in progress [one Nation and one Community](https://gist.github.com/treehouse-su/07e1919333e12f07768e))

Offline
-------
this Bell Community install needs a USB Stick ...
- [one Community with USB Stick](https://gist.github.com/dogi/dbe5408d97fc112e06a6)

QA
--
this BeLL's are build out of release and follow specially the need of QA which has to decide if a new build works with all the install and upgrade workflow of nations and communities:
- [2 Nations (old and new release) with QA content](qa/2nations-autorunonce.sh)
- [2 Communities (old and new release) attached to old nation](qa/2oldcommunities-autorunonce.sh)
- [2 Communities (old and new release) attached to new nation](qa/2newcommunities-autorunonce.sh)

original:
- [original 2 Nations](https://gist.github.com/treehouse-su/90d2fe58e1d8e0dcbbd7)

Branch
------
this install script is designed to create a branch library which will be paired up with an already exsisting community
- [Branch Library](branch/branch-autorunonce.sh)
