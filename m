From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/7] cgroup_freezer: don't stall transition to FROZEN for
	PF_NOFREEZE or PF_FREEZER_SKIP tasks
Date: Mon, 22 Oct 2012 17:18:22 -0400
Message-ID: <20121022211822.GF5951@atj.dyndns.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-5-git-send-email-tj@kernel.org>
	<20121022183453.GA24687@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121022183453.GA24687-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey,

On Mon, Oct 22, 2012 at 08:34:53PM +0200, Oleg Nesterov wrote:
> On 10/16, Tejun Heo wrote:
> >
> > cgroup_freezer doesn't transition from FREEZING to FROZEN if the
> > cgroup contains PF_NOFREEZE tasks or tasks sleeping with
> > PF_FREEZER_SKIP set.
> 
> And thus the patch looks like another bugfix to me.

It is but I'm not gonna send this one -stable.  Nobody has complained
yet and this is a userland visible behavior change, so I'd rather not
risk it.

> Just one question, and this question is offtopic again,
> 
> > Only kernel tasks can be non-freezable (PF_NOFREEZE)
> 
> Hmm. We seem to "leak" PF_NOFREEZE if a kernel thread execs?
> Perhaps do_execve_common() should do set_freezable() before return.
> 
> Or, at least, simply clear this flag along with PF_KTHREAD in
> flush_old_exec().

Ooh, ouch, definitely.  We should clear that.  Can you please make a
patch?

Thanks.

--
tejun
