From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Thu, 25 Aug 2011 11:20:45 +0200
Message-ID: <20110825092045.GG3286__59.2421311468527$1314264336$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-4-git-send-email-tj@kernel.org>
	<CALdu-PDAgqeRJt5vqTB9wddwz70Yn+Jf-Pb0dDKDBD_q37tHQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALdu-PDAgqeRJt5vqTB9wddwz70Yn+Jf-Pb0dDKDBD_q37tHQg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Thu, Aug 25, 2011 at 02:14:12AM -0700, Paul Menage wrote:
> The general idea of passing consistent information to all *attach
> methods seems good, but isn't it simpler to just fix up the various
> method signatures?

I think having separate ->attach() and ->attach_task() is inherently
broken.  Look at the memcg discussion I had in this thread for
reference and as soon as we need to do something across the tasks
being migrated, iteration-by-callback becomes very painful.
e.g. let's say memcg wants to find the mm->owner and wants to print
warning or fail if that doesn't work out.  How would that be
implemented if it's iterating by callback.

> The whole point of having *attach() and *attach_task() was to minimize
> the amount of boilerplate (in this case, iterating across a new
> cgroup_taskset abstraction) in the subsystems, leaving that to the
> cgroups framework.

Yeah, I agree with making things easier for subsystems but I violently
disagree that iteration-by-callback is helpful in any way.  If
control-loop style iterator is at all possible, it's almost always
better to go that way.

Thanks.

-- 
tejun
