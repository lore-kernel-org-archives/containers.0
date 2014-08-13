From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Wed, 13 Aug 2014 10:03:47 -0700
Message-ID: <CALCETrWT_p1-5nkiAjWoeta19fkO3rDiJe9_mhRVqF8x1zXv2A@mail.gmail.com>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<53EAD180.4010906@amacapital.net>
	<87sil1nhut.fsf@x220.int.ebiederm.org>
	<CAOP=4widH1rMZ1O=hzAT+M_8exdzRPA8pJ+wH29AQ9L0ogu9nw@mail.gmail.com>
	<87tx5ghekp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tx5ghekp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 13, 2014 at 3:24 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org> writes:
>
>> On Tue, Aug 12, 2014 at 9:17 PM, Eric W. Biederman
> I have a proposed fix as the end of this email.  Could you please
> test it?
>
> If I can get a Tested-by and possibly a Reviewed-by responses I would
> appreciate it.

Will test later today.

>
>> The problem is that users like us had no idea that nodev was being
>> silently added in the first place, and thus didn't know that we needed
>> to specify it in remounts.
>
> Agreed.  And frankly that is extremely reasonable and it would in fact
> break anything doing a traditional tracking of mounts with /etc/mtab.
> So it is a pretty siginificant discontinuity.
>
> I am not prepared to remove the the implicit adding of nodev from the
> implementation as that would just break your code and probably others
> code in a different way.

I'm having trouble figuring out what would break.  The only way to end
up with a device node on one of these filesystems would be to pass an
fd to the file system out of the userns and have some globally
privileged code put the device node there.

>
> What we can do and that will work cleanly long term is make remount
> match mount and implicitly add nodev.
>
>> We create the tmpfs, put some things in it,
>> and then want to remount it read-only for the sandbox. It seems
>> reasonable to expect that a newly-created tmpfs would have exactly the
>> flags I gave it when I created it, not silently get an additional flag
>> that I then need to pass on remount.
>
> A reasonable expectation yes.  At the same time it is also a very
> reasonable security requirement to not allow devices on filesystems
> that the global root does not control.

But the magic nodev isn't needed for that; the checks in mknod are the
right place for this -- they're sufficient, and they're required
anyway.

>
> Compared to Andy's suggestion of relaxing the nodev restriction this
> will also work for filesystems like fuse and nfs when we allow begin to
> allow unprivileged mounts of those filesystems, and it allows to sleep
> better knowing the code is extremely paranoid.

If we allow fuse and nfs, we need to deal with nosuid, too.  I want to
avoid using nosuid for this; I want to change the suid logic to check
the namespace, since I think that suid *should* work in a namespace.

Also, that implicit nodev may be a problem down the road if we ever
add device namespaces.

...

>
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 13 Aug 2014 01:33:38 -0700
> Subject: [PATCH] mnt: Implicitly add MNT_NODEV on remount as we do on mount
>
> Now that remount is properly enforcing the rule that you can't
> remove nodev at least sandstorm.io is breaking when performing
> a remount.
>
> It turns out that there is an easy intuitive solution implicitly
> add nodev on remount under the same conditions that we do on mount.
>
> Update the regression test for remounts to verify that this new
> addition does not regress either.
>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c                                     |  9 ++++
>  .../selftests/mount/unprivileged-remount-test.c    | 51 ++++++++++++----------
>  2 files changed, 36 insertions(+), 24 deletions(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 7886176232c1..0f158300c866 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1934,6 +1934,15 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>         if (path->dentry != path->mnt->mnt_root)
>                 return -EINVAL;
>
> +       /* Only in special cases allow devices from mounts created
> +        * outside the initial user namespace.

I don't like this comment at all.  If we stick with this approach, I
think that this should say:

Certain mounts are forced to have MNT_NODEV set.  For these mounts,
user code might not realize that nodev is set, so force MS_NODEV on
remount attempts to prevent confusing remount failures.

> +        */
> +       if ((mnt->mnt_ns->user_ns != &init_user_ns) &&
> +           !(sb->s_type->fs_flags & FS_USERNS_DEV_MOUNT)) {
> +               flags |= MS_NODEV;
> +               mnt_flags |= MNT_NODEV;
> +       }
> +
>         /* Don't allow changing of locked mnt flags.
>          *
>          * No locks need to be held here while testing the various

I will still advocate a different and much less magical approach.
I'll send a patch later today.

--Andy
