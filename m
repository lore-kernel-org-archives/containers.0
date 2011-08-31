From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: kill subsys->can_attach_task(), pre_attach()
	and attach_task()
Date: Wed, 31 Aug 2011 15:42:24 +0200
Message-ID: <20110831134220.GB20598__17127.9094451622$1314913472$gmane$org@somewhere>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-7-git-send-email-tj@kernel.org>
	<20110830201030.GC15953@somewhere.redhat.com>
	<20110831070313.GA29179@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110831070313.GA29179-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 31, 2011 at 09:03:13AM +0200, Tejun Heo wrote:
> Hello, Frederic.
> 
> On Tue, Aug 30, 2011 at 10:10:32PM +0200, Frederic Weisbecker wrote:
> > In order to keep the fix queued in -mm (https://lkml.org/lkml/2011/8/26/262)
> > the tasks that have failed to migrate should be removed from the iterator
> > so that they are not included in the batch in ->attach().
> 
> I don't think that's a good approach.  It breaks the symmetry when
> calling different callbacks.  What if ->can_attach() allocates
> per-task resources and the task exits in the middle?  I think we
> better lock down fork/exit/exec.  I'll send patches but I'm currently
> moving / traveling w/ limited access to my toys so it might take some
> time.

My task counter subsystem patchset brings a cancel_attach_task() callback
that cancels can_attach_task() effects.

I thought that rebased on top of your patch it's going to be merged inside
cancel_attach() but OTOH we can't cancel the effect of failed migration
on a thread that way.

May be we need to keep a cancel_attach_task() just for that purpose?
