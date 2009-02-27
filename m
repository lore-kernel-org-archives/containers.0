From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 27 Feb 2009 13:57:06 +0300
Message-ID: <20090227105706.GC2939__19930.7470270016$1235732028$gmane$org@x200.localdomain>
References: <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
	<20090226173302.GB29439@elte.hu>
	<20090226223112.GA2939@x200.localdomain>
	<20090227090323.GC16211@elte.hu>
	<20090227011901.8598d7f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227011901.8598d7f0.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Feb 27, 2009 at 01:19:01AM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 10:03:23 +0100 Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:
> 
> > 
> > * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > 
> > > > I think the main question is: will we ever find ourselves in 
> > > > the future saying that "C/R sucks, nobody but a small 
> > > > minority uses it, wish we had never merged it"? I think the 
> > > > likelyhood of that is very low. I think the current OpenVZ 
> > > > stuff already looks very useful, and i dont think we've 
> > > > realized (let alone explored) all the possibilities yet.
> > > 
> > > This is collecting and start of dumping part of cleaned up 
> > > OpenVZ C/R implementation, FYI.
> > > 
> > >  arch/x86/include/asm/unistd_32.h   |    2 
> > >  arch/x86/kernel/syscall_table_32.S |    2 
> > >  include/linux/Kbuild               |    1 
> > >  include/linux/cr.h                 |   56 ++++++
> > >  include/linux/ipc_namespace.h      |    3 
> > >  include/linux/syscalls.h           |    5 
> > >  init/Kconfig                       |    2 
> > >  kernel/Makefile                    |    1 
> > >  kernel/cr/Kconfig                  |   11 +
> > >  kernel/cr/Makefile                 |    8 
> > >  kernel/cr/cpt-cred.c               |  115 +++++++++++++
> > >  kernel/cr/cpt-fs.c                 |  122 +++++++++++++
> > >  kernel/cr/cpt-mm.c                 |  134 +++++++++++++++
> > >  kernel/cr/cpt-ns.c                 |  324 +++++++++++++++++++++++++++++++++++++
> > >  kernel/cr/cpt-signal.c             |  121 +++++++++++++
> > >  kernel/cr/cpt-sys.c                |  228 ++++++++++++++++++++++++++
> > >  kernel/cr/cr-ctx.c                 |  141 ++++++++++++++++
> > >  kernel/cr/cr.h                     |   61 ++++++
> > >  kernel/cr/rst-sys.c                |    9 +
> > >  kernel/sys_ni.c                    |    3 
> > >  20 files changed, 1349 insertions(+)
> > 
> > That does not look scary to me at all. Andrew?
> 
> I think we'd need to look into the details.  Sure, it's isolated from a
> where-it-is-in-the-tree POV.  But I assume that each of those files has
> intimate and intrusive knowledge of the internals of data structures?

Yes, and this is by design.
