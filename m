From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: container disk quota
Date: Wed, 30 May 2012 22:58:54 +0800
Message-ID: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Hello All,

According to glauber's comments regarding container disk quota, it should be binded to mount
namespace rather than cgroup.

Per my try out, it works just fine by combining with userland quota utilitly in this way.
However, they are something has to be done at user tools too IMHO.

Currently, the patchset is in very initial phase, I'd like to post it early to seek more
feedbacks from you guys.

Hopefully I can clarify my ideas clearly.

Kernel part:
* Container quota can be enabled indenpent to VFS quota or particular file system quota.
  quota per user/group are kept at memory instead of saved at separately files like general quota.
  There is no need to remount the rootfs inside container with general quota strings, quota could be
  enabled through quotaon/off directly.

* Always honor underlying file system quota checking firstly.  i.e, the exported quota bill up
  routines are take affected only after file system quota check up done if it is enabled at the
  same time.   hence the space allocation or inode creation inside container will failed if the
  outside quota limits were exceeded.

* Make use of the general VFS Q_XXXX quota control flags.

* Introduce a new disk quota struture as well as the operations to mount namespacedata structure,
  it should only be allocated and initialized at CLONE stage for contianer.

* Modify quotactl(2) to examine if the caller is invoked inside container.
  implemented by checking the quota device name("rootfs" for lxc guest) or current pid namespace
  is not the initial one, then do mount namespace quotactl if required, or goto
  the normal quotactl procedure.

* Introduce a new quota format "QFMT_NS" for container.  It will be used to examine the quota
  format at userland tools, so that quotacheck will do container quota IO initialization and
  proceeding operations. This flag returned when Q_GETQINFO was issued.

* Export a couple of container quota bill routines to the desired underlying
  file system.  They will take affected if container quota is enabled at kernel
  configuration, or just some inline functions without much overhead.

* Also, I have not handle a couple of things for now.
  . I think the container quota should be isolated to Jan's fs/quota/ directory.
  . There are a dozens of helper routines at general quota, e.g,
    struct if_dqblk <-> struct fs_disk_quota converts.
    dquot space and inodes bill up.
    They can be refactored as shared routines to some extents.
  . quotastats(8) is not teached to aware container for now.

Changes in quota userland utility:
* Introduce a new quota format string "lxc" to all quota control utility, to
  let each utility know that the user want to run container quota control. e.g:
  quotacheck -cvugm -F "lxc" /
  quotaon -u -F "lxc" /
  ....

* Currently, I manually created the underlying device(by editing cgroup
  device access list and running mknod /dev/sdaX x x) for the rootfs
  inside containers to let the cache mount points routine pass for
  executing quotacheck against the "/" directory.  Actually, it can be
  omitted here.

* Add a new quotaio_lxc.c[.h] for container quota IO, it basically same to
  VFS quotaio logic, I just hope to isolate container stuff here.

Issues:
* How to detect quotactl(2) is launched from container in a reasonable way.

* Do we need to let container quota works for cgroup combine with unshare(1)?
  Now the patchset is mainly works for lxc guest.  IMHO, it can be used outside
  guest if the user desired.  In this case, the quota limits can take effort
  among different underlying file systems if they have exported quota billing
  routines.

* As the configure entry for print warnning info to TTY has been marked to
  obsoleted, do we still need to support that.

* The warnning info format for sending it through netlink interface.
  VFS quota has a device parameter filled in the warns, how we define the
  format for container?

* The hash table list defines(hash table size)for dquot caching for each type is
  referred to kernel/user.c, maybe its better to define an array separatly for
  performance optimizations.  Of course, that's all depending on my current
  implementation is on the right road. :)
 
* Container quota statistics, should them be calculated and exposed to /proc/fs/quota?  If the underlying file system also enabled with quotas, they will be
  mixed up, so how about add a new proc file like "ns_quota" there?

* Memory shrinks acquired from kswap.
  As all dquot are cached in memory, and if the user executing quotaoff, maybe
  I need to handle quota disable but still be kept at memory.
  Also, add another routine to disable and remove all quotas from memory to
  save memory directly.

* Project quota(i.e, tree quota) support.
  Now the quota implemented without project quota supports, but it can be
  supported not complex based on current code, add a new parameter to
  ns_dquot_alloc_block(), etc... is ok.
  However, XFS support project quota setup on xfs tools, I observed there
  already have patchset for this feature in EXT4 mailist, is it possble
  to supply a unique interface and implementation to quota tools in the
  furture?
  AFAICS, project quota can be setup in container, because of we can
  fetch the super block from the transferred path.  Hence, the desired
  ioctl(2) for underlying file system can be invoked. 

* Security check up for mount namespace quotactl(2).
  In this version, I only do basic security check up to see if the caller
  has properly permissions for doing that.  I think I must miss much things
  in this point.

Testing:
Currently patch is lacking tests, I only do a few check to make sure the
basic operations works.

First of all, we need to invoke quotacheck with "--no-remount" opition
since the rootfs inside container guest can not be remouted:
root@debian:~/# quotacheck -cvugm -F "lxc" /
quotacheck: quotacheck: Scanning rootfs [/] done
quotacheck: Old user file name could not been determined. Usage will not be subtracted.
quotacheck: Old group file name could not been determined. Usage will not be subtracted.
quotacheck: Old user file name could not been determined. Usage will not be subtracted.
quotacheck: Old group file name could not been determined. Usage will not be subtracted.
quotacheck: Checked 3370 directories and 39434 files

By default, user/group quota is off:
root@debian:~/# quotaon -u -F "lxc" -p /
user quota on / (rootfs) is off

root@debian:~/# quotaon -u -F "lxc" -p /
group quota on / (rootfs) is off

Turn them on: 
root@debian:~/# quotaon -u -F "lxc" /   
root@debian:~/# quotaon -g -F "lxc" /
root@debian:~/# quotaon -u -F "lxc" -p /
user quota on / (rootfs) is on
root@debian:~/# quotaon -g -F "lxc" -p /
group quota on / (rootfs) is on

Edit quota, soft/hard for both space and inode are zeros by default:
configure them to a desired value:
root@debian:~/# edquota -u -F "lxc" /
Disk quotas for user jeff (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft  
    hard
  rootfs                   2025740    2025840   2026000  42786  42790   42800

The configuration are saved properly:
root@debian:~/# repquota -u -F "lxc" /
Block grace time: 00:00; Inode grace time: 00:00
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      44       0       0             20     0     0       
jeff      -- 2025740 2025840 2026000          42786 42790 42800  

Do checking for blocks and inodes limits:
root@debian:~/# su - jeff
jeff@debian:/$ dd if=/dev/zero of=abc bs=1M count=10
10+0 records in
10+0 records out
10485760 bytes (10 MB) copied, 1.19014 s, 8.8 MB/s
root@debian:~/# repquota -u -F "lxc" /
Jeff *** report() type=0 handle index=0
*** Report for user quotas on device rootfs
Block grace time: 00:00; Inode grace time: 00:00
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      44       0       0             20     0     0       
jeff      +- 2025980 2025840 2026000  7days   42786 42790 42800       

root@debian:~/# repquota -g -F "lxc" /
*** Report for group quotas on device rootfs
Block grace time: 00:00; Inode grace time: 00:00
                        Block limits                File limits
Group           used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --    8564       0       0            390     0     0       
adm       --     220       0       0              6     0     0       
tty       --       0       0       0              1     0     0       
utmp      --       4       0       0              1     0     0       
jeff      -- 2021268       0       0          42716     0     0  

root@debian:~/# su - jeff
jeff@debian:/$ dd if=/dev/zero of=test_space bs=1M count=100
dd: writing `test_space': Disk quota exceeded
11+0 records in
10+0 records out
10506240 bytes (11 MB) copied, 1.24721 s, 8.4 MB/s

root@debian:~/# repquota -u -F "lxc" /
Jeff *** report() type=0 handle index=0
*** Report for user quotas on device rootfs
Block grace time: 00:00; Inode grace time: 00:00
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      44       0       0             20     0     0       
jeff      +- 2026000 2025840 2026000  7days   42786 42790 42800   

root@debian:~/# su - jeff
jeff@debian:/$ for ((i=0; i<20; i++)); do touch test_file_cnt.$i; done
touch: cannot touch `test_file_cnt.14': Disk quota exceeded
touch: cannot touch `test_file_cnt.16': Disk quota exceeded
touch: cannot touch `test_file_cnt.18': Disk quota exceeded

root@debian:~/# repquota -u -F "lxc" /
Block grace time: 00:00; Inode grace time: 00:00
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      44       0       0             20     0     0       
jeff      ++ 2026000 2025840 2026000  6days   42800 42790 42800  7days

Any comments are appreciated, have a nice day!

-Jeff
