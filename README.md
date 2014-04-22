# OCDROP
___

## Building
OCDROP aims to be a sharing client for owncloud (http://owncloud.org) like Cloud or Droplr that rests in your menubar.
To run owncloud, you need to run `pod install` and `git submodule update --init`, since DAVKit does not support cocoapods.

## Running
You will also need to modify AppDelegate.m and change the username, password, baseURL and other Settings according to your ownCloud account, since OCDROP does not yet have a preferences interface and values are hardcoded (Ugly, I know. Help me and send a pull request :D).

## Notes
This Project was built in one evening. Don't expect much :D

Also: I forgot to add a quit button so you'll have to force quit OCDROP :P

## License
This Project is distributed under the GNU GENERAL PUBLIC LICENSE V3 (see "LICENSE" file).
