From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 12 Aug 2014 19:46:24 -0700
Message-ID: <53EAD180.4010906@amacapital.net>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/05/2014 05:57 PM, Eric W. Biederman wrote:
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

Sorry for catching this late.  I think this fix is likely to
unnecessarily break valid userspace due to an odd interaction.

do_new_mount contains this:

	if (user_ns != &init_user_ns) {
		if (!(type->fs_flags & FS_USERNS_MOUNT)) {
			put_filesystem(type);
			return -EPERM;
		}
		/* Only in special cases allow devices from mounts
		 * created outside the initial user namespace.
		 */
		if (!(type->fs_flags & FS_USERNS_DEV_MOUNT)) {
			flags |= MS_NODEV;
			mnt_flags |= MNT_NODEV | MNT_LOCK_NODEV;
		}
	}

This means that private tmpfs mounts end up with MNT_NODEV |
MNT_LOCK_NODEV.  Certainly the change from MNT_NODEV to MNT_LOCK_NODEV
is sensible *if MNT_NODEV made sense in the first place*.  But we didn't
have MNT_LOCK_NODEV in the past, so this well-intentioned code never
really worked.

This has a very strange effect: mounting a private tmpfs with all
default flags and then remounting with MS_REMOUNT | MS_BIND *without
MS_NODEV* will now fail.  I suspect that this practice is rather common,
since most likely no one ever paid attention to that implicit MNT_NODEV
before.

I would argue that the correct fix is to either remove the implicit
MNT_NODEV entirely or to set FS_USERNS_DEV_MOUNT on most filesystems.

The relevant filesystems are tmpfs, mqueue, sysfs, proc, ramfs, and
devpts.  devpts already sets FS_USERNS_DEV_MOUNT.  Setting
FS_USERNS_DEV_MOUNT should be safe on all of the others in this list --
I think that the only one that initially contains device nodes is sysfs
on selinux systems, which contains a null node.

I think the point of this is to prevent mounts of filesystems with
user-controlled initial contents from being dangerous.  But we don't
have any of those yet.

--Andy
