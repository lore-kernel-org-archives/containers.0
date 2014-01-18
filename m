From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/6] cgroup: make CONFIG_NET_CLS_CGROUP and
	CONFIG_NETPRIO_CGROUP bool instead of tristate
Date: Sat, 18 Jan 2014 10:28:13 -0500
Message-ID: <20140118152813.GG3640__27112.8187807792$1390058907$gmane$org@htj.dyndns.org>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
	<1389982317-22225-2-git-send-email-tj@kernel.org>
	<52D9D421.6040608@huawei.com>
	<20140118151006.GF3640@htj.dyndns.org>
	<52DA9D20.6010301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52DA9D20.6010301-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jan 18, 2014 at 04:26:24PM +0100, Daniel Borkmann wrote:
> >Unless there's gonna be another rc, I think it's already a bit too
> >late for 3.14 anyway.  I'll drop the net_cls part and rebase the
> >changes on top of rc1 later on.
> 
> I think that's 1 patch of your series, right?

They overlap.

> I think this one could still go through net-next if you want, that would
> avoid a merge conflict.

If there's gonna be another rc, I'll prolly just cherry-pick the
commit from net-next and then rebase the rest on top of it.  If there
isn't gonna be another rc, I'm just gonna base everything on v3.14-rc1
which would include the patch from net-next.

Thanks.

-- 
tejun
