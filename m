From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Thu, 12 Apr 2012 13:51:48 -0700
Message-ID: <20120412205148.GA24056__22392.996986355$1334263929$gmane$org@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<20120411192231.GF16008@quack.suse.cz>
	<20120412203719.GL2207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120412203719.GL2207-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Vivek.

On Thu, Apr 12, 2012 at 04:37:19PM -0400, Vivek Goyal wrote:
> I mean how are we supposed to put cgroup throttling rules using cgroup
> interface for network filesystems and for btrfs global bdi. Using "dev_t"
> associated with bdi? I see that all the bdi's are showing up in
> /sys/class/bdi, but how do I know which one I am intereste in or which
> one belongs to filesystem I am interestd in putting throttling rule on.
> 
> For block devices, we simply use "major:min limit" format to write to
> a cgroup file and this configuration will sit in one of the per queue
> per cgroup data structure.
> 
> I am assuming that when you say throttling should happen at bdi, you
> are thinking of maintaining per cgroup per bdi data structures and user
> is somehow supposed to pass "bdi_maj:bdi_min  limit" through cgroup files?
> If yes, how does one map a filesystem's bdi we want to put rules on?

I think you're worrying way too much.  One of the biggest reasons we
have layers and abstractions is to avoid worrying about everything
from everywhere.  Let block device implement per-device limits.  Let
writeback work from the backpressure it gets from the relevant IO
channel, bdi-cgroup combination in this case.

For stacked or combined devices, let the combining layer deal with
piping the congestion information.  If it's per-file split, the
combined bdi can simply forward information from the matching
underlying device.  If the file is striped / duplicated somehow, the
*only* layer which knows what to do is and should be the layer
performing the striping and duplication.  There's no need to worry
about it from blkcg and if you get the layering correct it isn't
difficult to slice such logic inbetween.  In fact, most of it
(backpressure propagation) would just happen as part of the usual
buffering between layers.

Thanks.

-- 
tejun
