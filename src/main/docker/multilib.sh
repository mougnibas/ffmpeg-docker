#!/bin/sh
#
# Based on x265/build/linux/multilib.sh original source.
# The unix static combine part has been removed, because this is a linux build.
# '-DENABLE_SHARED=OFF' has beed added to 8bit build
# Parameters order has been changed to better reflect changes between builds.
#

# Create multidepth build directories
mkdir -p 8bit 10bit 12bit

# Compile 12bit library
cd 12bit
cmake ../../../source -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DMAIN12=ON
make ${MAKEFLAGS}

# Compile 10bit library
cd ../10bit
cmake ../../../source -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF 
make ${MAKEFLAGS}

# Compile 8bit library, with awareness of 10bit and 12bit libraries
cd ../8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a
cmake ../../../source -DENABLE_SHARED=OFF -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON
make ${MAKEFLAGS}

# Combine 8bit, 10bit and 12 bit library together, for static library purpose
mv libx265.a libx265_main.a
ar -M <<EOF
CREATE libx265.a
ADDLIB libx265_main.a
ADDLIB libx265_main10.a
ADDLIB libx265_main12.a
SAVE
END
EOF
