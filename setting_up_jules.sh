#!/bin/bash
# Vivek, September 2023
Installing JULES in cv-hydro2

# A. 
ssh into cv-hydro1.cv.ic.ac.uk # because I didn't yet have access to ICL netwrok and this server was accessible on public network
ssh into cv-hydro2.cv.ic.ac.uk
#B. in 
/home/vivek/ from now on

# install some packages needed for cylc:
conda install -c conda-forge pygraphviz

#a. install python using miniconda
#using /home/clara/environment.yml file create a new python env, it will be python=2.7. JULES compatible with python>=3 is under working
conda env create -f environment.yml

#b. Now as the installation flow cylc -> Rose -> FCM -> JULES
#installing cylc (cylc-flow)
#now create a directory local in /home/vivek/: 
mkdir ~local
#currently JULES works with cylc<=7.9.8, get it from the github repo archive. I used 7.9.8
## Now this line is not needed now set the cylc version as env variable: export CYLC_VERSION="7.9.8"

'''| Pre-requisite of cylc is sphinx: '''
conda install sphinx

cd ~/local
wget https://github.com/cylc/cylc-flow/archive/refs/tags/7.9.7.tar.gz
tar zxf 7.9.7.zip
cd cylc-flow-7.9.7
export PATH=$PWD/bin:$PATH      # this will only temporarily set the path. Better do it permanently using: export PATH="$PATH:/path/to/dir"
#so edit the .bashrc file as: 
#vi ~/.bashrc
#scroll to the last line and add the line below
make

export PATH=$HOME/jules/local/cylc/bin:$PATH
export PATH=$HOME/jules/local/bin:$PATH

cylc --version
cylc check-software
#check the installation of cylc using: cylc check-software % only core requirements are needed

#c. Now installing Rose
#it did not work using mamba and conda-forge channel, probably because we need -v 2019.01.x and below gives -v 2
#mamba install -c conda-forge metomi-rose

cd ~/local
git clone https://github.com/metomi/rose.git
cd rose

#git tag -l
git checkout tags/2018.02.0     # Clara and Simon use more recent version (2019.01)
cd ..
export PATH=$HOME/local/rose/bin:$PATH
rose --version
cd ..
mkdir ~/.metomi
cd ~/.metomi
# Create a text file ~/.metomi/rose.conf containing the following test and substituting your username and whatever your SITE is
echo "[rosie-id]
prefix-username.u=yourusername

[rose stem]
automatic-options=SITE=jasmin" > rose.conf.txt

cd ~/local/rose/etc/

echo "[rosie-id]
prefix-default=u
prefixes-ws-default=u
prefix-location.u=https://code.metoffice.gov.uk/svn/roses-u
prefix-web.u=https://code.metoffice.gov.uk/trac/roses-u/intertrac/source:
prefix-ws.u=https://code.metoffice.gov.uk/rosie/u" >> rose.conf

source ~/.bashrc

# Check the Rose installation and server links
cd ~/local/
git clone git@github.com:metomi/metomi-vms.git
export PATH=$PATH:$HOME/local/metomi-vms/usr/local/bin     #WB: may need to be installed. Note: path at the end because it also comes with cylc

rosie hello


#d. Now installing FCM
#First go here: https://jules.jchmr.org/get-fcm
cd ~/local
git clone https://github.com/metomi/fcm.git
cd fcm
git tag -l
git checkout tags/2017.10.0
cd ..
export PATH=$HOME/local/fcm/bin:$PATH
fcm --version
​

mkdir ~/.subversion
cd ~/.subversion
echo "[groups]
metofficesharedrepos =code*.metoffice.gov.uk
[metofficesharedrepos]
username =yourusername
store-plaintext-passwords=no" >> servers.txt

# Check FCM installation
fcm --version

# Set up keywords
mkdir ~/.metomi/fcm/
cd ~/.metomi/fcm/
echo "location{primary, type:svn}[jules.x] = https://code.metoffice.gov.uk/svn/jules/main
browser.loc-tmpl[jules.x] = https://code.metoffice.gov.uk/trac/{1}/intertrac/source:/{2}{3}
browser.comp-pat[jules.x] = (?msx-i:\A // [^/]+ /svn/ ([^/]+) /*(.*) \z)

location{primary, type:svn}[jules_doc.x] = https://code.metoffice.gov.uk/svn/jules/doc
browser.loc-tmpl[jules_doc.x] = https://code.metoffice.gov.uk/trac/{1}/intertrac/source:/{2}{3}
browser.comp-pat[jules_doc.x] = (?msx-i:\A // [^/]+ /svn/ ([^/]+) /*(.*) \z)" >> keyword.cfg 

#e. Setting up MOSRS account login and password
## Caching your MOSRS password
#Caching your MOSRS password may be problematic if your MOSRS password has special characters in it (eg "%","!" or "&")
#Download two MOSRS utilities from [here]# (https://code.metoffice.gov.uk/trac/home/wiki/AuthenticationCaching/GpgAgent):
#firefox https://code.metoffice.gov.uk/trac/home/raw-attachment/wiki/AuthenticationCaching/GpgAgent/mosrs-setup-gpg-agent
#Put in your MOSRS password, save the file and close Firefox.
#firefox https://code.metoffice.gov.uk/trac/home/raw-attachment/wiki/AuthenticationCaching/GpgAgent/mosrs-cache-password
#Again, put in your MOSRS password, save the file and close Firefox.

mv ~/Downloads/mosrs-setup-gpg-agent ~/local/mosrs-setup-gpg-agent

mv ~/Downloads/mosrs-cache-password ~/local/mosrs-cache-password

''' Extremely important I lost a lot of time here '''
1. Make a folder in your home dir and add a file gpg-agent.conf with one line as 'allow-preset-passphrase'
mkdir ~/.gnupg
echo "allow-preset-passphrase" >> ~/.gnupg/gpg-agent.conf

2. 'Change the path of gpgpresetpassphrase variable in the mosrs-cache-password script to /usr/lib/gnupg/gpg-preset-passphrase'
'''Now export the path of the local folder to make both the above mosrs scripts 
executebale and add the folder to path'''
export PATH=$HOME/local:$PATH

chmod -R 755 ~/local

svn --version # check if subversion is installed, it is by default in linux
# if not installed simply: sudo apt install subversion
3. #Now activate
mosrs-setup-gpg-agent

'''3. Installing JULES'''
#Ideally download it using MORS login and fcm from metofficuk. Wouter had already given me three versions, using that below.

## Install JULES
mkdir ~/MODELS
cd ~/MODELS

# Download a version of JULES
'Format for download from a trunk (released version)'  fcm co fcm:jules.x_tr@vnX.X <DIR>
'from  a branch (under development version)'  fcm co fcm:jules.x_br/dev/<USER>/<BRANCH_NAME> <DIR>
fcm co fcm:jules.x_tr@vn6.1 "jules-vn6.1"

cd jules-vn6.1
export JULES_ROOT=$PWD
​echo $JULES_ROOT

`# Following is only for building manually (without rose) `
#Now echo a lot of things...
# export JULES_REMOTE=local
# export JULES_COMPILER=gfortran
# export JULES_BUILD=normal
# export JULES_OMP=noomp
# export JULES_MPI=mpi
# export JULES_NETCDF=netcdf
# export JULES_NETCDF_PATH=/opt/netcdf_par
# export JULES_NETCDF_INC_PATH=/opt/netcdf_par/include
# export JULES_NETCDF_LIB_PATH=/opt/netcdf_par/lib
# #this one is necessary to get rid of some type mismatches in the code (see above)
# export JULES_FFLAGS_EXTRA="-fallow-argument-mismatch"
# export JULES_LDFLAGS_EXTRA=""
# ​
# Now make...
# fcm make -j 2 -f etc/fcm-make/make.cfg --new
​`End of manual build`


rosie go

​''' add the following lines to the your bashrc file '''

#zlib
export PATH=/opt/zlib/:$PATH

# add both local and .local to path
export PATH=$HOME/local:$PATH
export PATH=$HOME/.local/bin:$PATH

# for Cylc
export PATH=$HOME/local/cylc-flow-7.9.7/bin:$PATH

# for Rose
export PATH=$HOME/local/rose/bin:$PATH
export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/usr/local/lib:$HOME/local/lib:$LD_LIBRARY_PATH

# for FCM
export PATH=$HOME/.local/fcm/bin:$HOME/local:$PATH

# cache mosrs password
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=`gpgconf --list-dirs agent-socket | tr -d '\n' && echo -n ::`
[[ "$-" != *i* ]] && return # Stop here if not running interactively

#netcdf
export PATH=/opt/netcdf_par/bin:$PATH
export LD_LIBRARY_PATH=/opt/netcdf_par/lib:$LD_LIBRARY_PATH

'4. Might not be needed yet, under testing'
4. Now is the time to expirt paths to netcdf libraries
Need to export two paths $JULES_NETCDF_INC_PATH and $JULES_NETCDF_LIB_PATH
As explained in `Check NetCDF: https://jules.jchmr.org/check-netcdf`
` path to $JULES_NETCDF_INC_PATH (module path)` find /usr -name "netcdf.mod"
` path to $JULES_NETCDF_LIB_PATH ( Fortran library path)` find /usr -name "libnetcdff.*"  
export JULES_NETCDF_INC_PATH=/usr/include:$JULES_NETCDF_INC_PATH
export JULES_NETCDF_LIB_PATH=/usr/lib/x86_64-linux-gnu:$JULES_NETCDF_LIB_PATH

export JULES_NETCDF_PATH=/usr    % nc-config  --prefix

"That's all folks!"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'When Rosie GUI is not working >>>'
If rosie go GUI does not start due to no libpng15 (this is an old library used to create GUI)
You need to build and install it, then make a hard link or export to LD_LIBRARY_PATH of the
installed location

go to sourceforge and search for libpng15, version 15. Download
wget https://excellmedia.dl.sourceforge.net/project/libpng/libpng15/older-releases/1.5.15/libpng-1.5.15.tar.gz
tar xvf libpng-1.5.15
cd libpng-1.5.15
./configure --prefix=/usr/local/libpng
make check
sudo make install
make check

'Installled! now export PATH OR add the path to LD_LIBRARY_PATH'
add the path /usr/local/libpng/lib: to the LD_LIBRARY_PATH variable in bashrc file
source ~/.bashrc


Again same problem as above, libexpat.so.0 was missing
Check if any existing versions of libexpat are installed
apt list libexpat1  
% see online for other versions like libexpat1-dev
'If found existing installations make a symboliclink of missing libexpat.so.0
to that installation'
Find path of that installation
dpkg -L libexpat1
ln  -sf  /lib/x86_64-linux-gnu/libexpat.so.1   libexpat.so.0
'Note that this creates a symboliclink only updating libexpat1 or changing its location will break the link. I was not able to create a hard link properly'
Verify it was created:
ls -l

Now run the GUI version of rosie
rosie go

'If it did not work, follow as above and find libexpat.so.0 somewhere and build and export path to LD_LIBRARY_PATH'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
''' Following is only for direct (without rose) run''' 
#Jules path
# export PATH=~/MODELS/jules-vn6.1/bin:$PATH
# export PATH=~/MODELS/jules-vn6.1/build/bin:$PATH
# export PATH=~/MODELS/jules-vn6.1/rose-stem/bin:$PATH
# export JULES_ROOT=~/MODELS/jules-vn6.1

# #openmpi
# export LD_LIBRARY_PATH=/opt/openmpi/lib:$LD_LIBRARY_PATH
# export PATH=/opt/openmpi/bin:$PATH
# source ~/.bashrc

### Check installations worked properly
cd ~
echo $SHELL
# This should return "/bin/bash"


Statring :Jules from scratchcd now on:

export RSUITE=$HOME/roses/u-cj531
echo $RSUITE

Now edit the roses suite using rose edit or any text editor

rose edit -C $RSUITE &
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
Tryng to run JULES now...

Note that $NAMELISTS is the folder containing the paramter files i.e. ending with .nml 
I found those in the folder $RSUITE/app/jules
export NAMELIST=$HOME/roses/nlists_${RSUITE##*/}; mkdir -p $NAMELIST; cd $NAMELIST
export NAMELIST=$HOME/roses/nlists_${RSUITE##*/}

Now I copied the .nml files to the folder which is pointed by $NAMELIST

Now run JULES in command line mode
$JULES_ROOT/build/bin/jules.exe $NAMELIST

Or using the GUI of Rose:

rose edit -C $RSUITE &  % from 'jules from scrtah'
rose suite-run  % from Dr Wouter didnt work for me


155.198.88.132  cv-hydro1
155.198.88.142  cv-hydro2
