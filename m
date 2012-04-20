From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Fri, 20 Apr 2012 15:29:30 -0400
Message-ID: <20120420192930.GR22419__30942.6881642596$1334950197$gmane$org@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404175124.GA8931@localhost>
	<20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120406095934.GA10465@localhost>
	<20120417223854.GG19975@google.com>
	<20120419142343.GA12684@localhost>
	<20120419183118.GM10216@redhat.com>
	<20120420124518.GA7133@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120420124518.GA7133@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 20, 2012 at 08:45:18PM +0800, Fengguang Wu wrote:

[..]
> If still keep the global async queue, it can run small 40ms slices
> without defeating the flusher's 500ms granularity. After each slice
> it can freely switch to other cgroups with sync IOs, so is free from
> latency issues. After return, it will continue to serve the same
> inode. It will basically be working on behalf of one cgroup for 500ms
> data, working for another cgroup for 500ms data and so on. That
> behavior does not impact fairness, because it's still using small
> slices and its weight is computed system wide thus exhibits some kind
> of smooth/amortize effects over long period of time. It can naturally 
> serve the same inode after return.

Ok, So tejun did say that we will have a switch where we will allow
retaining the old behavior of keeping all async writes in root group
and not in individual group. So throughput sensitive users can make
use of that and there is no need to push proportional IO logic to
writeback layer for buffered writes?

I am personally is not too excited about the case of putting async IO
in separate groups due to the reason that async IO of one group will
start impacting latencies of sync IO of another group and in practice
it might not be desirable. But there are others who have use cases for
separate async IO queue. So as long as switch is there to change the
behavior, I am not too worried.

Thanks
Vivek
