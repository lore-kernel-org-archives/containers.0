From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Date: Thu, 12 Feb 2009 14:57:37 -0800
Message-ID: <1234479457.30155.214.camel__33249.5237038986$1234479686$gmane$org@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>  <1234467035.3243.538.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1234467035.3243.538.camel@calx>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-02-12 at 13:30 -0600, Matt Mackall wrote:
> On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
...
> >  * Filesystem state
> >   * contents of files
> >   * mount tree for individual processes
> >  * flock
> >  * threads and sessions
> >  * CPU and NUMA affinity
> >  * sys_remap_file_pages()
> 
> I think the real questions is: where are the dragons hiding? Some of
> these are known to be hard. And some of them are critical checkpointing
> typical applications. If you have plans or theories for implementing all
> of the above, then great. But this list doesn't really give any sense of
> whether we should be scared of what lurks behind those doors.

This is probably a better question for people like Pavel, Alexey and
Cedric to answer.  

> Some of these things we probably don't have to care too much about. For
> instance, contents of files - these can legitimately change for a
> running process. Open TCP/IP sockets can legitimately get reset as well.
> But others are a bigger deal.

Legitimately, yes.  But, practically, these are things that we need to
handle because we want to make any checkpoint/restart as transparent as
possible.  Resetting people's network connections is not exactly illegal
but not very nice or transparent either.

> Also, what happens if I checkpoint a process in 2.6.30 and restore it in
> 2.6.31 which has an expanded idea of what should be restored? Do your
> file formats handle this sort of forward compatibility or am I
> restricted to one kernel?

In general, you're restricted to one kernel.  But, people have mentioned
that, if the formats change, we should be able to write in-userspace
converters for the checkpoint files.  

-- Dave
