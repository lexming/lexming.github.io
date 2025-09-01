---
title: "Linker error: multiple definition of symbol"
date: 2022-02-24
tags:
- linker
---

I got the following error from the linker `ld.gold` while linking `libsumo` in
a build of [SUMO](https://www.eclipse.org/sumo/) with bindings to
[FOX-toolkit](http://fox-toolkit.org/):

> g++ -fPIC -O2 -ftree-vectorize -march=native -fno-math-errno -std=c++11 -Wall -pedantic -Wextra -fPIC -O3 -DNDEBUG -L/apps/PROJ/7.0.0-GCCcore-9.3.0/lib -L/apps/GDAL/3.0.4-foss-2020a-Python-3.8.2/lib -L/apps/GL2PS/1.4.2-GCCcore-9.3.0/lib64 -L/apps/GL2PS/1.4.2-GCCcore-9.3.0/lib -L/apps/FOX-Toolkit/1.6.57-GCCcore-9.3.0/lib64 -L/apps/FOX-Toolkit/1.6.57-GCCcore-9.3.0/lib -L/apps/Xerces-C++/3.2.3-GCCcore-9.3.0/lib64 -L/apps/Python/3.8.2-GCCcore-9.3.0/lib -L/apps/Java/11.0.2/lib -L/apps/FFTW/3.3.8-gompi-2020a/lib -L/apps/ScaLAPACK/2.1.0-gompi-2020a/lib -L/apps/OpenBLAS/0.3.9-GCC-9.3.0/lib -L/apps/GCCcore/9.3.0/lib64 -L/apps/GCCcore/9.3.0/lib -shared  -o build/SUMO/1.0.0/foss-2020a-Python-3.8.2/sumo-1.0.0/tools/libsumo/_libsumo.so CMakeFiles/_libsumo.dir/__/__/tools/libsumo/libsumoPYTHON_wrap.cxx.o  -Wl,--whole-archive ../netload/libnetload.a ../microsim/libmicrosim.a ../microsim/cfmodels/libmicrosim_cfmodels.a ../microsim/lcmodels/libmicrosim_lcmodels.a ../microsim/devices/libmicrosim_devices.a ../microsim/output/libmicrosim_output.a ../microsim/pedestrians/libmicrosim_pedestrians.a ../microsim/trigger/libmicrosim_trigger.a ../microsim/actions/libmicrosim_actions.a ../microsim/traffic_lights/libmicrosim_traffic_lights.a ../mesosim/libmesosim.a ../traci-server/libtraciserver.a liblibsumostatic.a ../utils/emissions/libutils_emissions.a ../foreign/PHEMlight/cpp/libforeign_phemlight.a ../utils/vehicle/libutils_vehicle.a ../utils/distribution/libutils_distribution.a ../utils/shapes/libutils_shapes.a ../utils/options/libutils_options.a ../utils/xml/libutils_xml.a ../utils/geom/libutils_geom.a ../utils/common/libutils_common.a ../utils/importio/libutils_importio.a ../utils/iodevices/libutils_iodevices.a ../foreign/tcpip/libforeign_tcpip.a /apps/Xerces-C++/3.2.3-GCCcore-9.3.0/lib64/libxerces-c.so /apps/PROJ/7.0.0-GCCcore-9.3.0/lib/libproj.so -L/apps/FOX-Toolkit/1.6.57-GCCcore-9.3.0/lib -lFOX-1.6 -lX11 -lXext -lfreetype -lfontconfig -lXft -lXcursor -lXrender -lXrandr -lXfixes -lXi -ldl -lpthread -lrt -lm -lpthread -ljpeg -lpng -ltiff -lz -lbz2 -Wl,--no-whole-archive /apps/Python/3.8.2-GCCcore-9.3.0/lib/libpython3.8.so
>
> **/apps/binutils/2.34-GCCcore-9.3.0/bin/ld.gold: error: /usr/lib64/libpthread_nonshared.a(pthread_atfork.oS): multiple definition of '__pthread_atfork'**
>
> /apps/binutils/2.34-GCCcore-9.3.0/bin/ld.gold: /usr/lib64/libpthread_nonshared.a(pthread_atfork.oS): previous definition here
>
> **/apps/binutils/2.34-GCCcore-9.3.0/bin/ld.gold: error: /usr/lib64/libpthread_nonshared.a(pthread_atfork.oS): multiple definition of 'pthread_atfork'**
>
> /apps/binutils/2.34-GCCcore-9.3.0/bin/ld.gold: /usr/lib64/libpthread_nonshared.a(pthread_atfork.oS): previous definition here
>
> collect2: error: ld returned 1 exit status
>
> make[2]: *** [build/SUMO/1.0.0/foss-2020a-Python-3.8.2/sumo-1.0.0/tools/libsumo/_libsumo.so] Error 1
>
> make[2]: Leaving directory 'build/SUMO/1.0.0/foss-2020a-Python-3.8.2/easybuild_obj'
>
> make[1]: *** [src/libsumo/CMakeFiles/_libsumo.dir/all] Error 2
>
> make[1]: Leaving directory 'build/SUMO/1.0.0/foss-2020a-Python-3.8.2/easybuild_obj'
>
> make: *** [all] Error 2

The main errors from the linker are the `multiple definition of 'symbol'`
errors, which are caused by duplicate `LDFLAGS` in the linker command. In this
case, `-lpthread` is declared twice

> g++ [...] -ldl **-lpthread** -lrt -lm **-lpthread** -ljpeg -lpng [...]

This error can be easily solved by removing the duplicate linker flag. However,
depending on the underlying build system, this can be more or less involved. If
the build is done with `make`, it can be just a matter of manually editing the
corresponding `Makefile`.

In this case, the build is based on [CMake](https://cmake.org/) and hence, it
is necessary to dig into its modules to find the spot where this duplication
happens. Once the origin of the duplication is found, CMake provides the
`REMOVE_DUPLICATES` method to clean all duplicates from a list.

The following code snippet automatically removes duplicate elements in
`FOX_LIBRARY`, which contains these flags in the build of SUMO
(`cmake_modules/FindFOX.cmake`):

```cmake
separate_arguments(FOX_LIBRARY)
list(REMOVE_DUPLICATES FOX_LIBRARY)
string(REPLACE ";" " " FOX_LIBRARY "${FOX_LIBRARY}")
```
