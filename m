From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 cgroup/for-3.11 1/3] cgroup: fix RCU accesses to
	task->cgroups
Date: Wed, 26 Jun 2013 11:28:38 +0800
Message-ID: <51CA5FE6.1090207@huawei.com>
References: <20130621225116.GC3949@htj.dyndns.org>
	<20130625184832.GC20051@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130625184832.GC20051-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/26 2:48, Tejun Heo wrote:
> task->cgroups is a RCU pointer pointing to struct css_set.  A task
> switches to a different css_set on cgroup migration but a css_set
> doesn't change once created and its pointers to cgroup_subsys_states
> aren't RCU protected.
> 
> task_subsys_state[_check]() is the macro to acquire css given a task
> and subsys_id pair.  It RCU-dereferences task->cgroups->subsys[] not
> task->cgroups, so the RCU pointer task->cgroups ends up being
> dereferenced without read_barrier_depends() after it.  It's broken.
> 
> Fix it by introducing task_css_set[_check]() which does
> RCU-dereference on task->cgroups.  task_subsys_state[_check]() is
> reimplemented to directly dereference ->subsys[] of the css_set
> returned from task_css_set[_check]().
> 
> This removes some of sparse RCU warnings in cgroup.
> 
> v2: Fixed unbalanced parenthsis and there's no need to use
>     rcu_dereference_raw() when !CONFIG_PROVE_RCU.  Both spotted by Li.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
