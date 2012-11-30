From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
	cgroup core
Date: Fri, 30 Nov 2012 06:59:24 -0800
Message-ID: <20121130145924.GA3873__29234.6825860024$1354287616$gmane$org@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<50B8263C.7060908@jp.fujitsu.com> <50B875B4.2020507@parallels.com>
	<20121130092435.GD29317@dhcp22.suse.cz>
	<50B87F84.7040206@parallels.com>
	<20121130094959.GE29317@dhcp22.suse.cz>
	<50B883B5.8020705@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50B883B5.8020705-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Nov 30, 2012 at 02:00:21PM +0400, Glauber Costa wrote:
> Now, what I am actually seeing with cgroup creation, is that the
> children will copy a lot of the values from the parent, like swappiness,
> hierarchy, etc. Once the child copies it, we should no longer be able to
> change those values in the parent: otherwise we'll get funny things like
> parent.use_hierarchy = 1, child.use_hierarchy = 0.

So, the best way to do this is from ->css_online().  If memcg
synchronizes and inherits from ->css_online(), it can guarantee that
the new cgroup will be visible in any following iterations.  Just have
an online flag which is turned on and off from ->css_on/offline() and
ignore any cgroups w/o online set.

> One option is to take a global lock in memcg_alloc_css(), and keep it
> locked until we did all the cgroup bookkeeping, and then unlock it in
> css_online. But I am guessing Tejun won't like it very much.

No, please *NEVER* *EVER* do that.  You'll be creating a bunch of
locking dependencies as cgroup walks through different controllers.

memcg should be able to synchornize fully both css on/offlining and
task attachments in memcg proper.  Let's please be boring about
locking.

Thanks.

-- 
tejun
