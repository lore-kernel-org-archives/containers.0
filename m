From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] memcg: force use_hierarchy if sane_behavior
Date: Mon, 15 Apr 2013 00:29:24 -0500
Message-ID: <20130415052923.GA28141@sergelap>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
	<1365808259-31073-5-git-send-email-tj@kernel.org>
	<20130415011336.GF8408@sergelap>
	<20130415023935.GE3050@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130415023935.GE3050-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hello, Serge.
> 
> On Sun, Apr 14, 2013 at 08:13:36PM -0500, Serge Hallyn wrote:
> > If I do
> > 
> > 	cd /sys/fs/cgroup/memory
> > 	mkdir b
> > 	cd b
> > 	echo 1 > memory.use_hierarchy
> > 	echo 5000 > memory.limit_in_bytes
> > 	cat memory.limit_in_bytes
> > 8192
> > 	mkdir c
> > 	cd c
> > 	cat memory.use_hierarchy
> > 1
> > 	cat memory.limit_in_bytes
> > 9223372036854775807
> > 	echo $$ > tasks
> > 	bash
> > <killed>
> > 
> > So it seems the hierarchy is being enforced, but not reported in
> > child limit_in_bytes files.
> 
> Hmm.... if I understand you correctly, it ain't bug.  It's supposed to
> work that way.  The parent has certain limits and the child doesn't.
> The child will operate within the paren't limits but in those limits
> it isn't restricted.  We actually have a controller which does
> propagate configuration, the device security one, which I don't think
> is really optimal but it seems to be the easier way to implement
> hierarchical behavior for that controller.
> 
> Anyways, if you think about the use cases, the current memcg way makes
> a lot more sense and is more flexible.  e.g. You can express things
> like A + B shouldn't go above 1000 (whatever the unit is) but A and B
> in each can go upto 700 when there's room.

True, that makes sense, thanks.

This example would be great to have in Documentation/cgroups/memory.txt.
Perhaps as a new subsection 6.2?

-serge
