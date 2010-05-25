From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroups: Add an API to attach a task to current
	task's cgroup
Date: Tue, 25 May 2010 19:53:34 +0300
Message-ID: <20100525165334.GA27307__3454.2495538064$1274806736$gmane$org@redhat.com>
References: <1274227488.2370.107.camel@w-sridhar.beaverton.ibm.com>
	<AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Sridhar Samudrala <samudrala.sridhar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 20, 2010 at 03:22:15PM -0700, Paul Menage wrote:
> On Tue, May 18, 2010 at 5:04 PM, Sridhar Samudrala
> <samudrala.sridhar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Add a new kernel API to attach a task to current task's cgroup
> > in all the active hierarchies.
> >
> > Signed-off-by: Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> It would be more efficient to just attach directly to current->cgroups
> rather than potentially creating/destroying one css_set for each
> hierarchy until we've completely converged on current->cgroups - but
> that would require a bunch of refactoring of the guts of
> cgroup_attach_task() to ensure that the right can_attach()/attach()
> callbacks are made. That doesn't really seem worthwhile right now for
> the initial use, that I imagine isn't going to be
> performance-sensitive.
> 
> Paul

Is this patch suitable for 2.6.35?
It is needed to fix the case where vhost user might cause a kernel thread
to consume more CPU than allowed by the cgroup.
Should I just merge it through the vhost tree?
Ack for this?

Thanks,

-- 
MST
