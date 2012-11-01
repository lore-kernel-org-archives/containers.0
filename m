From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 4/8] cgroup: deactivate CSS's and mark cgroup dead before
	invoking ->pre_destroy()
Date: Thu, 1 Nov 2012 09:58:32 +0100
Message-ID: <20121101085832.GB8525@dhcp22.suse.cz>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-5-git-send-email-tj@kernel.org>
	<20121031212359.GC5286@dhcp22.suse.cz>
	<20121031212725.GA2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121031212725.GA2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 31-10-12 14:27:25, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Oct 31, 2012 at 10:23:59PM +0100, Michal Hocko wrote:
> > > +	for_each_subsys(cgrp->root, ss)
> > > +		if (ss->pre_destroy)
> > > +			WARN_ON_ONCE(ss->pre_destroy(cgrp));
> > 
> > Do you think that BUG_ON would be too harsh?
> 
> Yeah, I do think so.  In general, I think the consensus now is to
> prefer WARN_ON[_ONCE]() over BUG_ON() whenever possible.  It's not
> like we can get more information from BUG_ON()s (more likely to get
> less reporting actually by taking down the machine).  Limping machines
> are better than dead ones and there just isn't much to gain here by
> killing it.

Fair enough

-- 
Michal Hocko
SUSE Labs
