From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sun, 16 Aug 2015 01:22:41 -0500
Message-ID: <87fv3ju4zy.fsf@x220.int.ebiederm.org>
References: <87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
	<CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
	<20150816021209.GI14139@ZenIV.linux.org.uk>
	<CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A@mail.gmail.com>
	<20150816045322.GJ14139@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150816045322.GJ14139-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sun, 16 Aug 2015 05:53:22 +0100")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Sat, Aug 15, 2015 at 07:25:41PM -0700, Linus Torvalds wrote:
>> On Sat, Aug 15, 2015 at 7:12 PM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
>> >
>> > I think you are underestimating the frequency of .. traversals.  Any build
>> > process that creates relative symlinks will be hitting it all the time,
>> > for one thing.
>> 
>> I suspect you're over-estimating how expensive it is to just walk down
>> to the mount-point. It's just a few pointer traversals.
>> 
>> Realistically, we probably do more than that for a *regular* path
>> component lookup, when we follow the hash chains. Following a d_parent
>> chain for ".." isn't that different.
>
> Point, but...  Keep in mind that there's another PITA in there - unreachable
> submounts are not as harmless as Eric hopes.  umount -l of the entire tainted
> mount is a very large hammer _and_ userland needs to know when to use
> it in the first place; otherwise we'll end up with dirty reboots.
> So slightly longer term I want to have something done to them when they become
> unreachable.  Namely, detach and leave in their place a trap that would
> give EINVAL on attempt to cross.  Details depend on another pile of patches
> to review and serialize (nfsd-related fs_pin stuff), but catching the moments
> when they become unreachable is going to be useful (IOW, I don't see how to do
> it without catching those; there might be an elegant solution I'm missing, of
> course).

*Rolls my eyes*

This has to be one of the most inconsistent lines of reasoning I have
ever heard.  Either escaping from a bind mount is as rare as hen's teeth
and our handling of the case is to keep it that way.  Or if they are
common we really need to handle people performing lookups on bind mounts
people have escaped from.

If escaping from bind mounts is as rare as hen's teeth (which it had
better be), then we don't have to be clever, we don't have to be nice,
and umount -l is perfectly sufficient.  And most of the time it really
will be an exit of a mount namespace that blows things away anyway.

Certainly all of the easy to create cases require creating a user
namespace and which onws a mount namespace that a less privileged user
can manipulate.

If you gave someone you don't trust permission to move a directory
under which you have a mount point in the initial mount namespace
and that causes problems I am pretty certain that is a PBKAC error.

But even if I accept that the unmount code has to be done you have been
objecting to the infrastructure that is needed to make it happen.

That is to unmount something we must take namespace_sem from
d_splice_alias.  But more specifically we must call namespace_lock()
and namespace_unlock() from d_splice_alias.  And there are no hacks
like trylock for running synchronize_rcu.  That is we must sleep in
d_splice_alias to unmount things.   Arranging the locks so that it can
happen is what you have rather been strenuously objecting to.

Further if you want to unmount things you can't do it from __d_move
inside the rename_lock.  The logic must be outside the rename_lock.


>> Just looking at the last patch Eric sent, that one looks _trivial_. It
>> didn't need *any* preparation or new rules. Compared to the mess with
>> marking things MNT_DIR_ESCAPED etc, I know which approach I'd prefer.
>> 
>> But hey, if you think you can simplify it... I just don't think that
>> even totally ignoring the d_splice_alias() things, and totally
>> ignoring any locking around __d_move(), the whole "mark things
>> MNT_DIR_ESCAPED" is a lot more complex.
>
> 	Basically what I have in mind is a few helpers called from 
> dentry_lock_for_move() with d_move(), d_exchange() and d_splice_alias()
> doing read_seqlock_excl(&mount_lock); just before grabbing rename_lock and
> dropping it right after dropping rename_lock.

So you are arguing for code that has heavier locking than what I have
done, and you are conveniently ignoring the cost of reviewing all of
the code to see if i_lock is ever taken under mount_lock.

> find_and_taint(dentry, ancestor)
> {
> 	if (!is_dir(dentry))
> 		return;
> 	for (p = dentry->d_parent; p != ancestor; p = next) {
> 		if (unlikely(d_is_someones_root(p)))
> 			taint_mounts_of_this_subtree(p);
> 			// ... with dentry passed there as well when we
> 			// start handling unreachable submounts.
> 		next = p->d_parent;
> 		if (p == next)
> 			break;
> 	}
> }
>
> depth(d)
> {
> 	int n;
> 	for (n = 0; !IS_ROOT(d); d = d->d_parent, n++)
> 		;
> 	return n;
> }
>
> /* find the last common ancestor of d1 and d2; NULL if there isn't one */
> LCA(d1, d2)
> {
You are of course missing the common case and the obvious optimization
here:
	if (d1->d_parent == d2->d_parent)
		return d1->d_parent;

> 	int n1 = depth(d1), n2 = depth(d2);
> 	if (n1 > n2)
> 		do d1 = d1->d_parent; while (--n1 != n2);
> 	else if (n1 < n2)
> 		do d2 = d2->d_parent; while (--n2 != n1);
> 	while (d1 != d2) {
> 		if (unlikely(IS_ROOT(d1)))
> 			return NULL;
> 		d1 = d1->d_parent;
> 		d2 = d2->d_parent;
> 	}
> 	return d1;
> }
>
> dentry_lock_for_move(dentry, target, exchange)
> {
> 	ancestor = LCA(dentry, target);
> 	BUG_ON(ancestor == dentry);	// these BUG_ON are antisocial, BTW
> 	BUG_ON(ancestor == target);

> 	find_and_taint(dentry, ancestor);
> 	if (exchange)
> 		find_and_taint(target, ancestor);
> 	// the rest - as we do now

Which begs the question.  What is the point of doing this in
dentry_lock_for_move.  None of that code has any logical connection to
the function of dentry_lock_for_move.  And if the rest of the logic is
untouched it is just stupid to do the work in dentry_lock_for_move.

> }

Al I am sorry.  I am having a very hard time taking your comments on
code direction seriously at this point.  I have tested working code. 

You have some sort of half thought out proof of concept code that you
have never published.  And you are complaining that my working code is
not your half thought through code.

In my last round of patches that I sent out today.  I did put mount_lock
just outside of rename_lock, in d_splice_alias.  But apparently you
haven't noticed.



Now at this point I have hit the limit of my time available for rewrites
before the merge window.  We can go with my 7 patch variant I posted
today (whose only sin appears not to be your implemenation), it's
trivial reduction that Linus likes because it is simple, someone else
can write one, or this can all wait until the next development cycle.

Given that I have working code with no known defects I was really hoping
I could plug this security hole this development cycle.

Eric
