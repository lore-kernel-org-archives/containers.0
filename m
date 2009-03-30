From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: remap vdso at original address
Date: Mon, 30 Mar 2009 17:58:44 -0500
Message-ID: <20090330225844.GA1143@us.ibm.com>
References: <20090325143116.GA14040@us.ibm.com>
	<49D0C977.8060807@cs.columbia.edu>
	<20090330145054.GA23411@us.ibm.com>
	<49D0DF07.7030604@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49D0DF07.7030604-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Actually, I think that the get_gate_vma() is broken with randomized vdso
> in the main kernel - it simply won't work just like remapping won't work :)
> It simply didn't show up so far either because no-one is using it, or the
> function is not really important ?

I'm not so sure.  It appears to be just an optimization for the
compat vdso mode.  Well, so long as VDSO_HIGH_BASE isn't a
legitimate address for a user mapping when not in compat vdso
mode, which seems reasonable (0xffffe000U)?

So if not in compat vdso mode, then you don't use gate_vma, but notice
that powerpc for instance always returns 0 for in_gate_area() and NULL
for get_gate_vma().

> Who would be the right person to report this issue ?

Well git-blame suggests that the main people touching that code
have been Ingo and Jeremy.

> > But so for now I'm definately withdrawing this patch.  In the meantime,
> > do we prefer requiring COMPAT_VDSO (using config logic?), or do we
> > prefer resetting the context.vdso on x86 at restart?
> 
> I fear that if we require that, then we forget to un-require it later ...

Nonsense, if people care about it they'll yell.

> Another thing that we should do it transder the vdso page (one copy of
> each page) from the checkpoint and compare to the version available at
> the restart. Yell if differs.

As Matt points out, we'd need an arch-specific comparison function which
ignores the data page.

> (vdso page pointer will be treated as a shared resource - so only copied
> once).

That seems beneficial at least.

thanks,
-serge
