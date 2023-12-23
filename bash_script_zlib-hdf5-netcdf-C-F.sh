#!/bin/bash
# Vivek, 23 October 2023
mkdir ~/netcdf_par
mkdir ~/newfolder2
cd newfolder2

# Zlib
wget https://www.zlib.net/zlib-1.3.tar.gz
tar -xzf zlib-1.3.tar.gz
cd zlib-1.3
./configure --prefix=$HOME/netcdf_par/zlib-1.3

make -j8
#make check -j8
make install -j8
export PATH=$HOME/netcdf_par/zlib-1.3:$PATH
cd ..
echo "Installation of Zlib completed"

# openmpi
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz
tar -xzf openmpi-4.1.6.tar.gz
cd openmpi-4.1.6
./configure --prefix=$HOME/netcdf_par/openmpi-4.1.6 --with-zlib=$HOME/netcdf_par/zlib-1.3
make all -j8
make install -j8
cd ..
export PATH=$HOME/netcdf_par/openmpi-4.1.6/bin:$PATH
export LD_LIBRARY_PATH=$HOME/netcdf_par/openmpi-4.1.6/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$HOME/netcdf_par/openmpi-4.1.6lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$HOME/netcdf_par/openmpi-4.1.6/share/man:$MANPATH
echo "Installation of openmpi completed"

#HDF5
wget  https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.1/src/hdf5-1.12.1.tar.gz
tar -xzf hdf5*.tar.gz
cd hdf5-1.12.1
CC=$HOME/netcdf_par/openmpi-4.1.6/bin/mpicc \
./configure --enable-parallel --with-zlib=$HOME/netcdf_par/zlib-1.3 \
--prefix=$HOME/netcdf_par/hdf5-1.12.1
make -j8
#make check -j8
make install -j8
cd ..
export PATH=$HOME/netcdf_par/hdf5-1.12.1/bin:$PATH
export LD_LIBRARY_PATH=$HOME/netcdf_par/hdf5-1.12.1/lib:$LD_LIBRARY_PATH
echo "Installation of hdf5 completed"

wget https://codeload.github.com/Unidata/netcdf-c/tar.gz/refs/tags/v4.6.3 -O netcdf-c-4.6.3.tar.gz
tar -xzf netcdf-c-4.6.3.tar.gz
cd  netcdf-c-4.6.3
#*** For netcdf C build ***
export CC=$HOME/netcdf_par/openmpi-4.1.6/bin/mpicc
export H5DIR=$HOME/netcdf_par/hdf5-1.12.1
export ZDIR=$HOME/netcdf_par/zlib-1.3

# export the following flags, they are for netcdf, hdf5 and zlib  
CC=$HOME/netcdf_par/openmpi-4.1.6/bin/mpicc  \
CPPFLAGS="-I${H5DIR}/include -I${ZDIR}/include" \
LDFLAGS="-L${H5DIR}/lib -L${ZDIR}/lib" \
./configure --enable-shared --enable-static --enable-parallel-tests --prefix=$HOME/netcdf_par/netcdf-c-4.6.3     

make -j8
#make check
make install -j8
cd  ..
export PATH=$HOME/netcdf_par/netcdf-c-par-4.6.3/bin:$PATH
export LD_LIBRARY_PATH=$HOME/netcdf_par/netcdf-c-par-4.6.3/lib:$LD_LIBRARY_PATH
echo "Installation of netcdf-c completed"

#*** For netcdf fortran build ***
wget https://codeload.github.com/Unidata/netcdf-fortran/tar.gz/refs/tags/v4.6.0 -O netcdf-fortran-4.6.0.tar.gz
tar -xzf netcdf-fortran-4.6.0.tar.gz
cd netcdf-fortran-4.6.0
export NCDIR=$HOME/netcdf_par/netcdf-c-4.6.3
export NFDIR=$HOME/netcdf_par/netcdf-c-4.6.3
export H5DIR=$HOME/netcdf_par/hdf5-1.12.1
export ZDIR=$HOME/netcdf_par/zlib-1.3

# export the following flags, they are for netcdf, hdf5 and zlib

CC=$HOME/netcdf_par/openmpi-4.1.6/bin/mpicc \
FC=$HOME/netcdf_par/openmpi-4.1.6/bin/mpifort \
F77=$HOME/netcdf_par/openmpi-4.1.6/bin/mpifort  \
CPPFLAGS="-I${NCDIR}/include -I${H5DIR}/include -I${ZDIR}/include" \
LDFLAGS="-L${NCDIR}/lib -L${H5DIR}/lib -L${ZDIR}/lib" \
LD_LIBRARY_PATH="-L${NCDIR}/lib -L${H5DIR}/lib -L${ODIR}/lib"  \
LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lm -lzlib1 -lsz -lxml2" \
./configure  --enable-static --enable-shared --prefix=$HOME/netcdf_par/netcdf-c-4.6.3

make -j8
#make check
make install -j8
echo "Installation of netcdf-fortran completed"

cd