#!/usr/bin/sh

export LD_LIBRARY_PATH="/usr/lib/qwt:/usr/lib/paraview:${LD_LIBRARY_PATH}"
export PYTHONPATH="/usr/lib/paraview/site-packages/vtk:/usr/lib/paraview/site-packages:${PYTHONPATH}"

find "/etc/profile.d/" -name "salome-*.conf" -exec source "{}" \;

runSalome

