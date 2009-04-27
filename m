From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Mon, 27 Apr 2009 21:15:33 +0900 (JST)
Message-ID: <20090427.211533.115916003.ryov__25561.9568670683$1240835062$gmane$org@valinux.co.jp>
References: <20090420.183815.226804723.ryov@valinux.co.jp>
	<20090420150052.GC13307@linux>
	<20090427.194533.183037823.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090427.194533.183037823.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Kamezawa-san,

> I've come up with an idea to coexist blkio-cgroup and io-throttle.
> blkio-cgroup provides a function to get a cgroup with the specified ID.
> 
> /* Should be called under rcu_read_lock() */
> struct cgroup *blkio_cgroup_lookup(int id)
> {
> 	struct cgroup *cgrp;
> 	struct cgroup_subsys_state *css;
> 	
> 	if (blkio_cgroup_disabled())
> 		return NULL;
> 
> 	css = css_lookup(&blkio_cgroup_subsys, id);
> 	if (!css)
> 		return NULL;
> 	cgrp = css->cgroup;
> 	return cgrp;
> }
> 
> Then io-throttle can get a struct iothrottle which belongs to the
> cgroup by using the above function.
> 
> static struct iothrottle *iothrottle_lookup(int id)
> {
> 	struct cgroup *grp;
> 	struct iothrottle *iot;
> 
> 	...
> 	grp = blkio_cgroup_lookup(id);
> 	if (!grp)
> 		return NULL
> 	iot = cgroup_to_iothrottle(grp);
> 	...
> }
> 
> What do you think about this way?

I have some questions. 
- How about using the same numbering scheme as process ID for css_id
  instead of idr? It prevents the same ID from being resued quickly.
- Why are css_ids assigned per css? If each cgroup has a unique ID and
  the subsystems can refer to it, I can make the above code simple.

Thanks,
Ryo Tsuruta
