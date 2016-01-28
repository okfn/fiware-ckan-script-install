# CKAN Fiware Script install to Base Image

See the [Fiware Lab Image Deployment Guidelines](http://forge.fiware.org/plugins/mediawiki/wiki/testbed/index.php/FIWARE_LAB_Image_Deployement_Guideline) for more details of the purpose of this repository.

Running the installation script will install CKAN 2.5.

A Vagrantfile is provided for testing the scripts.


## Requirements

A base_ubuntu_14.04 image with at least **m1.small** flavour.


## Scripts

- `ckan2.5_install.sh`: to be run on the base image to install the CKAN 2.5 package and dependencies using chef. Requires that `cookbooks.tgz` is uploaded to the image at `/tmp/cookbooks.tgz`.
- `install_verification.sh`: runs `ckan2.5_install_verification.sh` in the image to verify that the installed services are running. Checks the following:
    + Apache2 is running
    + A request to http://localhost is successful
    + A request to Solr is successful
    + A request to the Datastore is successful


## Note

If changes are made to the `cookbooks` directory, a new `cookbooks.tgz` archive will need to be created with:

`tar -czvf cookbooks.tgz cookbooks`
