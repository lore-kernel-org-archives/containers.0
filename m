From: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 17 Feb 2011 15:09:25 +0100
Message-ID: <20110217140925.GA4115__11211.4940923222$1297951798$gmane$org@rabbit.intern.cm-ag>
References: <20110217133152.4043.94951.stgit@rabbit.intern.cm-ag>
	<20110217225010.7f79b412.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110217225010.7f79b412.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2011/02/17 14:50, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> I wonder allowing to set the limit to Root cgroup may imply the system death.
> How about disabling to set value to Root cgroup ?

That is taken care of already:

> > +static int
> > +cgroup_fork_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
> > +{
> > +	if (cgroup->parent == NULL)
> > +		/* cannot limit the root cgroup */
> > +		return 0;

The attribute simply doesn't exist in the root cgroup.

Also watch the loop condition in cgroup_fork_pre_fork() closely, the
root cgroup isn't checked (even if you could find a way to configure
it):

> > +	t = cgroup_fork_current();
> > +	while (t->css.cgroup->parent != NULL && err == 0) {


> IIRC, fork()'s error code is EAGAIN or ENOMEM. The exisiting limit of
> rlimit() returns EAGAIN.
> 
> How about -EAGAIN here ? I think it's not good to add new error code for
> system calls.

EPERM seemed appropriate to me, because the administrator disallows
more than N forks.  If there are practical reasons for changing it to
EAGAIN or ENOMEM, I'm ok with that.  Thanks for the hint.

Max
