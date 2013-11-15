From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Regression wrt mounting /proc in user namespace in 3.13
Date: Fri, 15 Nov 2013 16:41:23 +0000
Message-ID: <20131115164123.GN28794@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Just testing libvirt with user namespaces on current Fedora rawhide
3.13.0-0.rc0.git3.2.fc21.x86_64 kernel, I'm now getting an error when
we attempt to mount /proc

  # virsh -c lxc:/// start shell
  error: Failed to start domain shell
  error: internal error: guest failed to start: Failed to mount proc on /proc type proc flags=e: Operation not permitted

The syscall failing is

  mount("proc", "/proc", "proc", MS_NOSUID|MS_NODEV|MS_NOEXEC, NULL) = -1 EPERM (Operation not permitted)


On the host OS the default Fedora environment has the following mounts
present

  # grep /proc /proc/mounts 
  proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
  systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=41,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
  binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc rw,relatime 0 0
  sunrpc /proc/fs/nfsd nfsd rw,relatime 0 0

  # ls /proc/fs/nfsd/
  export_features  filehandle      nfsv4gracetime  nfsv4recoverydir  pool_threads  reply_cache_stats        threads            unlock_ip
  exports          max_block_size  nfsv4leasetime  pool_stats        portlist      supported_krb5_enctypes  unlock_filesystem  versions

  # ls /proc/sys/fs/binfmt_misc/
  qemu-alpha  qemu-cris        qemu-microblazeel  qemu-mips64el  qemu-ppc64       qemu-sh4    qemu-sparc32plus  status
  qemu-arm    qemu-m68k        qemu-mips          qemu-mipsel    qemu-ppc64abi32  qemu-sh4eb  qemu-sparc64
  qemu-armeb  qemu-microblaze  qemu-mips64        qemu-ppc       qemu-s390x       qemu-sparc  register


Only if I umount both of the /proc/sys/fs/binfmt_misc/ entries
am I able to get past this EPERM error code.

Looking at GIT history I see this change as a likely candidate for
something which has changed in this area:

  commit e51db73532955dc5eaba4235e62b74b460709d5b
  Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
  Date:   Sat Mar 30 19:57:41 2013 -0700

    userns: Better restrictions on when proc and sysfs can be mounted
    
    Rely on the fact that another flavor of the filesystem is already
    mounted and do not rely on state in the user namespace.
    
    Verify that the mounted filesystem is not covered in any significant
    way.  I would love to verify that the previously mounted filesystem
    has no mounts on top but there are at least the directories
    /proc/sys/fs/binfmt_misc and /sys/fs/cgroup/ that exist explicitly
    for other filesystems to mount on top of.
    
    Refactor the test into a function named fs_fully_visible and call that
    function from the mount routines of proc and sysfs.  This makes this
    test local to the filesystems involved and the results current of when
    the mounts take place, removing a weird threading of the user
    namespace, the mount namespace and the filesystems themselves.
    
    Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>


My guess is fs_fully_visible() is returning false, and thus causing the
proc_mount() call to return EPERM, but I'm unclear why this would happen,
or if this is indeed a correct hypothesis.


Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
