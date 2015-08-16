From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sun, 16 Aug 2015 05:53:22 +0100
Message-ID: <20150816045322.GJ14139@ZenIV.linux.org.uk>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Sat, Aug 15, 2015 at 07:25:41PM -0700, Linus Torvalds wrote:
> On Sat, Aug 15, 2015 at 7:12 PM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
> >
> > I think you are underestimating the frequency of .. traversals.  Any build
> > process that creates relative symlinks will be hitting it all the time,
> > for one thing.
> 
> I suspect you're over-estimating how expensive it is to just walk down
> to the mount-point. It's just a few pointer traversals.
> 
> Realistically, we probably do more than that for a *regular* path
> component lookup, when we follow the hash chains. Following a d_parent
> chain for ".." isn't that different.

Point, but...  Keep in mind that there's another PITA in there - unreachable
submounts are not as harmless as Eric hopes.  umount -l of the entire tainted
mount is a very large hammer _and_ userland needs to know when to use
it in the first place; otherwise we'll end up with dirty reboots.
So slightly longer term I want to have something done to them when they become
unreachable.  Namely, detach and leave in their place a trap that would
give EINVAL on attempt to cross.  Details depend on another pile of patches
to review and serialize (nfsd-related fs_pin stuff), but catching the moments
when they become unreachable is going to be useful (IOW, I don't see how to do
it without catching those; there might be an elegant solution I'm missing, of
course).

> Just looking at the last patch Eric sent, that one looks _trivial_. It
> didn't need *any* preparation or new rules. Compared to the mess with
> marking things MNT_DIR_ESCAPED etc, I know which approach I'd prefer.
> 
> But hey, if you think you can simplify it... I just don't think that
> even totally ignoring the d_splice_alias() things, and totally
> ignoring any locking around __d_move(), the whole "mark things
> MNT_DIR_ESCAPED" is a lot more complex.

	Basically what I have in mind is a few helpers called from 
dentry_lock_for_move() with d_move(), d_exchange() and d_splice_alias()
doing read_seqlock_excl(&mount_lock); just before grabbing rename_lock and
dropping it right after dropping rename_lock.

find_and_taint(dentry, ancestor)
{
	if (!is_dir(dentry))
		return;
	for (p = dentry->d_parent; p != ancestor; p = next) {
		if (unlikely(d_is_someones_root(p)))
			taint_mounts_of_this_subtree(p);
			// ... with dentry passed there as well when we
			// start handling unreachable submounts.
		next = p->d_parent;
		if (p == next)
			break;
	}
}

depth(d)
{
	int n;
	for (n = 0; !IS_ROOT(d); d = d->d_parent, n++)
		;
	return n;
}

/* find the last common ancestor of d1 and d2; NULL if there isn't one */
LCA(d1, d2)
{
	int n1 = depth(d1), n2 = depth(d2);
	if (n1 > n2)
		do d1 = d1->d_parent; while (--n1 != n2);
	else if (n1 < n2)
		do d2 = d2->d_parent; while (--n2 != n1);
	while (d1 != d2) {
		if (unlikely(IS_ROOT(d1)))
			return NULL;
		d1 = d1->d_parent;
		d2 = d2->d_parent;
	}
	return d1;
}

dentry_lock_for_move(dentry, target, exchange)
{
	ancestor = LCA(dentry, target);
	BUG_ON(ancestor == dentry);	// these BUG_ON are antisocial, BTW
	BUG_ON(ancestor == target);
	find_and_taint(dentry, ancestor);
	if (exchange)
		find_and_taint(target, ancestor);
	// the rest - as we do now
}
