#!/usr/bin/sh

export LD_LIBRARY_PATH="/usr/lib/qwt:/usr/lib/paraview:${LD_LIBRARY_PATH}"
export PYTHONPATH="/usr/lib/paraview/site-packages/vtk:/usr/lib/paraview/site-packages:${PYTHONPATH}"

for _conf_file in $(find "/etc/profile.d/" -name "salome-*.sh"); do
  source "${_conf_file}"
done

runSalome

