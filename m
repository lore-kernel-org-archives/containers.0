From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.7-fixes 1/2] Revert "cgroup: Remove
	task_lock() from cgroup_post_fork()"
Date: Sat, 20 Oct 2012 14:23:31 -0400
Message-ID: <CAFTL4hzwxqBgVBos00snoVaKAxXfv=DL+HermOOA6EsEhfjheA@mail.gmail.com>
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/10/20 Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> 2012/10/19 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
>> Hello, Frederic.
>>
>> On Fri, Oct 19, 2012 at 03:44:20PM -0400, Frederic Weisbecker wrote:
>>> > For -stable, I think it's better to revert.  If you want to remove
>>> > task_lock, let's do it for 3.8.
>>>
>>> I don't think that a wrong comment justifies a patch to stable.
>>
>> I'm not really sure whether it's safe or not.  It seems all usages are
>> protected by write locking css_set_lock but maybe I'm missing
>> something and as the commit is born out of confusion, I'm very
>> inclined to revert it by default.  Are you sure this one is safe?
>
> Thinking about it further, one scenario is worrying me but it
> eventually looks safe but by accident.
>
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
>         put_css_set(oldcg);
>          list_add(&child->cg_list, &child->cgroups->tasks); (1)

gmail mangled everything :(
