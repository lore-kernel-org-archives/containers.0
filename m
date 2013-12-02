From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/12] cgroup: unify cgroup_write_X64() and
	cgroup_write_string()
Date: Mon, 2 Dec 2013 08:30:59 -0500
Message-ID: <20131202133059.GA3626@htj.dyndns.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-8-git-send-email-tj@kernel.org>
	<20131128111818.GG2761@dhcp22.suse.cz>
	<20131129200525.GC21755@mtj.dyndns.org>
	<20131202095401.GA18838@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131202095401.GA18838-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Michal.

On Mon, Dec 02, 2013 at 10:54:01AM +0100, Michal Hocko wrote:
> Well, I am not happy about the use case as well and I will always
> discourage people from doing this. I was merely pointing out that the
> patch will break those even though it seems trivial to not do so. That
> being said I would rather see no allocation in that path but if that
> doesn't seem viable to you then I will not loose any sleep over it.

So, is it something already working reliably?  I really don't like the
implications of heading this way.  Does it also mean cgroup won't be
able to use seq_file for read paths either?

We're talking about a *lot* of extra restrictions and shackles if we
go down this path and many of them would be extremely subtle and
fragile.  If this is an one-off thing to keep the existing users
happy, I'm okay with it and will update this patch and kernfs so that
writes under certain size use on-stack buffer, but I *DO* want an
assurance that memcg isn't gonna march that way, which is likely to
bring down the rest of cgroup in the process.

Well, either that or please convince me it's something sane to
support, but you don't sound too sure either, so....

Thanks.

-- 
tejun
