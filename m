From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 4/6] mnt: Track when a directory escapes a bind
	mount
Date: Thu, 13 Aug 2015 23:10:26 -0500
Message-ID: <877foymrwt.fsf__3464.20753417096$1439525864$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150810043637.GC14139-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Mon, 10 Aug 2015 05:36:37 +0100")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Mon, Aug 03, 2015 at 04:27:34PM -0500, Eric W. Biederman wrote:
>
>> - The escape count on struct mount must be incremented both before the
>>   rename and after.  If the count is not incremented before the rename
>>   it is possible to hit a scenario where the rename happens the code
>>   walks up the directory tree to somewhere outside of the bind mount
>>   before the count is touched.  Similary without a count after the
>>   rename it is possible for the code to look at the escape count
>>   validate a path is connected before the rename and assume cache the
>>   escape count, leading to not retesting the path is ok.
>
> Umm...  I wonder if you are overcomplicating the things here.  Sure,
> I understand wanting to reduce the checks on "..", but...  It costs you
> considerable complexity (especially when it comes to 64bit counts),
> it's really brittle (you need to be very careful about the places where
> you zero the cached values in fs/namei.c and missing one will lead to
> really unpleasant effects there) _and_ it's all for the benefit of 
> a very rare case.  With check you are optimizing away not being all that
> costly anyway.

I had to give this a long hard think.  Algorithms going to O(N^2) when
it is uncessarry really bother me.  I ran some numbers for really deep
directory trees, slow memory, etc and I could not come up with a
scenario where even in it's worst case d_ancestor would take anywhere
near as long as a one disk seek, and most of the d_ancestor would be
much quicker.

So it appears to me that in the worst case a pathname lookup consisting
of a ridiculous number of .. components starting with a cold cache, on a
mount where a directory has escaped is likely to be faster than a
similar lookup going down the tree with many disk seeks.

I don't think the 64bit counts and the zeroing the cache values are
quite as bad as you make out.  There are much trickier things already in
path name lookup code.  But I do agree that it is easy to get wrong
because nothing will show up in testing, and getting it wrong will have
really unpleasant effects.

I also can't see a scenario where a directory would escape a subtree
that is mounted somewhere without it being a misconfiguration.

So I agree it is not worth it to optimize the code so that there
are an absolute minimum number of d_ancestor calls during pathname
lookup.

Further replacing mnt_escape_count with a mnt_flag makes the code much
simpler.  Which I very much appreciate.

>> - The largest change is in d_unalias, where the two cases are split
>>   apart so they can be handled separately.  In the easy case of a
>>   rename within the same directory all that is needed is __d_move
>>   (escaping a mount is impossible in that case).  In the more involved
>>   case mutexes need to be acquired, and now the spin locks need to be
>>   dropped so that proper lock aquisition order around __d_move can be
>>   arranged.
>
> I _really_ hate that part.  Could you explain WTF is wrong with simply
> taking mount_lock in that case of __d_splice_alias() just outside of
> rename_lock?

Me too.  So upon realizing the that inode->i_lock is held longer than
necessary in d_splice_alias I reworked the locking in d_splice_alias.

Updated patches to follow in a little bit.

> PS: that thing should be in fs/dcache.c, at least in the part that
> deals with finding the common ancestor, etc.  And __d_move() (and
> dentry_lock_for_move()) games with d_ancestor() should be redundant
> now.

It does seem reasonable that the BUG_ONs in __d_move that call
d_ancestor can be removed, or simplified by passing the common ancestor
into __d_move.

I don't know the code in dentry_lock_for_move well enough to say
anything except that the d_ancestor call in dentry_lock_for_move looks
reasonable.

Doing anything inside of __d_move or dentry_lock_for_move appears
to be a detour to the cause of preventing escaping from bind mounts.
So while I have no problems with the with the kinds of changes I hear
you suggesting, but unless I encounter something that makes changing
__d_move or dentry_lock_for_more relevant to the work of preventing
escaping from bind mounts I don't plan on touching them while that
is my focus.

Eric
