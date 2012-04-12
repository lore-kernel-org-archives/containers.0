From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 18:59:27 +0200
Message-ID: <20120412165922.GA12484@somewhere.redhat.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<20120412010745.GE1787@cmpxchg.org>
	<20120412145507.GC11455@somewhere.redhat.com>
	<4F87042A.2000902@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F87042A.2000902-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 12, 2012 at 01:34:50PM -0300, Glauber Costa wrote:
> On 04/12/2012 11:55 AM, Frederic Weisbecker wrote:
> >I don't know how the kernel stack is allocated for tasks. Do you mean
> >that we allocate a chunck of it for each new task and we could rely
> >on that?
> >
> More than this: amount of kernel stack is really, really something
> indirect if what you want to track is # of processes. Now, Hannes
> made a fair point in his other e-mail about what is a resource and
> what is not.

I start to consider this option, are there other people interested
in accounting/limiting kernel stack as well?

> 
> >>>  After all, we would only restrict the number of tasks for the
> >>>  resources they require
> >It depends if the kernel stack can have other kind of "consumer".
> >
> It also depends on what you really want to achieve.
> If you want to prevent fork bombs, limiting kernel stack will do just fine.

I want:

a) to prevent the forkbomb from going far enough to DDOS the machine
b) to be able to kill that forkbomb once detected, in one go without race
against concurrent forks.

I think a) can work just fine with kernel stack limiting. I also need
to be notified about the fact we reached the limit. And b) should
be feasible with the help of the cgroup freezer. 

> 
> Is there anything for which you need to know exactly the number of
> processes?

No that's really about prevent/kill forkbomb as far as I'm concerned.
