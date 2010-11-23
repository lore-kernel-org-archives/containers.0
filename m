From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: Convert synchronize_rcu to call_rcu in
	cgroup_attach_task
Date: Tue, 23 Nov 2010 16:14:24 +0800
Message-ID: <4CEB77E0.10202__31736.5587958649$1290500033$gmane$org@cn.fujitsu.com>
References: <AANLkTikx6d0_VFtZ4zWQucRCf=vFt7N2M6=0jpnKasEE@mail.gmail.com>
	<1290398767-15230-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1290398767-15230-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

12:06, Colin Cross wrote:
> The synchronize_rcu call in cgroup_attach_task can be very
> expensive.  All fastpath accesses to task->cgroups that expect
> task->cgroups not to change already use task_lock() or
> cgroup_lock() to protect against updates, and, in cgroup.c,
> only the CGROUP_DEBUG files have RCU read-side critical
> sections.
> 
> sched.c uses RCU read-side-critical sections on task->cgroups,
> but only to ensure that a dereference of task->cgroups does
> not become invalid, not that it doesn't change.
> 

Other cgroup subsystems also use rcu_read_lock to access task->cgroups,
for example net_cls cgroup and device cgroup.

I don't think the performance of task attaching is so critically
important that we have to use call_rcu() instead of synchronize_rcu()?

> This patch adds a function put_css_set_rcu, which delays the
> put until after a grace period has elapsed.  This ensures that
> any RCU read-side critical sections that dereferenced
> task->cgroups in sched.c have completed before the css_set is
> deleted.  The synchronize_rcu()/put_css_set() combo in
> cgroup_attach_task() can then be replaced with
> put_css_set_rcu().
> 

> Also converts the CGROUP_DEBUG files that access
> current->cgroups to use task_lock(current) instead of
> rcu_read_lock().
> 

What for? What do we gain from doing this for those debug
interfaces?

> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> 
> ---
> 
> This version fixes the problems with the previous patch by
> keeping the use of RCU in cgroup_attach_task, but allowing
> cgroup_attach_task to return immediately by deferring the
> final put_css_reg to an rcu callback.
> 
>  include/linux/cgroup.h |    4 +++
>  kernel/cgroup.c        |   58 ++++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 50 insertions(+), 12 deletions(-)
