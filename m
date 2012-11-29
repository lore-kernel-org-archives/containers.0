From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
	cgroup core
Date: Thu, 29 Nov 2012 06:26:46 -0800
Message-ID: <20121129142646.GD24683__8877.36964873529$1354199234$gmane$org@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<50B743A1.4040405@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50B743A1.4040405-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Glauber.

On Thu, Nov 29, 2012 at 03:14:41PM +0400, Glauber Costa wrote:
> On 11/29/2012 01:34 AM, Tejun Heo wrote:
> > This patchset decouples cpuset locking from cgroup_mutex.  After the
> > patchset, cpuset uses cpuset-specific cpuset_mutex instead of
> > cgroup_mutex.  This also removes the lockdep warning triggered during
> > cpu offlining (see 0009).
> > 
> > Note that this leaves memcg as the only external user of cgroup_mutex.
> > Michal, Kame, can you guys please convert memcg to use its own locking
> > too?
> 
> Not totally. There is still one mention to the cgroup_lock():
> 
> static void cpuset_do_move_task(struct task_struct *tsk,
>                                 struct cgroup_scanner *scan)
> {
>         struct cgroup *new_cgroup = scan->data;
> 
>         cgroup_lock();
>         cgroup_attach_task(new_cgroup, tsk);
>         cgroup_unlock();
> }

Which is outside all other locks and scheduled to be moved inside
cgroup_attach_task().

> And similar problem to this, is the one we have in memcg: We need to
> somehow guarantee that no tasks will join the cgroup for some time -
> this is why we hold the lock in memcg.
> 
> Just calling a function that internally calls the cgroup lock won't do
> much, since it won't solve any dependencies - where it is called matters
> little.

The dependency is already solved in cpuset.

> What I'll try to do, is to come with another specialized lock in cgroup
> just for this case. So after taking the cgroup lock, we would also take
> an extra lock if we are adding another entry - be it task or children -
> to the cgroup.

No, please don't do that.  Just don't invoke cgroup operation inside
any subsystem lock.

Thanks.

-- 
tejun
