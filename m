From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: add cgroup->id
Date: Mon, 19 Nov 2012 23:08:51 -0800
Message-ID: <20121120070851.GG25790__4966.93392419747$1353395358$gmane$org@mtj.dyndns.org>
References: <1353093624-22608-1-git-send-email-tj@kernel.org>
	<1353093624-22608-2-git-send-email-tj@kernel.org>
	<50AB086E.70901@jp.fujitsu.com>
	<20121120053112.GE25790@mtj.dyndns.org>
	<50AB2BCF.2050204@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50AB2BCF.2050204-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Kamezawa.

On Tue, Nov 20, 2012 at 04:05:51PM +0900, Kamezawa Hiroyuki wrote:
> BTW, css's ID was limited to 65535 to be encoded in 2bytes.
> If we use INT, this will increase size of swap_cgroup.
> (2bytes per page => 4bytes per page) It's preallocated at swapon()
> because allocating memory dynamically when we swap a memory is not good.
> 
> Do we really need 4bytes for ID ? If so, swap_cgroup should be totally re-designed.

That's a memcg restriction which shouldn't have been imposed on cgroup
core from the beginning.  What memcg should do is rejecting to become
online from ->css_onilne() if cgrp->id is out of the range it can
handle.

Thanks.

-- 
tejun
