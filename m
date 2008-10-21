From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v7][PATCH 0/9] Kernel based checkpoint/restart
Date: Tue, 21 Oct 2008 13:41:07 -0700
Message-ID: <1224621667.1848.228.camel__22074.8696280227$1224621831$gmane$org@nimitz>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	<20081021122135.4bce362c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081021122135.4bce362c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-10-21 at 12:21 -0700, Andrew Morton wrote:
> On Mon, 20 Oct 2008 01:40:28 -0400
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> > These patches implement basic checkpoint-restart [CR]. This version
> > (v7) supports basic tasks with simple private memory, and open files
> > (regular files and directories only).
> 
> - how useful is this code as it stands in real-world usage?

Right now, an application must be specifically written to use these mew
system calls.  It must be a single process and not share any resources
with other processes.  The only file descriptors that may be open are
simple files and may not include sockets or pipes.

What this means in practice is that it is useful for a simple app doing
computational work.

> - what additional work needs to be done to it?  (important!)
> 
> - how far are we down the design and implementation path with that new
>   work?

We know this design can work.  We have two commercial products and a
horde of academic projects doing it today using this basic design.
We're early in this particular implementation because we're trying to
release early and often.

I think we're at the point where we need a yes or no from the rest of
the community on it.  Reading the patches, I'd hope a reviewer can get
an idea how this will extend to other subsystems.  Do you think the
current patches aren't enough from which to extrapolate how this will be
extended?

> Are we yet at least in a position where we can say "yes, this
> feature can be completed and no, it won't be a horrid mess"?

It will be complete a few months after the rest of the kernel is
complete. :)

From these patches, I think you can see that this will largely be
something that can live off in its own corner of the tree.  We will, of
course, need to do plenty of refactoring of existing code (like the pid
namespaces for instance) to make some of it more accessible from the
outside.  We're also going to look for every opportunity to share code
with other users like the freezer.

-- Dave
