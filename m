From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.12] cgroup: make cgroup_event specific
	to memcg
Date: Fri, 22 Nov 2013 18:39:47 -0500
Message-ID: <20131122233947.GH8981__15992.9096502767$1385163606$gmane$org@mtj.dyndns.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<20131110044811.GA25112@mtj.dyndns.org>
	<20131111141010.GB14497@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131111141010.GB14497-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Nov 11, 2013 at 03:10:10PM +0100, Michal Hocko wrote:
> On Sun 10-11-13 13:48:11, Tejun Heo wrote:
> > Hey, guys.
> > 
> > I'll route this series through the cgroup tree with the acks added
> > once v3.13-rc1 drops.
> 
> Do you have it a local branch which I can merge into mm git tree?

Applied to cgroup/memcg_event which is based on top of v3.12 and then
pulled into cgroup/for-3.14.  Both branches are stable.  Please feel
free to use any.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git memcg_event
 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.14

Thanks.

-- 
tejun
