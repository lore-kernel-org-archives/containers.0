From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: remap vdso at original address
Date: Mon, 30 Mar 2009 09:50:54 -0500
Message-ID: <20090330145054.GA23411@us.ibm.com>
References: <20090325143116.GA14040@us.ibm.com>
	<49D0C977.8060807@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49D0C977.8060807-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> 
> 
> Serge E. Hallyn wrote:
> > Well, here is my current attempt at properly handling vdso for
> > the x86 and s390 c/r code.  I was going to test with gettimeofday,
> > but x86 doesn't use vdso for that, and I'm still recompiling glibc
> > on s390 to exploit vdso for it.  So what I can tell so far is that
> > CONFIG_COMPAT_VDSO=n is now save on x86 - the kernel vdso segment
> > is re-mapped from the kernel into the checkpointed location, so
> > the fact that the task was started with a random vdso base doesn't
> > matter.
> > 
> > Once I get a proper testcase, I intend to show that checkpointing
> > a testcase which does gettimeofday(), waiting 10 seconds, and
> > then restarting it, will end up with bad __vdso_gettimeofday()
> > results without this patch, and good ones with it.
> 
> It will be helpful if you split the patch into non-c/r changes (i.e.
> add a parameter to request mapping for vdso), following by c/r changes
> per architecture.

Actually, since sending this patch I've been trying to exercise the
vdso on 4 different systems (s390, x86, powerpc).  Only on powerpc
was i able to confirm vdso was being used, and there not having this
patch made zero difference.

So right now I'm thinking the only thing that is needed is to either
demand COMPAT_VDSO=y on x86, or to take the part of this patch where
we reset context.vdso.

> Also, I noticed that it may be more complicated. For example, the
> function get_gate_vma() (at least on x86) test the value of context.vdso
> against some constant to decide on the return value. I don't know if
> this will break if the vdso of a task ends up being something that the
> system didn't expect it to be ?

Yeah that logic will need a tweak, thanks.

But so for now I'm definately withdrawing this patch.  In the meantime,
do we prefer requiring COMPAT_VDSO (using config logic?), or do we
prefer resetting the context.vdso on x86 at restart?

thanks,
-serge
