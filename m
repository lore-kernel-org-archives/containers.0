From: Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cgroup_freezer: allow migration
	regardless of freezer state and update locking
Date: Wed, 17 Oct 2012 12:16:06 -0700
Message-ID: <20121017191606.GA6223@us.ibm.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1350426526-14254-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 16, 2012 at 03:28:39PM -0700, Tejun Heo wrote:
> Hello,
> 
> This patchset updates cgroup_freezer so that
> 
> * Unfreezable kernel tasks don't prevent a cgroup from transitioning
>   into FROZEN from FREEZING.  There's nothing userland can do with or
>   about such tasks.

Seems like a non-problem. Do you have a testcase showing how kernel
threads prevent cgroups that should be freezable from being frozen?
It used to be that you couldn't move kernel threads out of the root
cgroup and the root cgroup was not freezable. So this was never a
problem before. Is there some change here that I'm unaware of?

> 
> * Tasks can be moved in and out of a frozen cgroup.  Tasks are made to
>   conform to the state of the new cgroup during migration.  This
>   behavior makes a lot more sense and removes the use of
>   ->can_attach() which makes co-mounting difficult.

One nice aspect of freezing the set of tasks in the cgroup as well as the
tasks themselves was you had a fixed set of tasks to work with (from
userspace or otherwise). With this change that will no longer be true.
This is a userspace-visible behavior change and userspace code may
have relied on this feature.

Will this work for the CRIU folks? With this patch one of the tasks being
checkpointed could become thawed simply by some other process writing
the pid into a different cgroup's tasks file. In contrast, with the
current code they'd have to explicitly thaw its cgroup first.

Cheers,
	-Matt Helsley
