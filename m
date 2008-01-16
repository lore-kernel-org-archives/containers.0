From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: [patch 00/10] mount ownership and unprivileged mount syscall (v7)
Date: Wed, 16 Jan 2008 13:31:47 +0100
Message-ID: <20080116123147.466284860@szeredi.hu>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Thanks to everyone for the comments on the previous submission.

Christoph, could you please look through the patches if they are
acceptable from the VFS point of view?

Thanks,
Miklos

v6 -> v7:

 - add '/proc/sys/fs/types/<type>/usermount_safe' tunable (new patch)
 - do not make FUSE safe by default, describe possible problems
   associated with unprivileged FUSE mounts in patch header
 - return EMFILE instead of EPERM, if maximum user mount count is exceeded
 - rename option 'nomnt' -> 'nosubmnt'
 - clean up error propagation in dup_mnt_ns
 - update util-linux-ng patch

v5 -> v6:

 - update to latest -mm
 - preliminary util-linux-ng support (will post right after this series)

v4 -> v5:

 - fold back Andrew's changes
 - fold back my update patch:
    o use fsuid instead of ruid
    o allow forced unpriv. unmounts for "safe" filesystems
    o allow mounting over special files, but not over symlinks
    o set nosuid and nodev based on lack of specific capability
 - patch header updates
 - new patch: on propagation inherit owner from parent
 - new patch: add "no submounts" mount flag

v3 -> v4:

 - simplify interface as much as possible, now only a single option
   ("user=UID") is used to control everything
 - no longer allow/deny mounting based on file/directory permissions,
   that approach does not always make sense

v1 -> v3:

 - add mount flags to set/clear mnt_flags individually
 - add "usermnt" mount flag.  If it is set, then allow unprivileged
   submounts under this mount
 - make max number of user mounts default to 1024, since now the
   usermnt flag will prevent user mounts by default

--
