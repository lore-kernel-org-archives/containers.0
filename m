From: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 8/9] Introduce functions to restart a process
Date: Sat, 13 Sep 2008 19:34:19 +0200
Message-ID: <20080913173418.GA8822__26554.5311886401$1221327412$gmane$org@ucw.cz>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<1220439476-16465-5-git-send-email-major@openvz.org>
	<1220439476-16465-6-git-send-email-major@openvz.org>
	<1220439476-16465-7-git-send-email-major@openvz.org>
	<1220439476-16465-8-git-send-email-major@openvz.org>
	<1220439476-16465-9-git-send-email-major@openvz.org>
	<20080903143248.GU14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080903143248.GU14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi!

> > @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
> >  	CFI_ENDPROC
> >  END(ret_from_fork)
> >  
> > +ENTRY(i386_ret_from_resume)
> > +	CFI_STARTPROC
> > +	pushl %eax
> > +	CFI_ADJUST_CFA_OFFSET 4
> > +	call schedule_tail
> > +	GET_THREAD_INFO(%ebp)
> > +	popl %eax
> > +	CFI_ADJUST_CFA_OFFSET -4
> > +	movl (%esp), %eax
> > +	testl %eax, %eax
> > +	jz    1f
> > +	pushl %esp
> > +	call  *%eax
> > +	addl  $4, %esp
> > +1:
> > +	addl  $256, %esp

Can we do something with naming here? resume usually means 'resume
from s2ram'...

> > diff --git a/cpt/rst_process.c b/cpt/rst_process.c
> > new file mode 100644
> > index 0000000..6d47f3c
> > --- /dev/null
> > +++ b/cpt/rst_process.c
> > @@ -0,0 +1,277 @@

....and you are not even consistent. Plus, rst_ will probably be
understood as a reset by most people.

Hmmm... your syscalls get fd. What happens if I pass something like
/proc/self/maps to them?


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
