From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Tue, 17 Apr 2012 15:01:06 -0700
Message-ID: <20120417220106.GF19975__5814.28044611147$1334700083$gmane$org@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<20120411192231.GF16008@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120411192231.GF16008-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Apr 11, 2012 at 09:22:31PM +0200, Jan Kara wrote:
> > So all the metadata IO will happen thorough journaling thread and that
> > will be in root group which should remain unthrottled. So any journal
> > IO going to disk should remain unthrottled.
>
>   Yes, that is true at least for ext3/ext4 or btrfs. In principle we don't
> have to have the journal thread (as is the case of reiserfs where random
> writer may end up doing commit) but let's not complicate things
> unnecessarily.

Why can't journal entries keep track of the originator so that bios
can be attributed to the originator while committing?  That shouldn't
be too difficult to implement, no?

> > Now, IIRC, fsync problem with throttling was that we had opened a
> > transaction but could not write it back to disk because we had to
> > wait for all the cached data to go to disk (which is throttled). So
> > my question is, can't we first wait for all the data to be flushed
> > to disk and then open a transaction for metadata. metadata will be
> > unthrottled so filesystem will not have to do any tricks like bdi is
> > congested or not.
>
>   Actually that's what's happening. We first do filemap_write_and_wait()
> which syncs all the data and then we go and force transaction commit to
> make sure all metadata got to stable storage. The problem is that writeout
> of data may need to allocate new blocks and that starts a transaction and
> while the transaction is started we may need to do some reads (e.g. of
> bitmaps etc.) which may be throttled and at that moment the whole
> filesystem is blocked. I don't remember the stack traces you showed me so
> I'm not sure it this is what your observed but it's certainly one possible
> scenario. The reason why fsync triggers problems is simply that it's the
> only place where process normally does significant amount of writing. In
> most cases flusher thread / journal thread do it so this effect is not
> visible. And to precede your question, it would be rather hard to avoid IO
> while the transaction is started due to locking.

Probably we should mark all IOs issued inside transaction as META (or
whatever which tells blkcg to avoid throttling it).  We're gonna need
overcharging for metadata writes anyway, so I don't think this will
make too much of a difference.

Thanks.

-- 
tejun
