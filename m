From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
	cgroup removal
Date: Wed, 14 Mar 2012 09:28:28 +0900
Message-ID: <20120314092828.3321731c.kamezawa.hiroyu__12542.6554390744$1331685014$gmane$org@jp.fujitsu.com>
References: <20120312213155.GE23255@google.com>
	<20120312213343.GF23255@google.com>
	<20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
	<20120313163914.GD7349@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120313163914.GD7349-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 13 Mar 2012 09:39:14 -0700
Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> Hello, KAMEZAWA.
> 
> On Tue, Mar 13, 2012 at 03:11:48PM +0900, KAMEZAWA Hiroyuki wrote:
> > The trouble for pre_destroy() is _not_ refcount, Memory cgroup has its own refcnt
> > and use it internally. The problem is 'charges'. It's not related to refcnt.
> 
> Hmmm.... yeah, I'm not familiar with memcg internals at all.  For
> blkcg, refcnt matters but if it doesn't for memcg, great.
> 
> > Cgroup is designed to exists with 'tasks'. But memory may not be related to any
> > task...just related to a cgroup.
> > 
> > But ok, pre_destory() & rmdir() is complicated, I agree.
> > 
> > Now, we prevent rmdir() if we can't move charges to its parent. If pre_destory()
> > shouldn't fail, I can think of some alternatives.
> > 
> >  * move all charges to the parent and if it fails...move all charges to
> >    root cgroup.
> >    (drop_from_memory may not work well in swapless system.)
> 
> I think this one is better and this shouldn't fail if hierarchical
> mode is in use, right?
> 

Right.


> > I think.. if pre_destory() never fails, we don't need pre_destroy().
> 
> For memcg maybe, blkcg still needs it.
> 
> > >   The last one seems more tricky.  On destruction of cgroup, the
> > >   charges are transferred to its parent and the parent may not have
> > >   enough room for that.  Greg told me that this should only be a
> > >   problem for !hierarchical case.  I think this can be dealt with by
> > >   dumping what's left over to root cgroup with a warning message.
> > 
> > I don't like warning ;) 
> 
> I agree this isn't perfect but then again failing rmdir isn't perfect
> either and given that the condition can be wholly avoided in
> hierarchical mode, which should be the default anyway (is there any
> reason to keep flat mode except for backward compatibility?), I don't
> think the trade off is too bad.
> 

One reason is 'performance'. You can see performance trouble when you
creates deep tree of memcgs in hierarchy mode. The deeper memcg tree,
the more res_coutners will be shared.

For example, libvirt creates cgroup tree as

	/cgroup/memory/libvirt/qemu/GuestXXX/....
        /cgroup/memory/libvirt/lxc/GuestXXX/...

No one don't want to count up 4 res_coutner, which is very very heavy,
for handling independent workloads of "Guest".

IIUC, in general, even in the processes are in a tree, in major case
of servers, their workloads are independent.
I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
cannot be managed.


Thanks,
-Kame
