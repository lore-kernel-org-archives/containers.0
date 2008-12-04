From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 04 Dec 2008 07:41:31 -0800
Message-ID: <1228405291.13111.86.camel@nimitz>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.175697908@goodmis.org>
	<m1d4g8un6b.fsf@frodo.ebiederm.org>
	<1228395378.13111.23.camel@nimitz> <1228396022.13111.27.camel@nimitz>
	<m1prk8t5xr.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1prk8t5xr.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dipankar Sarma <dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-12-04 at 05:40 -0800, Eric W. Biederman wrote:
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > On Thu, 2008-12-04 at 04:56 -0800, Dave Hansen wrote:
> >> On Thu, 2008-12-04 at 04:42 -0800, Eric W. Biederman wrote:
> >> > 
> >> > > +static void clear_ftrace_pid_task(struct pid **pid)
> >> > > +{
> >> > > +     struct task_struct *p;
> >> > > +
> >> >         rcu_read_lock();
> >> > 
> >> > > +     do_each_pid_task(*pid, PIDTYPE_PID, p) {
> >> > > +             clear_tsk_trace_trace(p);
> >> > > +     } while_each_pid_task(*pid, PIDTYPE_PID, p);
> >> >         rcu_read_unlock()
> >> > 
> >> > > +     put_pid(*pid);
> >> > > +
> >> > > +     *pid = NULL;
> >> > > +}
> >> 
> >> Could we get away with sticking the rcu_read_{un}lock() inside
> those
> >> macros?  Those are going to get used in pretty high level code and
> we're
> >> allowed to nest rcu_read_lock().  No danger of deadlocks or lock
> >> inversions.
> >
> > Why don't any of the other users of do_each_pid_task() use
> > rcu_read_lock()?  They all seem to be under
> read_lock(&tasklist_lock)
> > (except one is under a write lock of the same).
> 
> We probably should.  Historically read_lock(&tasklist_lock) implies
> rcu_read_lock().  And the tasklist lock is what we hold when it is
> safe.

So, Dipankar tells me that you really do need rcu_read_lock/unlock() for
the guarantee here; the tasklist lock is not sufficient.  The realtime
kernel will preempt even those sections covered by spinlocks.

-- Dave
