From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sun, 16 Aug 2015 03:12:09 +0100
Message-ID: <20150816021209.GI14139@ZenIV.linux.org.uk>
References: <877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
	<87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
	<CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Sat, Aug 15, 2015 at 03:47:50PM -0700, Linus Torvalds wrote:
> So the cost I worry about is not the CPU cost, but the complexity and
> correctness. If anything goes subtly wrong, the end result is going to
> be some very very subtle bugs.
> 
> And personally, I'd be much happier with something that is a bit more
> straightforward, even if it makes ".." lookup slower. Especially since
> I think we can limit the costs to fairly obvious cases (ie only for
> partial bind mounts). Keep the code more straightforward, and *if* we
> ever see the cost of dentry traversal
> 
> But it's up to Al, I think.
> 
> Al, comments?

I think you are underestimating the frequency of .. traversals.  Any build
process that creates relative symlinks will be hitting it all the time,
for one thing.  And less-than-entire-fs mounts are not something pathological -
I've got quite a few here, things like container setups often create such
beasts, etc.  Not to mention that things like NFSv4 will often look like such
partial mounts, BTW.

I really don't understand why the hell do we need *anything* complicated
around __d_move() callers - just take sodding spinlock of mount_lock in
the (few) callers around rename_lock, and that's it.  No need for anything
subtle and brittle.

Redoing the locking in d_splice_alias() simply doesn't belong anywhere near
that work.

Basically, all places where we change tree topology go through __d_move()
(and take rename_lock around it).  There are very few of those.  And we
can find and taint affected mounts quite easily - I think we all agree that
beginning of that series looks sane (locating mounts by mnt_root), right?

Let's just add "mount_lock should be held read-exclusive by all callers of
__d_move()" and do the find-and-taint logics from
dentry_lock_for_move().  Move these
        BUG_ON(d_ancestor(dentry, target));
        BUG_ON(d_ancestor(target, dentry));
into dentry_lock_for_move(), while we are at it.  And have it begin with
finding the last common ancestor of dentry and target.  Which turns those
checks into ancestor == dentry and ancestor == target...  Then we need to
taint everything with root being an ancestor of dentry, but not an ancestor
of target.  Which is trivial with LCA already found.  For exchange case we
need to do that both for dentry and target, of course.  That's it.  After that
we just use that taint instead of "is it a partial?" in .. handling.
