From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Wed, 07 Jan 2015 15:51:17 -0600
Message-ID: <87iogi8dka.fsf@x220.int.ebiederm.org>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150107205239.GB22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Wed, 7 Jan 2015 20:52:40 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Wed, Jan 07, 2015 at 01:30:22PM -0600, Eric W. Biederman wrote:
>
>> > Explicit description of your new refcounting rules, please.  What's more,
>> > how do those non-pinning children interact with e.g. copy_tree()?
>> 
>> The parents hold a reference on the children, and the parent keeps track
>> of it's children through the mnt_mounts list.  The parents reference to
>> a child is held until the final mntput of the parent.
>
> This is obvious crap.  It doesn't match the resulting code, not to mention
> making no sense whatsoever.
>
> If you (with your resulting tree) mount ten filesystems on /tmp/[0-9],
> you will have refcount of vfsmount on /tmp incremented by 10.  Moreover,
> you really don't want /tmp *not* to be busy after having done that.

You are complaining that I did not describe the part of the rules that
are not new?

> The current rules are
> 	* take the number of external references
> 	* add 1 if it's reachable from hash table
> with mnt->mnt_parent being a counting reference unless it points to mnt
> itself.
> One extra wart is namespace_unlock() treatment of ex-mountpoints - we
> have decremented their refcounts early (during umount_tree()) to avoid
> false positives on "is it busy" checks, but once we are done with calculating
> the set of victims we want proper ordering on the fs shutdown vs dput() of
> mountpoints, so namespace_unlock() starts with unrolling these decrements
> and then replays them in proper order.
>
> You have modified that, but your description above doesn't match what you
> are doing.  Moreover, in absense of those locked-and-lazy you *still* have
> the same rules as before.  Full description of the new rules, please.

Al I think you are big pig headed to be pig headed, you don't see to be
trying to understand so I don't know if this conversation will be
productive.  I did describe how the rules change in the specific case
that they change which is what I though you were asking for.


I disagree with how you have described the current rules.

Currently the reference count on a struct mount is:

- incremented by 1 for every child listed in mnt_mounts.
- incremented by 1 for every oridinary user that does not know
  the intimate details of how mounts are implemented.
- incremented by 1 if the mount is on the mnt_list and is mounted.
- Mounts that have been unmounted do not mounted do not have children.


What I have introduced is state where a mount that is unmounted has
children, and the connection between the mount and those children
remain in the mount hash table.

In this new case it becomes possible for a mount with children to reach
the final mntput.

In this new case an unmounted mount with children that reaches mntput
will hold a reference to each of it's children until it reaches mntput,
and there the reference will be dropped.

To get into that state in umount_tree the code drops the reference to the
parent from children as normal.  The code repairs the child list which
was torn down early.  The code takes mnt_list and sets mnt_ns = NULL so
the mount is clearly unmounted.  The reference count from being mounted
is given to the mount parent.


At the parents final mntput the children are walked through and removed
from the mount hash table, and in cleanup_mnt where we don't have an
ultra deep stack and are not holding locks, the dentry is dput and
and the child mount is mntput.


For fs/namespace.c not a particularly complicated scenario, and not
particulary weird.  And a scenario that matches the description
a parent holds a reference to the child instead of the other way around.

Now that I have fleshed out my description if you continue to think it
is obvious crap and doesn't match the resulting code, your analysis
is bollocks.

Eric
