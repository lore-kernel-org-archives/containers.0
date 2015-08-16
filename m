From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sat, 15 Aug 2015 19:59:39 -0500
Message-ID: <87bne82glg.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
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
In-Reply-To: <CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Sat, 15 Aug 2015 15:47:50 -0700")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Sat, Aug 15, 2015 at 2:07 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> Yes we can compare s_root and mnt_root and only call is_subir  if they don't match.
>
> Not even "is_subdir()" - for the RCU traversal case, just d_ancestor()
> should be sufficient since we'd already be in an RCU read-locked
> region and the RCU lookup checks the rename sequence number around it
> all.

We check the dentry sequence number and the mount sequence number, which
may be enough to catch a local rename but is certainly not enough to
catch what d_ancestor cares about.

Further we have the partial rcu to non-rcu walk case represented by
unlazy_walk that means we can't blithely do something that might be
wrong and only check the sequence numbers at each step.

> And d_ancestor() should really be pretty low-cost - even *if* we have
> to call it, which wouldn't even be the case for the normal situation.

>
>> At this point it is a matter of trade offs.
>>
>> If there is not an escape I do not expect my current implementation will have a measurable cost.
>> And I don't expect there will be any escapes.
>
> So the cost I worry about is not the CPU cost, but the complexity and
> correctness. If anything goes subtly wrong, the end result is going to
> be some very very subtle bugs.

Fair enough.  I like simple low complexity code, but I don't want to
mess up the pathname lookup fastpath.

> And personally, I'd be much happier with something that is a bit more
> straightforward, even if it makes ".." lookup slower. Especially since
> I think we can limit the costs to fairly obvious cases (ie only for
> partial bind mounts). Keep the code more straightforward, and *if* we
> ever see the cost of dentry traversal
>
> But it's up to Al, I think.
>
> Al, comments?

At the very beginning of this I got shot down by Al Viro for a simple
implementation that essentially had everything except the check for
being a bind mount.  Knowing what I know now I realize it was a bit
buggy, calling d_ancestor in the rcu walk instead of d_subdir, but it
was shot down for the cpu cost.  Then Al suggested the basic approach I
have taken in these patches.

As soon as I am done testing I am going to post the revised version of
my final patch that only performs is_subdir checks on bind mounts.

Then we can decide to merge whichever version of the code you and Al are
happy with.

Eric
