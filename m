From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Why is cpuset_cpus_allowed_fallback() necessary?
Date: Sun, 2 Dec 2012 06:15:50 -0800
Message-ID: <20121202141550.GQ15930__26763.1428469487$1354457778$gmane$org@mtj.dyndns.org>
References: <20121126223249.GB15930@mtj.dyndns.org>
	<20121127184117.GA8937@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121127184117.GA8937-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Oleg.

On Tue, Nov 27, 2012 at 07:41:17PM +0100, Oleg Nesterov wrote:
> > Oleg, do you remember?  Why do we need
> > this?
> 
> No, I forgot. And this code was changed after that, the fat comment in
> cpuset_cpus_allowed_fallback() tried to explain the code below which
> was removed.
> 
> I am starting to recall what this patch tried to do after I looked into
> git history. This patch was the last (probably) change in series.
> 
> Please look at
> 	897f0b3c3ff40b443c84e271bef19bd6ae885195
> 	sched: Kill the broken and deadlockable cpuset_lock/cpuset_cpus_allowed_locked code
> 
> In particular it removes cpuset_cpus_allowed_locked() from
> select_fallback_rq() because this was very wrong. IOW, this patch
> simply removes the code which didn't really work
> 
> And after some other changes, this comment tried to add the supposed
> behaviour back: we shouldn't simply use cpu_possible_mask, we should
> consult cpuset.

Ah, okay.  If the task's affinity, which is subset of cpuset's, become
empty while the cpuset's doesn't, we still better confine the task to
the cpuset.  The code seems broken tho - it looks at CPUs which are on
the same node first before consulting cpuset, which may lead to the
task escaping cpuset.  Prolly the function need to be restructured
that it first runs as if cpuset->cpus_allowed is cpu_possible_mask and
then if that fails with the actual cpu_possible_mask.

Thanks!

-- 
tejun
