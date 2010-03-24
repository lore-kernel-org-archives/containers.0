From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Tue, 23 Mar 2010 18:53:13 -0700
Message-ID: <20100324015313.GA5704__29925.7323648364$1269395645$gmane$org@count0.beaverton.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
	<20100323211843.GC19572@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100323211843.GC19572-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 23, 2010 at 09:18:43PM +0000, Russell King - ARM Linux wrote:

<snip> (sorry -- I'm not familiar with ARM so I can't respond to those)

> > +/* dump the thread_struct of a given task */
> > +int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
> > +{
> > +	int ret;
> > +	struct ckpt_hdr_thread *h;
> > +	struct thread_info *ti = task_thread_info(t);
> > +
> > +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
> > +	if (!h)
> > +		return -ENOMEM;
> > +
> > +	/*
> > +	 * Store the syscall information about the checkpointed process
> > +	 * as we need to know if the process was doing a syscall (and which)
> > +	 * during restart.
> > +	 */
> > +	h->syscall = ti->syscall;
> > +
> > +	/*
> > +	 * Store remaining thread-specific info.
> > +	 */
> > +	h->tp_value = ti->tp_value;
> 
> How do you safely obtain consistent information from a thread?  Do you
> temporarily stop it?

It must be frozen with the cgroup freezer (which reuses the suspend freezer).
sys_checkpoint moves the cgroup freezer into the CHECKPOINTING state which
prevents tasks in that group from being thawed until just before checkpoint
returns.

Cheers,
	-Matt Helsley
