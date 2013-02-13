From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: nfs-ganesha with Linux containers
Date: Tue, 12 Feb 2013 23:47:47 -0800
Message-ID: <20130213074747.GA19635@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nfs-ganesha-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



I have nfs-ganesha [1.5.1] with FSAL_VFS running on Linux 3.7.0-rc8 on
an x86_64 RHEL6.2 system (the "host"). I can export the filesystems and
mount from another system.

I am trying to use nfs-Ganesha from within a Linux container on the same
system.

My container setup:

	On the REHL6.2 host, I have a directory, /export/vm1-root.

	The root of my linux container is bind mounted to that directory 
	So a file '/export/vm1-root/foobar' is known to the container as
	'/foobar' and other files/directories in '/export' are not visible
	from the container.

	[ie it is as if the processes inside the containers have run 'chroot'
	into /export/vm1-root and can't escape out of this]. 

I am now trying to export a directory, '/vm1gfs0' from within the container
to the external world. (on the host, this directory is /export/vm1-root/vm1gfs).

I have nfs-ganesha* rpms installed and /etc/ganesha/vfs.ganesha.exports.conf
properly configured to export '/vm1gfs0' from within the container. 

When I try to start the vfs-ganesha service from within the container:

	$ /etc/init.d/nfs-ganesha-vfs start

I get the following errors in the log file:


------
12/02/2013 15:01:20 epoch=1360710080 : elm3a241-vm1 : vfs.ganesha.nfsd-1015[main
] :COMMON_InitClientContext :FSAL: FULLDEBUG: FSAL_InitClientContext returns (ER
R_FSAL_NO_ERROR, No error, 0)
12/02/2013 15:01:20 epoch=1360710080 : elm3a241-vm1 : vfs.ganesha.nfsd-1015[main
] :VFSFSAL_BuildExportContext :FSAL: CRITICAL ERROR: No mount entry matches '/ex
port/vm1gfs0' in /etc/mtab
12/02/2013 15:01:20 epoch=1360710080 : elm3a241-vm1 : vfs.ganesha.nfsd-1015[main
] :VFSFSAL_BuildExportContext :FSAL: DEBUG: FSAL_BuildExportContext returns (ERR
_FSAL_NOENT, No such file or directory, 0)
12/02/2013 15:01:20 epoch=1360710080 : elm3a241-vm1 : vfs.ganesha.nfsd-1015[main
] :nfs_export_create_root_entry :NFS STARTUP: CRITICAL ERROR: Couldn't build exp
ort context for /vm1gfs0
12/02/2013 15:01:20 epoch=1360710080 : elm3a241-vm1 : vfs.ganesha.nfsd-1015[main
] :nfs_Init :NFS STARTUP: FATAL ERROR: Error initializing Cache Inode root entri
es

--------

Inside the linux container, there is no entry in /etc/mtab for the
container's root filesystem. 

Is nfs-Ganesha trying to find the path all the way back to the root of the 
filesystem (which the linux container is unable to get to) ?

Faking an mtab entry with:

	$ mount -o bind / /

gives a slightly different error:

---------

12/02/2013 15:42:05 epoch=1360712525 : elm3a241-vm1 : vfs.ganesha.nfsd-1113[main
] :COMMON_GetClientContext :FSAL: FULLDEBUG: FSAL_GetClientContext returns (ERR_
FSAL_NO_ERROR, No error, 0)
12/02/2013 15:42:05 epoch=1360712525 : elm3a241-vm1 : vfs.ganesha.nfsd-1113[main
] :fsal_internal_Path2Handle :FSAL: FULLDEBUG: Lookup handle for /vm1gfs0
12/02/2013 15:42:05 epoch=1360712525 : elm3a241-vm1 : vfs.ganesha.nfsd-1113[main
] :VFSFSAL_lookupPath :FSAL: DEBUG: FSAL_lookupPath returns (ERR_FSAL_NOENT, No
such file or directory, 2)
12/02/2013 15:42:05 epoch=1360712525 : elm3a241-vm1 : vfs.ganesha.nfsd-1113[main
] :nfs_export_create_root_entry :NFS STARTUP: CRITICAL ERROR: Couldn't access th
e root of the exported namespace, ExportId=77 Path=/vm1gfs0 FSAL_ERROR=(2
,2)
12/02/2013 15:42:05 epoch=1360712525 : elm3a241-vm1 : vfs.ganesha.nfsd-1113[main
] :nfs_Init :NFS STARTUP: FATAL ERROR: Error initializing Cache Inode root entri
es

---------

If a physical disk is mounted inside the container, say:

	$ mount /dev/sdb1 /mnt1

will we be able export /mnt1 from within the container or does nfs-Ganesha
still need to find the actual root fs ?

In effect, can a process chroot into a directory and export a subdir using
nfs-ganesha ?

Sukadev
