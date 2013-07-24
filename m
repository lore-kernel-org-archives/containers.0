From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] vfs: Lock in place mounts from more privileged
	users
Date: Tue, 23 Jul 2013 23:50:52 -0700
Message-ID: <87li4wpi2b.fsf@xmission.com>
References: <877gghruwq.fsf@xmission.com>
	<CALCETrXXGhVbkG6AnRck+W1kMns5TJuNYAqe_tV44JvWgDoUzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrXXGhVbkG6AnRck+W1kMns5TJuNYAqe_tV44JvWgDoUzA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Tue, 23 Jul 2013 18:15:03 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Serge does this patch break lxc?  I think all should be well but I want
to make certain there is not some hidden case where this fundamentaly
breaks some functionality.

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Tue, Jul 23, 2013 at 11:30 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> When creating a less privileged mount namespace or propogating mounts
>> from a more privileged to a less privileged mount namespace lock the
>> submounts so they may not be unmounted individually in the child mount
>> namespace revealing what is under them.
>
> I would propose a different rule: if vfsmount b is mounted on vfsmount
> a, then to unmount b, you must be ns_capable(CAP_SYS_MOUNT) on either
> a's namespace or b's namespace.  The idea is that you should be able
> to see under a mount if you own the parent (because it's yours) or if
> you own the child (because you, or someone no more privileged than
> you, put it there).  This may result in a simpler patch and should do
> much the same thing.

It definitely won't result in a simpler patch as the information you are
basing the decision on is not available.

Effectively my patch implements the rule you proposed.

If someone with no more privilege than you put a mount in place (aka the
mount comes from your current user namespace or from a child user
namespace) MNT_LOCKED is not set.

In general mounts happen one at a time and propogate one at a time.  In
which case MNT_LOCKED does not get set on any mount.  I believe the only
time where multiple mounts propogate at once besides the original
unshare of a mount namespace is a mount --rbind.  In the case of a
mount --rbind this patch makes it so that the submounts can not be
unmounted.  Which is again in line with your rule because neither the
top mount nor the lower mount are owned by you.

>> This enforces the reasonable expectation that it is not possible to
>> see under a mount point.  Most of the time mounts are on empty
>> directories and revealing that does not matter, however I have seen an
>> occassionaly sloppy configuration where there were interesting things
>> concealed under a mount point that probably should not be revealed.
>>
>> Expirable submounts are not locked because they will eventually
>> unmount automatically so whatever is under them already needs
>> to be safe for unprivileged users to access.
>>
>> From a practical standpoint these restrictions do not appear to be
>> significant for unprivileged users of the mount namespace.  Recursive
>> bind mounts and pivot_root continues to work, and mounts that are
>> created in a mount namespace may be unmounted there.  All of which
>> means that the common idiom of keeping a directory of interesting
>> files and using pivot_root to throw everything else away continues to
>> work just fine.
>
> Is there some kind of recursive unmount that will get rid of the
> pivot_root result and everything under it?

cd /my/fancy/new/root
pivot_root . /mnt

Will mount the old root on /mnt

umount -l /mnt unmount everything on /mnt.

And that is safe because the mount of /mnt was made in your mount namespace.

> In any case, I think that something like this patch is probably
> -stable material: I suspect that things like seunshare and systemd's
> instance directories are currently insecure.

Given that right now user namespaces are not yet deployed in distro
kernels and even with a deployment it is uncertain if there is anything
exploitable this doesn't feel like stable fodder to me.  However I won't
object if someone else chooses to backport the code.

Eric
