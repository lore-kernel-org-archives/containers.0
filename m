From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Thu, 8 Jan 2015 00:22:27 +0000
Message-ID: <20150108002227.GC22149__16535.3853990839$1420676592$gmane$org@ZenIV.linux.org.uk>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
	<87iogi8dka.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87iogi8dka.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 07, 2015 at 03:51:17PM -0600, Eric W. Biederman wrote:

> I disagree with how you have described the current rules.

In which situation that description does not match what we do?

> Currently the reference count on a struct mount is:
> 
> - incremented by 1 for every child listed in mnt_mounts.

Yes - their ->mnt_parent does it.

> - incremented by 1 for every oridinary user that does not know
>   the intimate details of how mounts are implemented.

That'd be references other than ->mnt_parent.

> - incremented by 1 if the mount is on the mnt_list and is mounted.

== reachable from hashtable, except that you include the reference from
namespace to its root mount into that; in my description that goes as
external reference.

> - Mounts that have been unmounted do not mounted do not have children.

Meaning?

> What I have introduced is state where a mount that is unmounted has
> children, and the connection between the mount and those children
> remain in the mount hash table.
> 
> In this new case it becomes possible for a mount with children to reach
> the final mntput.

> In this new case an unmounted mount with children that reaches mntput
> will hold a reference to each of it's children until it reaches mntput,
> and there the reference will be dropped.
> 
> To get into that state in umount_tree the code drops the reference to the
> parent from children as normal.  The code repairs the child list which
> was torn down early.  The code takes mnt_list and sets mnt_ns = NULL so
> the mount is clearly unmounted.  The reference count from being mounted
> is given to the mount parent.
> 
> 
> At the parents final mntput the children are walked through and removed
> from the mount hash table, and in cleanup_mnt where we don't have an
> ultra deep stack and are not holding locks, the dentry is dput and
> and the child mount is mntput.

You are describing what your code does.  Thank you, but I *can* read C just
as easy as your text (easier, TBH).  What I'm asking for is data structures
invariants.  As in, "outside of such and such locks, the following predicates
are true"...

If I understand what you are saying, you have
	* subset of mounts (ones that had MNT_LOCKED and went through
MNT_DETACH umount).
	* mounts in that subset are
		* hashed
		* present in their parents' lists of children
		* do _NOT_ contribute to parents' refcounts
		* do _NOT_ participate in event propagation
		* removed from the lists of children and dropped upon
parent's final mntput (dropping being done on shallow stack, just before the
fs shutdown of parent).

I can buy that, *IF* one could add
		* are guaranteed to be unreachable from any namespace root.
to the above.  And yes, your logics around marking them is probably enough
for that.  However, if we go that way, I don't understand why do we need
to involve MNT_LOCKED.

Look: your new rules for that subset are actually not that different from
the old ones - they *are* hashed, so by the old rules we'd added 1 to
refcount anyway.  The only period when that is not true is from __detach_mnt()
in mntput_no_expire() to cleanup_mnt().  The real difference, AFAICS, is
that their ->mnt_parent does not contribute to refcount of its targets.

If the root of such a detached tree gets the last reference dropped,
it gets killed as usual *and* its children become roots of detached trees.
That is protected by mount hash lock (which prevents somebody inside a subtree
from traversing .. and grabbing a reference to root after we'd started to
detach stuff from it).

Fine, that makes sense, but IMO it would make a lot of sense to have a variant
of MNT_DETACH that would do that for *all* mounts, locked or not.  I'd be
tempted to make MNT_DETACH itself do that, except that the current behaviour
(dropping eagerly) is useful in situations like "we have a stuck filesystem
and a bunch of stuff under it; let's do umount -l on that shit, hopefully
the non-busy filesystems mounted down there will get a clean shutdown out
of that".

I seriously dislike your use of path_put() on mnt_ex_mountpoint - it's
actively misleading.  We bloody better _not_ have non-NULL
->mnt_ex_mountpoint.mnt in your cleanup_mnt(), for obvious reasons.  So
it's just dput() + do something random if non-NULL mnt found.

Not sure if I like the use of mnt_child between mntput_no_expire() and
cleanup_mnt() - it's probably safe, but the fewer lists we modify outside of
mount hash lock, the better; hell knows, I'll need to stare at that code
a bit more.  FWIW, AFAICS the refcount rules with your variant are
	* external references countribute
	* mnt_parent contributes unless it points to ourselves *or* mnt_ns is
NULL
	* reachable from mount hash => add 1
	* in addition to the wart around namespace_unlock(), we have a similar
wart between mntput_no_expire() and cleanup_mnt(), only there we thread the
suckers on mnt_child instead of mnt_list and use slightly different logics to
prevent shutdown of parent fs before the dput(mountpoint).

I really hate synchronize_rcu() in namespace_unlock() ;-/  Not your fault,
but it's a PITA every time one does analysis of all that code...  It's
about legitimize_mnt() vs. umount() - we want to make sure that any
transient bumps of refcount from attempts to legitimize a lazy reference
to vfsmount getting killed by umount() will be undone *before* we get to
mntput_no_expire() in namespace_unlock().  It's only an issue for sync
umounts, so we are fine here, but it definitely needs commenting upon -
some vfsmounts *can* escape it with that approach, but they are not going
to be marked sync-umount, so we don't need to worry about them...
