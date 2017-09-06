"""
  Write bytes to an RBD image 
  (useful for development / tests)

  Other useful commands
   $ rados --pool=iscsi-images ls
   $ rados --pool=iscsi-images stat rbd_data.19be7238e1f29.0000000000000002
   $ rados --pool=iscsi-images get rbd_data.19be7238e1f29.0000000000000002 /tmp/data.tmp
"""

import rbd
import rados
import sys

if len(sys.argv) != 5:
    print "Required parameters:\n  <pool-name> <rbd-image> <offset-in-megabytes> <length-in-megabytes>"
    sys.exit()

pool_name=sys.argv[1]
rbd_image=sys.argv[2]
offset = int(sys.argv[3]) * 1024 ** 2
length = int(sys.argv[4]) * 1024 ** 2

cluster = rados.Rados(conffile='/etc/ceph/ceph.conf')
cluster.connect()

ioctx = cluster.open_ioctx(pool_name)

image = rbd.Image(ioctx, rbd_image)

image.write("R"*length, offset)
image.close()
ioctx.close()
cluster.shutdown()

print "Poll name: {}".format(pool_name)
print "RBD image: {}".format(rbd_image)
print "Offset: {} bytes".format(offset)
print "Lenght: {} bytes".format(length)
