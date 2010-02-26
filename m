From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Fri, 26 Feb 2010 14:01:35 +0900
Message-ID: <20100226140135.23c32a8d.kamezawa.hiroyu__39896.891572471$1267160751$gmane$org@jp.fujitsu.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<alpine.DEB.2.00.1002211321010.22858@chino.kir.corp.google.com>
	<20100221221700.GA5233@linux> <20100222180732.GC3096@redhat.com>
	<20100223115846.GI1882@linux>
	<28c262361002250736k57543379j8291e0dfb8df194e@mail.gmail.com>
	<20100226092339.1f639cbf.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002252050r29f54ea2u6c6e87f1f702d195@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <28c262361002252050r29f54ea2u6c6e87f1f702d195-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Fri, 26 Feb 2010 13:50:04 +0900
Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > Hm ? I don't read the whole thread but can_attach() is called under
> > cgroup_mutex(). So, it doesn't need to use RCU.
> 
> Vivek mentioned memcg is protected by RCU if I understand his intention right.
> So I commented that without enough knowledge of memcg.
> After your comment, I dive into the code.
> 
> Just out of curiosity.
> 
> Really, memcg is protected by RCU?
yes. All cgroup subsystem is protected by RCU.

> I think most of RCU around memcg is for protecting task_struct and
> cgroup_subsys_state.
> The memcg is protected by cgroup_mutex as you mentioned.
> Am I missing something?

There are several levels of protections.

cgroup subsystem's ->destroy() call back is finally called by

As this.

 768                 synchronize_rcu();
 769 
 770                 mutex_lock(&cgroup_mutex);
 771                 /*
 772                  * Release the subsystem state objects.
 773                  */
 774                 for_each_subsys(cgrp->root, ss)
 775                         ss->destroy(ss, cgrp);
 776 
 777                 cgrp->root->number_of_cgroups--;
 778                 mutex_unlock(&cgroup_mutex);

Before here, 
	- there are no tasks under this cgroup (cgroup's refcnt is 0)
          && cgroup is marked as REMOVED.

Then, this access
	rcu_read_lock();
	mem = mem_cgroup_from_task(task);
	if (css_tryget(mem->css))   <===============checks cgroup refcnt
		....
	rcu_read_unlock()
is O.K.

And, it's graranteed that we don't have to do complicated fine-grain check
if cgroup_mutex() is held.

Because cgroup_mutex() is system-wide heavy lock, this refcnt+RCU trick is
used and works quite well.

Thanks,
-Kame
