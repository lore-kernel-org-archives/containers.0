From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 27 Feb 2009 13:59:35 +0300
Message-ID: <20090227105935.GD2939__34224.1657934666$1235732159$gmane$org@x200.localdomain>
References: <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
	<20090226173302.GB29439@elte.hu>
	<20090226223112.GA2939@x200.localdomain>
	<20090227090323.GC16211@elte.hu>
	<20090227012209.65401324.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227012209.65401324.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

On Fri, Feb 27, 2009 at 01:22:09AM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 10:03:23 +0100 Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:
> 
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
> btw, why is there no need for a kernel/cr/cpt-net.c?

Too early :-) There is no rst-*.c counterparts either :-) But I'm
working on this.

But, yes, cpt-net.c will be definitely: all sorts of sockets, virtual
netdevices, iptables, ...
