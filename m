From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Mon, 17 Aug 2015 00:29:29 +0200
Message-ID: <20150816222929.GA13710__30507.2014256895$1439764776$gmane$org@1wt.eu>
References: <20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
	<CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
	<20150816021209.GI14139@ZenIV.linux.org.uk>
	<CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A@mail.gmail.com>
	<87egj3moxm.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87egj3moxm.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Aug 16, 2015 at 06:51:33AM -0500, Eric W. Biederman wrote:
> It occurs to me that there is a fairly simple way we can emperically
> test to see how expensive calling is_subdir for every .. on a bind mount
> is in practice.
> 
> - Take my last patch
> - run a benchmark outside of a bind mount (perhaps a kernel compile).
> - run the same benchmark inside of a bind mount.
> 
> See if the performance differs.
> 
> I am going to try to find time to do this, but I am travelling for the
> next couple of days.
> 
> If someone who has a bit more time wants to try it and beats me to that
> would be great.
> 
> I think having some emperical numbers would be nice in this part of the
> conversation.

I took a bit of time to do something simpler though less scientific : I
just ran a kernel build under strace -c -f to get a rough idea of the
number of syscalls. It takes 2m23 without strace and 3m00 under strace.
7.2M syscalls were seen out of which only 3.2M were related to FS access
(mostly open(), fstat() and stat()), the rest is minor. That's 22k
syscalls per second, or 45 us between two syscalls. From this point I'm
having a hard time imagining that any extra tests in the code path would
have a significant impact to cause a measurable difference compared to
these 45us, especially since I'm counting all FS accesses (worst case)
and not just those referencing "..".

Just my two cents,
Willy
