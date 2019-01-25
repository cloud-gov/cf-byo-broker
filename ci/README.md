# Pipelines

We have provided a [set-pipelines.sh](set-pipelines.sh) script as a convenience. This will create all the pipelines in this repo.
Simply run the script with a fly target name and the pipelines in this repo will be created accordingly. For example, 
running `./set-pipelines.sh 18f` will create the pipelines in the Concourse team area defined by the target `18f`.