From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 0/2] memcg: per cgroup dirty limit
Date: Mon, 22 Feb 2010 12:58:33 -0500
Message-ID: <20100222175833.GB3096__2531.60194629363$1266861820$gmane$org@redhat.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<20100222142744.GB13823@redhat.com>
	<20100222173640.GG3063@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222173640.GG3063-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 11:06:40PM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2010-02-22 09:27:45]:
> 
> > On Sun, Feb 21, 2010 at 04:18:43PM +0100, Andrea Righi wrote:
> > > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > > 
> > > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > > will not be able to consume more than their designated share of dirty pages and
> > > will be forced to perform write-out if they cross that limit.
> > > 
> > > The overall design is the following:
> > > 
> > >  - account dirty pages per cgroup
> > >  - limit the number of dirty pages via memory.dirty_bytes in cgroupfs
> > >  - start to write-out in balance_dirty_pages() when the cgroup or global limit
> > >    is exceeded
> > > 
> > > This feature is supposed to be strictly connected to any underlying IO
> > > controller implementation, so we can stop increasing dirty pages in VM layer
> > > and enforce a write-out before any cgroup will consume the global amount of
> > > dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes limit.
> > > 
> > 
> > Thanks Andrea. I had been thinking about looking into it from IO
> > controller perspective so that we can control async IO (buffered writes
> > also).
> > 
> > Before I dive into patches, two quick things.
> > 
> > - IIRC, last time you had implemented per memory cgroup "dirty_ratio" and
> >   not "dirty_bytes". Why this change? To begin with either per memcg
> >   configurable dirty ratio also makes sense? By default it can be the
> >   global dirty ratio for each cgroup.
> > 
> > - Looks like we will start writeout from memory cgroup once we cross the
> >   dirty ratio, but still there is no gurantee that we be writting pages
> >   belonging to cgroup which crossed the dirty ratio and triggered the
> >   writeout.
> > 
> >   This behavior is not very good at least from IO controller perspective
> >   where if two dd threads are dirtying memory in two cgroups, then if
> >   one crosses it dirty ratio, it should perform writeouts of its own pages
> >   and not other cgroups pages. Otherwise we probably will again introduce
> >   serialization among two writers and will not see service differentation.
> 
> I thought that the I/O controller would eventually provide hooks to do
> this.. no?

Actually no. This belongs to writeback logic which selects the inode to
write from. Ideally, like reclaim logic, we need to flush out the pages
from memory cgroup which is being throttled so that we can create
parallel buffered write paths at higher layer and rate of IO allowed on
this paths can be controlled by IO controller (either proportional BW or
max BW etc).

Currently the issue is that everything in page cache is common and there
is no means in writeout path to create a service differentiation. This is
where this per memory cgroup dirty_ratio/dirty_bytes can be useful where
writeout from a cgroup are not throttled till it does not hit its own
dirty limits.

Also we need to make sure that in case of throttling, we are submitting pages
to writeout from our own cgroup and not from other cgroup, otherwise we
are back to same situation.

> 
> > 
> >   May be we can modify writeback_inodes_wbc() to check first dirty page
> >   of the inode. And if it does not belong to same memcg as the task who
> >   is performing balance_dirty_pages(), then skip that inode.
> 
> Do you expect all pages of an inode to be paged in by the same cgroup?

I guess at least in simple cases. Not sure whether it will cover majority
of usage or not and up to what extent that matters.

If we start doing background writeout, on per page (like memory reclaim),
the it probably will be slower and hence flusing out pages sequentially
from inode makes sense. 

At one point I was thinking, like pages, can we have an inode list per
memory cgroup so that writeback logic can traverse that inode list to
determine which inodes need to be cleaned. But associating inodes to
memory cgroup is not very intutive at the same time, we again have the
issue of shared file pages from two differnent cgroups. 

But I guess, a simpler scheme would be to just check first dirty page from
inode and if it does not belong to memory cgroup of task being throttled,
skip it.

It will not cover the case of shared file pages across memory cgroups, but
at least something relatively simple to begin with. Do you have more ideas
on how it can be handeled better.

Vivek
