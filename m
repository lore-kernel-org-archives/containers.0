From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
	cgroup core
Date: Fri, 30 Nov 2012 14:00:21 +0400
Message-ID: <50B883B5.8020705@parallels.com>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<50B8263C.7060908@jp.fujitsu.com> <50B875B4.2020507@parallels.com>
	<20121130092435.GD29317@dhcp22.suse.cz>
	<50B87F84.7040206@parallels.com>
	<20121130094959.GE29317@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121130094959.GE29317-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/30/2012 01:49 PM, Michal Hocko wrote:
> On Fri 30-11-12 13:42:28, Glauber Costa wrote:
> [...]
>> Speaking of it: Tejun's tree still lacks the kmem bits. How hard would
>> it be for you to merge his branch into a temporary branch of your tree?
> 
> review-cpuset-locking is based on a post merge window merges so I cannot
> merge it as is. I could cherry-pick the series after it is settled. I
> have no idea how much conflicts this would bring, though.
> 
Ok.

I believe the task problem only exist for us for kmem. So I could come
up with a patchset that only deals with child cgroup creation, and
ignore attach for now. So long as we have a mechanism that will work for
it, and don't get lost and forget to patch it when the trees are merged.

Now, what I am actually seeing with cgroup creation, is that the
children will copy a lot of the values from the parent, like swappiness,
hierarchy, etc. Once the child copies it, we should no longer be able to
change those values in the parent: otherwise we'll get funny things like
parent.use_hierarchy = 1, child.use_hierarchy = 0.

One option is to take a global lock in memcg_alloc_css(), and keep it
locked until we did all the cgroup bookkeeping, and then unlock it in
css_online. But I am guessing Tejun won't like it very much.

What do you think about a children counter? If we are going to do things
similar to the attach_in_progress of cpuset, we might very well turn it
into a direct counter so we don't have to iterate at all.

The code would look like: (simplified example for use_hierarchy)

memcg_lock();
if (memcg->nr_children != 0)
    return -EINVAL;
else
    memcg->use_hierarchy = val
memcg_unlock()
