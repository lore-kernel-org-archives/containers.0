From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v8][PATCH 9/10]: Define clone3() syscall
Date: Thu, 22 Oct 2009 11:10:47 -0700
Message-ID: <20091022181047.GA21628__10549.5634525598$1256235071$gmane$org@us.ibm.com>
References: <20091016042041.GA7220@us.ibm.com>
	<cfd18e0f0910152325m4a9125c2q18f36f5bd7d4a0@mail.gmail.com>
	<20091016180631.GA31036@us.ibm.com>
	<20091019174405.GE27627@count0.beaverton.ibm.com>
	<4ADCDAA8.5080408@zytor.com>
	<20091019235012.GF27627@count0.beaverton.ibm.com>
	<cfd18e0f0910202126w1ebfa2e2u2ecbaa23b198d100@mail.gmail.com>
	<4ADF06B7.50508@zytor.com> <20091021194440.GA1283@us.ibm.com>
	<cfd18e0f0910220340n7c655daap78e395136c56f882@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cfd18e0f0910220340n7c655daap78e395136c56f882-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Michael Kerrisk [mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org] wrote:
| Sukadev,
| =

| On Wed, Oct 21, 2009 at 9:44 PM, Sukadev Bhattiprolu
| <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
| > H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
| >> On 10/21/2009 01:26 PM, Michael Kerrisk wrote:
| >>>
| >>> My question here is: what does "3" actually mean? In general, system
| >>> calls have not followed any convention of numbering to indicate
| >>> successive versions -- clone2() being the one possible exception that
| >>> I know of.
| >>>
| >>
| >> "3" is number of arguments.
| >
| > To me, it is a version number.
| =

| See my precending mail. Isn't the number of arguments "2".

Well it was 2 at one point, but I have posted a new version of
just that one patch - please see http://lkml.org/lkml/2009/10/16/3
for comments.

I am working on some updates and will post a new patchset - it
will have 3 parameters to clone3() as shown in the above mail.

| =

| > mmap() and mmap2() both have 6 parameters.
| >
| > Besides if wait4() were born before wait3(), would it still be wait4() =
:-)
| > But I see that it is hard to get one-convention-that-fits-all.
| =

| Yes -- that's exactly right.
| =

| >> It's better than "extended" or something
| >> like that simply because "extended" just means "more than", and a numb=
er
| >> at least tells you *how much more than*.
| >
| > And extended assumes we wont extend again.
| =

| Well, if we do things right in this design, we may not need to ever
| extend (by creating a new syscall) again. That's why I mentioned the
| "flags" argument idea. Did you give this some thought?

Yes, we have done the best we can to avoid extending clone() again
anytime soon (some reserved bytes and clone_args_size field). Would
we still need the flags parameter ? Again its in the new patch
that I pointed to above.

| =

| > An informal poll of reviewers has clone3() with a slight advantage :-)
| >
| > =A0 =A0 =A0 =A0clone_extended() camp: Serge Hallyn, Kerrisk, Louis Rill=
ing,
| > =A0 =A0 =A0 =A0clone3(): Sukadev, H. Peter Anvin, Oren, Matt Helsley.
| >
| > I like clone3() but am not insisting on it. I just want a name...
| =

| And I'm not really insisting on a change. As you rightly point out,
| there is much inconsistency in the naming conventions that have been
| used over the years.
| =

| But, because there has been no consistency in the use of numbers, and
| because the number of arguments that are presented in a glibc
| interface may differ from the number of arguments in an underlying
| syscall (several precedents: signalfd4(), pselect(), ppoll()), I'm
| inclined to think that clonex() or clone_ext() is slighly better than
| clone3(). But, certainly, my arguments are not compelling.
