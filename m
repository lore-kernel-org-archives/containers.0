From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH v2] mm: Add a user_ns owner to mm_struct and fix
	ptrace permission checks
Date: Thu, 27 Oct 2016 21:22:38 -0500
Message-ID: <8760odnrf5.fsf@xmission.com>
References: <20161024105959.GQ1847@uranus.lan> <8760oh8tbp.fsf@xmission.com>
	<20161024202925.GS1847@uranus.lan>
	<CAGXu5jK4p4bbQU1Bu-p9aM1GJ+CAR-FAHZcXXRH0De_M4VQ3wA@mail.gmail.com>
	<8760oh737b.fsf@xmission.com> <20161025090213.GX1847@uranus.lan>
	<87d1ilrdmt.fsf_-_@xmission.com> <20161027213918.GA1922@uranus.lan>
	<20161027223430.GC1922@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161027223430.GC1922-ZmlpmtaulQd+urZeOPWqwQ@public.gmane.org> (Cyrill Gorcunov's message of
	"Fri, 28 Oct 2016 01:34:30 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrey Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Fri, Oct 28, 2016 at 12:39:18AM +0300, Cyrill Gorcunov wrote:
>> On Thu, Oct 27, 2016 at 10:54:34AM -0500, Eric W. Biederman wrote:
>> > 
>> > 
>> > I can't imagine either of these changes making a practical difference
>> > to anyone but I am calling them out in case someone can.
>> > 
>> >  include/linux/mm_types.h |  1 +
>> >  kernel/fork.c            |  9 ++++++---
>> >  kernel/ptrace.c          | 26 +++++++++++---------------
>> >  mm/init-mm.c             |  2 ++
>> >  4 files changed, 20 insertions(+), 18 deletions(-)
>> 
>> Thanks a huge, Eric! And really sorry for delay in response,
>> I managed to miss this quite important mail for me in mail
>> storm. Gonna test it and will write you the results. Overall looks
>> great, but better be sure and run the tests.
>> 
>> Reviewed-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>
> Eric, on which kernel the patch is on top of?
> It doesn't apply on linux-next for some reason.
>
>  | Date:   Thu Oct 27 14:21:59 2016 +1100
>  | 
>  |     Add linux-next specific files for 20161027
>  |     
>  |     Signed-off-by: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
>
> I applied it on Linus' master and tests passed fine
> (but they were passing fine even without the patch,
>  only linux-next failed).

Odd.  I don't think I have taken the old version out of
linux-next yet.   So you can probably revert the old version out of
linux-next and apply this one.  All of my development at this point is
against v4.9-rc1.

I suspect you will find my last version on top of against v4.9-rc1 will
pass.  Since my tree is only one deep and I don't think anyone except
linux-next is based on it, I plan to drop and readd this patch.
Especially since it is candidate for backporting.

Eric
