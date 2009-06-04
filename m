From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (a)
Date: Thu, 4 Jun 2009 09:32:29 -0500
Message-ID: <20090604143229.GA28586@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
	<20090603161840.GD7848@us.ibm.com>
	<Pine.LNX.4.64.0906031957110.19096@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0906032008490.19096@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906032008490.19096-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> >From 6cdb7d9504a19ad88e6da8ad85374267c7acb1b2 Mon Sep 17 00:00:00 2001
> From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 3 Jun 2009 02:31:21 -0700
> Subject: [PATCH] cgroup freezer: Add CHECKPOINTING state to safeguard container checkpoint
> 
> The CHECKPOINTING state prevents userspace from unfreezing tasks until
> sys_checkpoint() is finished. When doing container checkpoint userspace
> will do:
> 
> 	echo FROZEN > /cgroups/my_container/freezer.state
> 	...
> 	rc = sys_checkpoint( <pid of container root> );
> 
> To ensure a consistent checkpoint image userspace should not be allowed
> to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
> during checkpoint.
> 
> "CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
> system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
> the checkpoint system call is finished and ready to return. Then the
> freezer state returns to "FROZEN". Writing any new state to freezer.state while
> checkpointing will return EBUSY. These semantics ensure that userspace cannot
> unfreeze the cgroup midway through the checkpoint system call.
> 
> The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
> make relatively few assumptions about the task that is passed in. However the
> way they are called in do_checkpoint() assumes that the root of the container
> is in the same freezer cgroup as all the other tasks that will be
> checkpointed.
> 
> Matt Helsley's wrote the original patch.
> 
> Changlog:
>   [2009-Jun-03] change cgroup_freezer_{begin,end}_checkpoint() to take a
>   		struct cgroup_subsys_state pointer
> 		add struct cgroup_subsys_state *get_task_cgroup_freezer()
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

Looks good -

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

to both.  I still don't see why you need a ref to the root_freezer,
but it doesn't hurt at any rate so I won't harp on it.

thanks,
-serge
