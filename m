From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 04:53:57 -0700
Message-ID: <20100326115357.GA3345__29056.3018680134$1269606928$gmane$org@count0.beaverton.ibm.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100326111131.GA8604-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 26, 2010 at 12:11:31PM +0100, Oleg Nesterov wrote:
> On 03/25, Grzegorz Nosek wrote:
> >
> > On wto, mar 23, 2010 at 02:28:34 -0700, Matt Helsley wrote:
> > > On Sun, Mar 21, 2010 at 08:50:44PM +0100, Grzegorz Nosek wrote:
> > >
> > > <snip>
> > >
> > > > 2. Weird strace behaviour across pidns boundary
> > > >
> > > > When strace'ing (with -ff) lxc-start, I get a proper strace for the
> > > > directly spawned process and the container init. However, any processes
> > > > spawned by the container's init are not straced properly
> 
> Yes, this is broken. More precisely, this wasn't even supposed to work.
> 
> Even stracing of the sub-init itself (or global init btw) has problems,
> the straced init is not protected from unwanted signals.
> 
> > > I'm suprised strace of ls works across pid namespaces. I've been looking
> > > at strace and it seemed to me that one kernel change and a bunch of strace
> > > changes are needed to make strace'ing in child pid namespaces work.
> 
> Yes. First of all, tracehook_report_clone_complete() reports the wrong pid nr,
> as it seen inside the init's namespace. This is easy to fix, but I doubt this
> can help. IIRC strace doesn't use PTRACE_GETEVENTMSG at all, it looks at eax
> after syscall.

Yup. strace would need to be modified to use that. I tried that and it still
won't work -- I seem to recall it didn't work because strace uses pid values
obtained from the wait syscall too. To make it work we'd need to be able to
translate those pids in userspace. That's do-able from userspace if you trace
all forks descending from the pidns init task. But it's not do-able for
simple attaches. That's why I was thinking Eric's setns() might be able to
help if strace used it to enter the tracee's pid namespace whenever we need to.

gdb often doesn't use the same methods but has similar problems with pid
namespaces.

Cheers,
	-Matt Helsley
