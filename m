From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 12/12] cfq-iosched: add hierarchical cfq_group statistics
Date: Tue, 18 Dec 2012 11:14:25 -0800
Message-ID: <20121218191425.GO1844@htj.dyndns.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<1355524885-22719-13-git-send-email-tj@kernel.org>
	<20121218191117.GD24050@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121218191117.GD24050-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Vivek.

On Tue, Dec 18, 2012 at 02:11:17PM -0500, Vivek Goyal wrote:
> All these stats needs to be mentioned in blkio-controller.txt file to 
> keep that file uptodate.
> 
> I think it also needs another word about nature of hierarchical stats.
> That is they represent current view of the system and don't store the
> history. So if a cgroup was created, did some IO and it was removed, we
> lost that history. Deleted cgroup's parent will have no history of
> stats of deleted cgroup.

Haven't thought about that.  That's nasty.

> Hence these stats can't be used for things like billing purposes.
> 
> IIRC, this is different from the way we collect hierarhical stats for
> memory controller.
> 
> But I kind of like this because stat update overhead does not increase
> with depth of hierarchy. Primarily stat reader pays the price of
> traversing through all the stats.

Yeah, hmmm, maybe we should add another set of counters to carry stats
from dead ones?  Avoiding hierarchical accounting overhead in hot path
while remembering by-gones shouldn't be that hard.  Will work on that.

Thanks.

-- 
tejun
