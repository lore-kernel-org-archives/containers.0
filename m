From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Sun, 16 Aug 2015 06:51:33 -0500
Message-ID: <87egj3moxm.fsf@x220.int.ebiederm.org>
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
	<20150816021209.GI14139@ZenIV.linux.org.uk>
	<CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Sat, 15 Aug 2015 19:25:41 -0700")
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

> On Sat, Aug 15, 2015 at 7:12 PM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
>>
>> I think you are underestimating the frequency of .. traversals.  Any build
>> process that creates relative symlinks will be hitting it all the time,
>> for one thing.
>
> I suspect you're over-estimating how expensive it is to just walk down
> to the mount-point. It's just a few pointer traversals.
>
> Realistically, we probably do more than that for a *regular* path
> component lookup, when we follow the hash chains. Following a d_parent
> chain for ".." isn't that different.
>
> Just looking at the last patch Eric sent, that one looks _trivial_. It
> didn't need *any* preparation or new rules. Compared to the mess with
> marking things MNT_DIR_ESCAPED etc, I know which approach I'd prefer.
>
> But hey, if you think you can simplify it... I just don't think that
> even totally ignoring the d_splice_alias() things, and totally
> ignoring any locking around __d_move(), the whole "mark things
> MNT_DIR_ESCAPED" is a lot more complex.

It occurs to me that there is a fairly simple way we can emperically
test to see how expensive calling is_subdir for every .. on a bind mount
is in practice.

- Take my last patch
- run a benchmark outside of a bind mount (perhaps a kernel compile).
- run the same benchmark inside of a bind mount.

See if the performance differs.

I am going to try to find time to do this, but I am travelling for the
next couple of days.

If someone who has a bit more time wants to try it and beats me to that
would be great.

I think having some emperical numbers would be nice in this part of the
conversation.

Eric
