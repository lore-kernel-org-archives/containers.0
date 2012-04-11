From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Wed, 11 Apr 2012 21:22:31 +0200
Message-ID: <20120411192231.GF16008__22954.7133356848$1334172189$gmane$org@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120411154005.GD16692-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed 11-04-12 11:40:05, Vivek Goyal wrote:
> On Wed, Apr 11, 2012 at 12:24:25AM +0200, Jan Kara wrote:
> 
> [..]
> > > I have implemented and posted patches for per bdi per cgroup congestion
> > > flag. The only problem I see with that is that a group might be congested
> > > for a long time because of lots of other IO happening (say direct IO) and
> > > if you keep on backing off and never submit the metadata IO (transaction),
> > > you get starved. And if you go ahead and submit IO in a congested group,
> > > we are back to serialization issue.
> >   Clearly, we mustn't throttle metadata IO once it gets to the block layer.
> > That's why we discuss throttling of processes at transaction start after
> > all. But I agree starvation is an issue - I originally thought blk-throttle
> > throttles synchronously which wouldn't have starvation issues. But when
> > that's not the case things are a bit more tricky. We could treat
> > transaction start as an IO of some size (since we already have some
> > estimation how large a transaction will be when we are starting it) and let
> > the transaction start only when our "virtual" IO would be submitted but
> > I feel that gets maybe too complicated... Maybe we could just delay the
> > transaction start by the amount reported from blk-throttle layer? Something
> > along your callback for throttling you implemented?
> 
> I think now I have lost you. It probably stems from the fact that I don't
> know much about transactions and filesystem.
>  
> So all the metadata IO will happen thorough journaling thread and that
> will be in root group which should remain unthrottled. So any journal
> IO going to disk should remain unthrottled.
  Yes, that is true at least for ext3/ext4 or btrfs. In principle we don't
have to have the journal thread (as is the case of reiserfs where random
writer may end up doing commit) but let's not complicate things
unnecessarily.

> Now, IIRC, fsync problem with throttling was that we had opened a
> transaction but could not write it back to disk because we had to
> wait for all the cached data to go to disk (which is throttled). So
> my question is, can't we first wait for all the data to be flushed
> to disk and then open a transaction for metadata. metadata will be
> unthrottled so filesystem will not have to do any tricks like bdi is
> congested or not.
  Actually that's what's happening. We first do filemap_write_and_wait()
which syncs all the data and then we go and force transaction commit to
make sure all metadata got to stable storage. The problem is that writeout
of data may need to allocate new blocks and that starts a transaction and
while the transaction is started we may need to do some reads (e.g. of
bitmaps etc.) which may be throttled and at that moment the whole
filesystem is blocked. I don't remember the stack traces you showed me so
I'm not sure it this is what your observed but it's certainly one possible
scenario. The reason why fsync triggers problems is simply that it's the
only place where process normally does significant amount of writing. In
most cases flusher thread / journal thread do it so this effect is not
visible. And to precede your question, it would be rather hard to avoid IO
while the transaction is started due to locking.

> [..]
> > > I guess throttling at bdi layer will take care of network filesystem
> > > case too?
> >   Yes. At least for client side. On sever side Steve wants server to have
> > insight into how much IO we could push in future so that it can limit
> > number of outstanding requests if I understand him right. I'm not sure we
> > really want / are able to provide this amount of knowledge to filesystems
> > even less userspace...
> 
> I am not sure what does it mean but server could simply query the bdi
> and read configured rate and then it knows at what rate IO will go to
> disk and make predictions about future?
  Yeah, that would work if we had the current bandwidth for current cgroup
exposed in bdi.
 
> > > Also per bdi limit mechanism will not solve the issue of global throttling
> > > where in case of btrfs an IO might go to multiple bdi's. So throttling limits
> > > are not total but per bdi.
> >   Well, btrfs plays tricks with bdi's but there is a special bdi called
> > "btrfs" which backs the whole filesystem and that is what's put in
> > sb->s_bdi or in each inode's i_mapping->backing_dev_info. So we have a
> > global bdi to work with.
> 
> Ok, that's good to know. How would we configure this special bdi? I am
> assuming there is no backing device visible in /sys/block/<device>/queue/?
> Same is true for network file systems.
  Where should be the backing device visible? Now it's me who is lost :)

								Honza
-- 
Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
SUSE Labs, CR
