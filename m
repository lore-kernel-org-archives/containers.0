From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/4] io controller: documentation
Date: Mon, 10 Nov 2008 08:44:07 -0500
Message-ID: <20081110134407.GA26956__35623.9903405823$1226325161$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
	<20081106153135.743458085@redhat.com>
	<4917A116.7040603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4917A116.7040603-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Nov 10, 2008 at 10:48:54AM +0800, Li Zefan wrote:
> Hi, Vivek
> 
> Thanks for your work. :)
> 
> A question below.
> 
> > +For example, assume there are two cgroups A and B with weights 1024 and 2048
> > +in the system. Tasks in two cgroups A and B are doing IO to two disks sda and
> > +sdb in the system. A user has enabled IO control on both sda and sdb. Now on
> > +both sda and sdb, tasks in cgroup B will get to use 2/3 of disk BW and
> > +tasks in cgroup A will get to use 1/3 of disk bandwidth, only in case of
> > +contention. If tasks in any of the groups stop doing IO to a particular disk,
> > +task in other group will get to use full disk BW for that duration.
> > +
> 
> So in this example, I can't assign 1/3 of sda's disk BW while 2/3 of sdb's
> disk BW to A. Am I right?

Hi,

Yes you are right. Currently policies are global and not per disk. So in 
above example, cgroup A will get 1/3 of disk BW both on sda and sdb. And
one can not configure in such a manner so that A gets 1/3 of BW on sda and
2/3 of BW on sdb.

I think assigning cgroup weights per disk should be doable but personally
I think it makes configuration complex and I am not sure if it really a
very useful feature.

Thanks
Vivek
