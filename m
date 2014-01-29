From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/6] cgroup: drop module support
Date: Wed, 29 Jan 2014 10:30:49 -0500
Message-ID: <20140129153049.GC30842@htj.dyndns.org>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
	<1390952641-15950-3-git-send-email-tj@kernel.org>
	<52E880A6.4040902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52E880A6.4040902-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Li.

On Wed, Jan 29, 2014 at 12:16:38PM +0800, Li Zefan wrote:
> > -#define for_each_builtin_subsys(ss, i)					\
> > -	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
> > -	     (((ss) = cgroup_subsys[i]) || true); (i)++)
> > +	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT &&		\
> > +	     (((ss) = cgroup_subsys[ssid]) || true); (ssid)++)
> 
> Now cgroup_subsys[i] won't be NULL, so we can drop "|| true".

Hmmm... because the macro is kinda complex, I'd like to avoid changing
its implementation in this patch.  Also, the "|| true" tells the
compiler that it doesn't have to generate conditional branch on the
preceding condition.

Now that the array is always consecutive, I'm planning to further
simplify the iterators to not require ssid, so that it just becomes
for_each_subsys(ss).  Let's leave it alone for now.

> > +	if (need_forkexit_callback)
> > +		for_each_subsys(ss, i)
> >  			if (ss->fork)
> >  				ss->fork(child);
> > -	}
> 
> This looks a bit ugly. How about leaving the parentheses for the
> outmost if statement?
> 
> if (need_forkexit_callback) {
> 	for_each_subsys(ss, i)
> 		if (ss->fork)
> 			ss->fork(child);
> }

Maybe, I don't know.  I tend to aim for the minimum necessary as that
usually is the easiest way to achieve consistency.  That said certain
things are a lot easier on the eye with a bit of extra notations -
e.g. "(a & b) && c".  Alright, will add the parentheses.

Thanks!

-- 
tejun
