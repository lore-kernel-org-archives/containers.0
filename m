From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [v11][PATCH 8/9] Define clone_with_pids() syscall
Date: Sat, 7 Nov 2009 12:18:10 -0800
Message-ID: <20091107201810.GA26787__21886.4870876589$1257625106$gmane$org@us.ibm.com>
References: <20091105053053.GA11289@us.ibm.com>
	<20091105054124.GH16142@us.ibm.com>
	<20091106180210.GA31652@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091106180210.GA31652-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > +	stack_size = (unsigned long)kca.child_stack_size;
| > +	child_stack = (unsigned long)kca.child_stack_base + stack_size;
| > +
| > +	if (!child_stack)
| > +		child_stack = regs->sp;
| 
| I'm hooking up the s390 version right now.  Do you think you should
| make this
| 
| 	if (!kca.child_stack_base)
| 		child_stack = regs->sp;
| 
| ?
| 
| I suppose that in general if I pass in a NULL kca.child_stack_base
| I'll also pass in a 0 stacksize, but as a user I'd expect that if
| I pass in NULL, the size gets ignored.  Instead, if I pass in NULL
| plus a size, then the kernel will take (void *)size as the stacktop.

Good point. Like copy_thread() on IA64, how about ignoring 'stack_size'
if base is NULL ?

        child_stack = 0UL;
        if (kca.child_stack_base)
                child_stack = (unsigned long)kca.child_stack_base + stack_size;

        if (!child_stack)
                child_stack = regs->sp;

The other question is whether we should force all architectures to pass in
the stack *base* ? clone(2) man page says:

	Stacks grow  downwards  on  all  processors  that  run  Linux (except
	the  HP  PA  processors), so child_stack usually points to the topmost
	address of the memory space set up for the child stack.

To be compatibile with clone() on most architectures, should we rename
'clone_args.child_stack_base' to 'clone_args.child_stack' and let
architectures use this field like they currently use the 'child_stack'
parameter to clone(2) ?

So x86 would pass in address of top-of-stack while HP-PA can pass in address
of base-of-stack.

Arnd, Roland, Peter please let me know if you have any inputs on this.

Sukadev
