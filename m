From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sun, 16 Aug 2015 06:33:21 -0500
Message-ID: <87bne7piwu.fsf@x220.int.ebiederm.org>
References: <874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
	<CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
	<20150816021209.GI14139@ZenIV.linux.org.uk>
	<CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A@mail.gmail.com>
	<20150816045322.GJ14139@ZenIV.linux.org.uk>
	<87fv3ju4zy.fsf@x220.int.ebiederm.org>
	<20150816065503.GL14139@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150816065503.GL14139-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sun, 16 Aug 2015 07:55:03 +0100")
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

> On Sun, Aug 16, 2015 at 01:22:41AM -0500, Eric W. Biederman wrote:
>
>> In my last round of patches that I sent out today.  I did put mount_lock
>> just outside of rename_lock, in d_splice_alias.  But apparently you
>> haven't noticed.
>
> I have.  The problem I have with that one is that you end up with duplicated
> logics rather than taking it to one place.

We are talking about a very small duplication of code.  But you are also
talking about combining logic that can get you in trouble pretty easily.

As I read the code sketch you posted it had the issue that if a
disconnected dentry was also a mount point it would mark that mount
point as escaped (because there was no common ancestor).

In the split out logic I don't even bother because you trivially can't
have escaped from anywhere when IS_ROOT(dentry).

>> Now at this point I have hit the limit of my time available for rewrites
>> before the merge window.  We can go with my 7 patch variant I posted
>> today (whose only sin appears not to be your implemenation), it's
>> trivial reduction that Linus likes because it is simple, someone else
>> can write one, or this can all wait until the next development cycle.
>
> ... or either of us can do merging those checks into a single place,
> be it as a followup to your 7-patch series, or folded with the
> fs/dcache.c-affecting patches in there.  If you have no time left, I can
> certainly do that followup myself - not a problem[1]

I don't have time.  Everytime I have worked with this it has take pretty
much full days of staring at the code, and I don't have any more full
days left before the merge window.

> And umount-related followups are just that - I'm not asking you to do those,
> especially since as I said this stuff is sensitive to fs_pin details (so far
> it appears to fold nicely with the __detach_mounts()/umount_tree() stuff,
> BTW).
>
> PS: it doesn't need namespace_sem taken inside __d_move() - actual
> detaching does, of course, but that part gets done via task_work_add(),
> in a reasonably sane locking environment.

The part that boggles my mind about that whole approach is that just
outside of rename_lock there already is a sane locking environment.

Admittedly it will take a touch of work in d_splice_alias to get it
sane, but that isn't particularly hard.

	write_seqlock(&rename_lock);
        if (!IS_ROOT(new))
		__d_unalias(...);

__d_unalias(...)
{	
        /* Parent's don't go away so !IS_ROOT(new) will stay valid */
        write_sequnlock(&rename_lock);
        /* Hooray! The code can be normal and sleep if it needs to,
         * before calling into __d_move.
         */
         ...
         d_move();
}

Similarly for duplicate logic removal.  Teaching d_splice_alias when
it is performing an ordinarly rename to be able to just call d_move
gets you far more from a maintenance perspective than cramming
everything into __d_move.

> [1] with credits for your patches preserved - normally I would assume that
> this goes without saying, but your reply seems to imply that I'm playing some
> kind of political BS games, so I'd rather spell that out.

My issue wasn't political games, but rather holding code to an
apparently BS standard.

Eric
