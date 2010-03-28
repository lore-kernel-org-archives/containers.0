From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: --freezer option to /bin/restart
Date: Sun, 28 Mar 2010 16:32:54 -0500
Message-ID: <20100328213254.GA12661@us.ibm.com>
References: <20100327191453.GA1533@us.ibm.com>
	<4BAF72C6.1020806@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BAF72C6.1020806-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Sukadev Bhattiprolu wrote:
> > The help message for --freezer=CGROUP option says:
> > 
> > 	freeze tasks in freezer group CGROUP on success
> > 
> > and if this option specifies an existing cgroup, then (and only
> > then) is the RESTART_FROZEN flag to sys_restart() set.
> > 
> > Does the --freezer option have to specify an existing cgroup ?
> 
> As it is now - yes;
> 
> In theory I would like use -F (--freezer) without an  argument,
> to use RESTART_FROZEN without explicitly adding tasks to a
> target cgroup.
> 
> The trick is that we need to put all the restarted tasks in the
> traget cgroup. The coordinator must remain outside that cgroup,
> or it will be frozen as well when restart succeeds.
> 
> This means that restarted tasks (at least the root task) have
> to be explicitly added to the cgroup - which is why I require
> that the cgroup name be passed.
> 
> This could be avoided if we could add 'restart' to a cgruop and
> then after spawning the entire tree, we could remove 'restart'
> from that cgroup. I don't think this is possible ?

Why not?  You can certainly move to freezer:/restart.XYZ, spawn
tasks, then move back to freezer:/.  And since the tasks should
hang in sys_restart() until the coordinator calls sys_restart()
itself, there should be no race issues.  Do you mean that something
else won't work?

> > Is there a way to specify that the restarted application belong
> > to a new (yet-to-be created) cgroup AND to leave the application
> > FROZEN after restart ? Or would we need a new command line option
> > and field in 'struct app_restart_args' to specify this ?
> 
> This is exactly what --freezer does. Well, alsmot - except for
> "yet-to-be created". Do you want 'restart' to create the cgroup
> if it doesn't exist ?

I thought that was what Suka was asking for.

-serge
