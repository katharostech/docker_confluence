# Build the version specific image
Building this image requires that you pass a version of the Confluence binary to the build command.  This version must coincide directly with the build number that resides in the downloads section of BitBucket for this Git repo.
The same version of the Confluence binary used (6.8.0 as in the example below), should be used to tag the Docker image produced.  Additional tags may be added as needed after the initial image is built.

```bash
docker build --build-arg CONFL_VERSION=6.8.0 -t kadimasolutions/confluence:6.8.0 .
```

# Run the container
Running the container can be done as follows.  

```bash
docker run -h confl \
--name confl \
-v prod-confl-attachs:/var/atlassian/application-data/confluence/attachments:Z \
-v prod-confl-thumbs:/var/atlassian/application-data/confluence/thumbnails:Z \
-v prod-confl-index:/var/atlassian/application-data/confluence/index:Z \
-e dbhost="mydbhost:3306" \
-e dbname="mydb" \
-e dbuser="mydbuser" \
-e dbpass="mydbpass" \
-e sid="MY-SERVER-SID" \
-e lic="MyBigGiantLicenseKeyWithSpecialCharactersEscapedWithBackSlashes" \
-e ssl_term_domain="confluence.zalecorp.com" \
-e nfs_mount_attachments_cmd=mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-999999.efs.us-west-2.amazonaws.com:/attachments /var/atlassian/application-data/confluence/attachments
-e nfs_mount_thumbnails_cmd=mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-999999.efs.us-west-2.amazonaws.com:/thumbnails /var/atlassian/application-data/confluence/thumbnails
-e nfs_mount_index_cmd=mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-999999.efs.us-west-2.amazonaws.com:/index /var/atlassian/application-data/confluence/index
-p 8090:8090 \
-dt kadimasolutions/confluence:6.8.0
```

# Environment Variables

## ssl_term_domain
This environment variable is used when setting up your server with SSL Termination.  Confluence needs to know what domain your server is listening on for port 443 traffic.  This assumes that all other measures, such as certification and network routing is already in place for proper SSL Termination.  Providing this environment variable injects the appropriate proxy information into the server configuration to properly serve terminated traffic.  This setup does NOT support SSL Offloading where the Confluence server itself is setup to translate the encrypted SSL traffic.

## Database connection and license info
Take note that if any of the following environment variables are missing from the run command of this container, the container will assume that this is a new instance and it will treat it as such, and you will be presented with the default installation wizard when navigating to the site.  All variables are necessary to successfully start up an existing instance.  These include database connection information and server id as well as license.  Note that the license variable must have special characters escaped with back slashes.  The most notable to escape are the forward slashes as the license is injected into the config file using sed.  As such sed uses slashes for its syntax and thus slashes in the license cause misinterpretation during the injection process.

* dbhost
* dbname
* dbuser
* dbpass
* sid
* lic

## NFS Mount commands
The NFS mount commands provided in the example are specific to AWS EFS, however any NFS storage device in any location can be substituted.  These NFS commands should be used instead of the volume mounts if the system is using NFS to store the data.  You cannot use both the volume mounts and the NFS mount commands.  The NFS devices need to be mounted to the container locations that are referenced in the example.  These locations support the application's persisted data.

# Volume Mounts
In the case that you are using named volumes or host mounts, the volume commands in the example should be used.  Note that these volume mounts should not be used in conjunction with the NFS Mount Command environment variables as they serve the same purpose through different methods.  You must use one or the other depending on your system setup.
