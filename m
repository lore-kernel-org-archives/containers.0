From: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Wed, 20 Aug 2014 17:06:59 +0200
Message-ID: <CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fvhav3ic.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 6, 2014 at 2:57 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Linus,
>
> Please pull the for-linus branch from the git tree:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>
>    HEAD: 344470cac42e887e68cfb5bdfa6171baf27f1eb5 proc: Point /proc/mounts at /proc/thread-self/mounts instead of /proc/self/mounts
>
> This is a bunch of small changes built against 3.16-rc6.  The most
> significant change for users is the first patch which makes setns
> drmatically faster by removing unneded rcu handling.
>
> The next chunk of changes are so that "mount -o remount,.." will not
> allow the user namespace root to drop flags on a mount set by the system
> wide root.  Aks this forces read-only mounts to stay read-only, no-dev
> mounts to stay no-dev, no-suid mounts to stay no-suid, no-exec mounts to
> stay no exec and it prevents unprivileged users from messing with a
> mounts atime settings.  I have included my test case as the last patch
> in this series so people performing backports can verify this change
> works correctly.
>
> The next change fixes a bug in NFS that was discovered while auditing
> nsproxy users for the first optimization.  Today you can oops the kernel
> by reading /proc/fs/nfsfs/{servers,volumes} if you are clever with pid
> namespaces.  I rebased and fixed the build of the !CONFIG_NFS_FS case
> yesterday when a build bot caught my typo.  Given that no one to my
> knowledge bases anything on my tree fixing the typo in place seems more
> responsible that requiring a typo-fix to be backported as well.
>
> The last change is a small semantic cleanup introducing
> /proc/thread-self and pointing /proc/mounts and /proc/net at it.  This
> prevents several kinds of problemantic corner cases.  It is a
> user-visible change so it has a minute chance of causing regressions so
> the change to /proc/mounts and /proc/net are individual one line commits
> that can be trivially reverted.  Unfortunately I lost and could not find
> the email of the original reporter so he is not credited.  From at least
> one perspective this change to /proc/net is a refgression fix to allow
> pthread /proc/net uses that were broken by the introduction of the network
> namespace.
>
> Eric
>
> Eric W. Biederman (11):
>       namespaces: Use task_lock and not rcu to protect nsproxy
>       mnt: Only change user settable mount flags in remount
>       mnt: Move the test for MNT_LOCK_READONLY from change_mount_flags into do_remount
>       mnt: Correct permission checks in do_remount

This commit breaks libvirt-lxc.
libvirt does in lxcContainerMountBasicFS():

        /*
         * We can't immediately set the MS_RDONLY flag when mounting filesystems
         * because (in at least some kernel versions) this will propagate back
         * to the original mount in the host OS, turning it readonly too. Thus
         * we mount the filesystem in read-write mode initially, and then do a
         * separate read-only bind mount on top of that.
         */
        bindOverReadonly = !!(mnt_mflags & MS_RDONLY);

        VIR_DEBUG("Mount %s on %s type=%s flags=%x",
                  mnt_src, mnt->dst, mnt->type, mnt_mflags & ~MS_RDONLY);
        if (mount(mnt_src, mnt->dst, mnt->type, mnt_mflags &
~MS_RDONLY, NULL) < 0) {

^^^^ Here it fails for sysfs because with user namespaces we bind the
existing /sys into the container
and would have to read out all existing mount flags from the current /sys mount.
Otherwise mount() fails with EPERM.
On my test system /sys is mounted with
"rw,nosuid,nodev,noexec,relatime" and libvirt
misses the realtime...

            virReportSystemError(errno,
                                 _("Failed to mount %s on %s type %s flags=%x"),
                                 mnt_src, mnt->dst, NULLSTR(mnt->type),
                                 mnt_mflags & ~MS_RDONLY);
            goto cleanup;
        }

        if (bindOverReadonly &&
            mount(mnt_src, mnt->dst, NULL,
                  MS_BIND|MS_REMOUNT|MS_RDONLY, NULL) < 0) {

^^^ Here it fails because now we'd have to specify all flags as used
for the first
mount. For the procfs case MS_NOSUID|MS_NOEXEC|MS_NODEV.
See lxcBasicMounts[].
In this case the fix is easy, add mnt_mflags to the mount flags.

         virReportSystemError(errno,
                                 _("Failed to re-mount %s on %s flags=%x"),
                                 mnt_src, mnt->dst,
                                 MS_BIND|MS_REMOUNT|MS_RDONLY);
            goto cleanup;
        }


-- 
Thanks,
//richard
