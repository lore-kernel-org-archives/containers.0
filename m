From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: sysctl variables are not available to newly created namespace
Date: Thu, 28 Jul 2016 08:22:00 -0500
Message-ID: <877fc5kidj.fsf@x220.int.ebiederm.org>
References: <8FAD92B89CFCF442A932848BE6809DD30A1277@G4W3221.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8FAD92B89CFCF442A932848BE6809DD30A1277-oqutU3L0SekSZAcGdq5asR6epYMZPwEe5NbjCUgZEJk@public.gmane.org>
	(Madhukrishna G.'s message of "Wed, 27 Jul 2016 11:10:36 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "G, Madhukrishna" <madhukrishna.g-ZPxbGqLxI0U@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

"G, Madhukrishna" <madhukrishna.g-ZPxbGqLxI0U@public.gmane.org> writes:

> Hi,
>
> In my current linux 3.2.71 stable version , I have created a network
> namespace  and when I listed sysctl variables in  following directory
> " /proc/sys/net/core/" am able to see net.core.xfrm* variables only,
> i.e only CONFIG_SYSCTL related variables, even though I have enabled
> CONFIG_NET as well as CONFIG_NET_NS I am not able to see any sysctl
> variables related to ne.core(rmem_max, wmem_max, rmem_default and
> wmem_default).
>

The only networking sysctls that are shown are the networking sysctls
that are local to your network namespace (unless you are in the
initial network namespace).

> #<mailto:root@ned4g8:/home/gmadhuk/linux-3.16-clim-3.16.7-clim#> ip netns exec gmk1 ls -l /proc/sys/net/core/
> total 0
> -rw-r--r-- 1 root root 0 Jul 25 03:01 somaxconn
> -rw-r--r-- 1 root root 0 Jul 25 03:01 xfrm_acq_expires
> -rw-r--r-- 1 root root 0 Jul 25 03:01 xfrm_aevent_etime
> -rw-r--r-- 1 root root 0 Jul 25 03:01 xfrm_aevent_rseqth
> -rw-r--r-- 1 root root 0 Jul 25 03:01 xfrm_larval_drop
>
>
> Where as in my older kernel version, it will show all sysctl variables.
> # ls -l /proc/sys/net/core/
> total 0
> -rw-r--r-- 1 root root 0 Jul 20 05:40 busy_poll
> -rw-r--r-- 1 root root 0 Jul 20 05:40 busy_read
> -rw-r--r-- 1 root root 0 Jul 20 05:40 default_qdisc
> -rw-r--r-- 1 root root 0 Jul 20 05:40 dev_weight
> -rw-r--r-- 1 root root 0 Jul 20 05:40 flow_limit_cpu_bitmap
> -rw-r--r-- 1 root root 0 Jul 20 05:40 flow_limit_table_len
> -rw-r--r-- 1 root root 0 Jul 20 05:40 message_burst
> -rw-r--r-- 1 root root 0 Jul 20 05:40 message_cost
> -rw-r--r-- 1 root root 0 Jul 20 05:40 netdev_budget
> -rw-r--r-- 1 root root 0 Jul 20 05:40 netdev_max_backlog
> -rw-r--r-- 1 root root 0 Jul 20 05:40 netdev_tstamp_prequeue
> -rw-r--r-- 1 root root 0 Jul 20 05:40 optmem_max
> -rw-r--r-- 1 root root 0 Jul 20 05:40 rmem_default
> -rw-r--r-- 1 root root 0 Jul 20 05:40 rmem_max
> -rw-r--r-- 1 root root 0 Jul 20 05:40 rps_sock_flow_entries
> -rw-r--r-- 1 root root 0 Jul 20 05:40 somaxconn
> -rw-r--r-- 1 root root 0 Jul 20 05:40 warnings
> -rw-r--r-- 1 root root 0 Jul 20 05:40 wmem_default
> -rw-r--r-- 1 root root 0 Jul 20 05:40 wmem_max
> -rw-r--r-- 1 root root 0 Jul 20 05:40 xfrm_acq_expires
> -rw-r--r-- 1 root root 0 Jul 20 05:40 xfrm_aevent_etime
> -rw-r--r-- 1 root root 0 Jul 20 05:40 xfrm_aevent_rseqth
> -rw-r--r-- 1 root root 0 Jul 20 05:40 xfrm_larval_drop

Yep.  That was a bug, now fixed.

Eric
