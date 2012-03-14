From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
	cgroup removal
Date: Tue, 13 Mar 2012 23:11:12 -0700
Message-ID: <20120314061112.GA3258__32173.3637167656$1331705489$gmane$org@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120312213155.GE23255@google.com>
	<20120312213343.GF23255@google.com>
	<20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
	<20120313163914.GD7349@google.com>
	<20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120314092828.3321731c.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Mar 14, 2012 at 09:28:28AM +0900, KAMEZAWA Hiroyuki wrote:
> > I agree this isn't perfect but then again failing rmdir isn't perfect
> > either and given that the condition can be wholly avoided in
> > hierarchical mode, which should be the default anyway (is there any
> > reason to keep flat mode except for backward compatibility?), I don't
> > think the trade off is too bad.
> 
> One reason is 'performance'. You can see performance trouble when you
> creates deep tree of memcgs in hierarchy mode. The deeper memcg tree,
> the more res_coutners will be shared.
> 
> For example, libvirt creates cgroup tree as
> 
> 	/cgroup/memory/libvirt/qemu/GuestXXX/....
>         /cgroup/memory/libvirt/lxc/GuestXXX/...
> 
> No one don't want to count up 4 res_coutner, which is very very heavy,
> for handling independent workloads of "Guest".

Yes, performance definitely is a concern but I think that it would be
better to either avoid building deep hierarchies or provide a generic
way to skip some levels rather than implementing different behavior
mode per controller.  Per-controller behavior selection ends up
requiring highly specialized configuration which is very difficult to
generalize and automate.

> IIUC, in general, even in the processes are in a tree, in major case
> of servers, their workloads are independent.
> I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
> cannot be managed.

I currently am hoping that cgroup core can provide a generic mechanism
to abbreviate, if you will, hierarchies so that controllers can be
used the same way, with hierarchy unaware controllers using the same
mechanism to essentially achieve flat view of the same hierarchy.  It
might as well be a pipe dream tho.  I'll think more about it.

Anyways, I'm building up updates on top of the patch to strip out
pre_destroy waiting and failure handling.  Is anyone interested in
doing the memcg part, pretty please?

Thank you very much.

-- 
tejun
