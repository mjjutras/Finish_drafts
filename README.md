# Finish_drafts
Drafts of the finish.m function; runs automatically upon closing MATLAB. My version backs up all files changed in the interval specified in 'datebuffer' to the Network drive, commits all changes to Git, and specifies which repositories to push to Github in a log file.

For this to work, the following practices must be implemented:

•	Make sure that the subdirectory within the MATLAB folder on the local machine is the same as the subdirectory in the MATLAB folder on the network drive. The code will create a new folder on the network drive to match the local version if it doesn't already exist.

•	It is preferable not to load code directly from the network into MATLAB but instead to copy code to the local drive and make any changes locally. If the code is housed on Github, it's preferable to clone to the local drive rather than copy from the network.

•	The finish.m function will automatically identify files that have been changed in the last 7 days (or whatever is specified in datebuffer) and commit changes to Git, but these commits will need to be manually pushed to Github after closing MATLAB. The function will generate a log file that will detail which repositories to push to Github. This will allow for the creation on Github of repositories that don’t yet exist.

•	Make sure repository names don’t contain spaces (same goes for directories that are used to house repositories).

•	When modifying code that has been pushed to Github, it should be cloned on the local drive instead of copying from the network drive, to preserve the Git logging.

•	Only .m files will be backed up! Ensure that there are no .txt files or other misc. files (.py?) that are essential.

