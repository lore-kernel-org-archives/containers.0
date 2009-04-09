From: Nigel Cunningham <ncunningham-lkml-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org>
Subject: Re: [PATCH/RFC] do not count frozen tasks toward load
Date: Thu, 09 Apr 2009 11:21:43 +1000
Message-ID: <1239240103.9869.1.camel__40588.5855354883$1239240315$gmane$org@nigel-laptop>
References: <20090408194512.47a99b95@manatee.lan>
Reply-To: ncunningham-lkml-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090408194512.47a99b95-qBK8ZvQsWF7hXIiyNabO3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi again.

On Wed, 2009-04-08 at 19:45 -0500, Nathan Lynch wrote:
> Freezing tasks via the cgroup freezer causes the load average to climb
> because the freezer's current implementation puts frozen tasks in
> uninterruptible sleep (D state).
> 
> Some applications which perform job-scheduling functions consult the
> load average when making decisions.  If a cgroup is frozen, the load
> average does not provide a useful measure of the system's utilization
> to such applications.  This is especially inconvenient if the job
> scheduler employs the cgroup freezer as a mechanism for preempting low
> priority jobs.  Contrast this with using SIGSTOP for the same purpose:
> the stopped tasks do not count toward system load.
> 
> Change task_contributes_to_load() to return false if the task is
> frozen.  This results in /proc/loadavg behavior that better meets
> users' expectations.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  include/linux/sched.h |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 011db2f..f8af167 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -202,7 +202,8 @@ extern unsigned long long time_sync_thresh;
>  #define task_is_stopped_or_traced(task)	\
>  			((task->state & (__TASK_STOPPED | __TASK_TRACED)) != 0)
>  #define task_contributes_to_load(task)	\
> -				((task->state & TASK_UNINTERRUPTIBLE) != 0)
> +				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
> +				 (task->flags & PF_FROZEN) == 0)
>  
>  #define __set_task_state(tsk, state_value)		\
>  	do { (tsk)->state = (state_value); } while (0)

Tested-by: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>

Looks good to me (though I like Andrew's point about using task_frozen).

nigel@nigel-laptop:~$ cat /proc/loadavg 
0.34 0.27 0.12 1/251 9001
nigel@nigel-laptop:~$ sudo hibernate
nigel@nigel-laptop:~$ cat /proc/loadavg 
0.52 0.33 0.14 2/250 9807
nigel@nigel-laptop:~$ 
