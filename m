From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup: remove extra calls to find_existing_css_set
Date: Thu, 22 Dec 2011 07:40:37 -0800
Message-ID: <20111222154037.GC17084__14208.5035251968$1324568457$gmane$org@google.com>
References: <1324527518-24461-1-git-send-email-msb@chromium.org>
	<1324527518-24461-4-git-send-email-msb@chromium.org>
	<4EF2C536.7070408@cn.fujitsu.com>
	<20111222094437.GO17668@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111222094437.GO17668@somewhere>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 22, 2011 at 10:44:39AM +0100, Frederic Weisbecker wrote:
> > >  		if (ent.cgrp == cgrp)
> > >  			continue;
> > > +		ent.cg = find_css_set(tsk->cgroups, cgrp);
> > 
> > unfortunately This won't work, because we are holding tasklist_lock.
> 
> I believe we can remove tasklist_lock now (in a seperate patch).
> 
> It was there in order to protect while_each_thread() against exec but
> now we have threadgroup_lock().
> 
> I think we only need to use rcu_read_lock() to protect against concurrent
> removal in exit.

Yeah, that should work and I really like this patch.

 kernel/cgroup.c |  152 ++++++++++++-------------------------------------------
 1 files changed, 32 insertions(+), 120 deletions(-)

Let's get it working. :)

Thanks.

-- 
tejun
