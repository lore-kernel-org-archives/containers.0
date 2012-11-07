From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/9] cgroup: add cgroup_subsys->post_create()
Date: Wed, 7 Nov 2012 09:02:21 -0800
Message-ID: <20121107170221.GE2660@mtj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
	<20121107152516.GA4131@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121107152516.GA4131-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Michal.

On Wed, Nov 07, 2012 at 04:25:16PM +0100, Michal Hocko wrote:
> > This patch adds ->post_create().  It's called after all ->create()
> > succeeded and the cgroup is linked into the generic cgroup hierarchy.
> > This plays the counterpart of ->pre_destroy().
> 
> Hmm, I had to look at "cgroup_freezer: implement proper hierarchy
> support" to actually understand what is the callback good for. The above
> sounds as if the callback is needed when a controller wants to use
> the new iterators or when pre_destroy is defined.
> 
> I think it would be helpful if the changelog described that the callback
> is needed when the controller keeps a mutable shared state for the
> hierarchy. For example memory controller doesn't have any such a strict
> requirement so we can safely use your new iterators without pre_destroy.

Hmm.... will try to explain it but I think it might be best to just
refer to the later patch for details.  It's a bit tricky to explain.

Thanks.

-- 
tejun
