From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.7-fixes 1/2] Revert "cgroup: Remove
	task_lock() from cgroup_post_fork()"
Date: Sat, 20 Oct 2012 15:37:09 -0700
Message-ID: <20121020223709.GA5626@htj.dyndns.org>
References: <20121008020000.GB2575@localhost>
	<20121019005922.GG13370@google.com>
	<CAFTL4hz82==b3ioSMhbKzh0CN1ivR7RQMKKMFFWu5PHPjg=Bfg@mail.gmail.com>
	<20121019193808.GL13370@google.com>
	<CAFTL4hwQ6Ntn5GJwj=jiO2p3GdwhEMp0MyR8dgUj_Lx0U4kNqg@mail.gmail.com>
	<20121019210738.GA1180@google.com>
	<CAFTL4hy+vrvJKrc1Y2FW44k=LBi72H=34337xALpbtG_3u5O7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAFTL4hy+vrvJKrc1Y2FW44k=LBi72H=34337xALpbtG_3u5O7w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Frederic.

On Sat, Oct 20, 2012 at 02:21:43PM -0400, Frederic Weisbecker wrote:
> CPU 0
>                     CPU 1
> 
> cgroup_task_migrate {
>         task_lock(p)
>         rcu_assign_pointer(tsk->cgroups, newcg);
>         task_unlock(tsk);
> 
>         write_lock(&css_set_lock);
>         if (!list_empty(&tsk->cg_list))
>             list_move(&tsk->cg_list, &newcg->tasks);
>         write_unlock(&css_set_lock);
> 
>                           write_lock(&css_set_lock);
> 	put_css_set(oldcg);
>          list_add(&child->cg_list, &child->cgroups->tasks); (1)

Man, that's confusing. :)

> On (1), child->cgroups should have the value of newcg and not oldcg
> due to the memory ordering implied by the locking of css_set_lock. Now
> I can't guarantee that because I'm no memory ordering expert. And even
> if it's safe, it's so very non obvious that I now agree with you:
> let's revert  the patch and restart with a better base by gathering
> all the cgroup fork code in the current cgroup_post_fork place.

Aye aye, let's move everything to cgroup_post_fork() and then we don't
have to worry about grabbing task_lock multiple times.

Thanks.

-- 
tejun
