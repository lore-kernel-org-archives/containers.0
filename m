From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 4/4] memcg: force use_hierarchy if sane_behavior
Date: Sun, 14 Apr 2013 19:35:52 -0700
Message-ID: <20130415023552.GA9955__19962.9533141435$1365993364$gmane$org@dhcp22.suse.cz>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
	<1365808259-31073-5-git-send-email-tj@kernel.org>
	<20130415011336.GF8408@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130415011336.GF8408@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun 14-04-13 20:13:36, Serge Hallyn wrote:
> Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > Turn on use_hierarchy by default if sane_behavior is specified and
> > don't create .use_hierarchy file.
> > 
> > It is debatable whether to remove .use_hierarchy file or make it ro as
> > the former could make transition easier in certain cases; however, the
> > behavior changes which will be gated by sane_behavior are intensive
> > including changing basic meaning of certain control knobs in a few
> > controllers and I don't really think keeping this piece would make
> > things easier in any noticeable way, so let's remove it.
> 
> Hi Tejun,
> 
> this actually reminds me of something that's been on my todo list to
> report for some time, but I haven't had time to find the source of the
> bug...  And maybe it's already been reported...  but
> 
> If I do
> 
> 	cd /sys/fs/cgroup/memory
> 	mkdir b
> 	cd b
> 	echo 1 > memory.use_hierarchy
> 	echo 5000 > memory.limit_in_bytes
> 	cat memory.limit_in_bytes
> 8192
> 	mkdir c
> 	cd c
> 	cat memory.use_hierarchy
> 1
> 	cat memory.limit_in_bytes
> 9223372036854775807
> 	echo $$ > tasks
> 	bash
> <killed>
> 
> So it seems the hierarchy is being enforced, but not reported in
> child limit_in_bytes files.

This is an intended behavior. Limits are not propagated to the children
because they are enforced anyway (by reclaim). The behavior would
be quite inconsistent when the parent limit would be changed later
otherwise. We only inherit properties which are enforced hierarchically:
use_hierarchy, oom_disable and swappiness.

> (Last tested tonight on 3.8.0-17-generic #27-Ubuntu fwiw)
> 
> -serge

-- 
Michal Hocko
SUSE Labs
