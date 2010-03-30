From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH tip/core/urgent] rcu: protect fork-time cgroup access
Date: Tue, 30 Mar 2010 10:26:50 -0700
Message-ID: <20100330172650.GJ2513__28314.1793952838$1269970065$gmane$org@linux.vnet.ibm.com>
References: <20100330093204.GP3345@count0.beaverton.ibm.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100330093204.GP3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dvhltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, abogani-c2gU+FDvWfqonA0d6jMUrA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 30, 2010 at 02:32:04AM -0700, Matt Helsley wrote:
> > On Mon, Mar 29, 2010 at 11:42:55PM +0200, Peter Zijlstra wrote:
> > > On Mon, 2010-03-29 at 14:34 -0700, Paul E. McKenney wrote:
> > >
> > > > And it appears that my patch is at best insufficient:
> > > > http://paste.ubuntu.com/406189/
> > > >
> > > > Left to myself, I would wrap copy_process() with rcu_read_lock(),
> > > > but I would rather hear your thoughts before doing too much more
> > > > semi-random hacking.  ;-)
> > >
> > > Well, I don't think you can get away with that, copy_process() wants to
> > > sleep on quite a few places ;-) Also, locks should be taken at the
> > > smallest possible scope, unless we want to go back to BKL style
> > > locking :-)
> > 
> > No argument here!  ;-)
> > 
> > > As to that freezer splat, you'd have to chase down the cgroup folks, I'm
> > > fully ignorant on that.
> > 
> > K, adding them to CC.  The two splats are:
> > 
> >        http://pastebin.ubuntu.com/406131/
> >         http://paste.ubuntu.com/406189/
> 
> Please feel free to Cc me on cgroup freezer stuff.
> 
> There's a comment in the code explaining why it's not used in freezer_fork():
> 
>        /*
>         * No lock is needed, since the task isn't on tasklist yet,
>         * so it can't be moved to another cgroup, which means the
>         * freezer won't be removed and will be valid during this
>         * function call.
>         */
> 	freezer = task_freezer(task);

Good to know, thank you!

So the cgroup that this task is associated with cannot be deleted in
the meantime?

							Thanx, Paul
