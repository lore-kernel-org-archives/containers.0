From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: New LXC HOW-TO
Date: Tue, 27 Oct 2009 17:42:25 +0900
Message-ID: <20091027174225.ddd56319.kamezawa.hiroyu@jp.fujitsu.com>
References: <68e6eac60910171732w6b7fe5dbt755963653e417302@mail.gmail.com>
	<68e6eac60910180710j6ebce156w886588013786b4e9@mail.gmail.com>
	<4ADB37DF.8050907@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4ADB37DF.8050907-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 18 Oct 2009 17:44:31 +0200
Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> AFAIR these following options add some overhead especially the memory resource controller.
> 
> CONFIG_CGROUP_CPUACCT=y
> CONFIG_RESOURCE_COUNTERS=y
> CONFIG_CGROUP_MEM_RES_CTLR=y
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> CONFIG_MM_OWNER=y
> 
> 
sorry, memcg's performance fix is now tested under -mm kernel.
plz wait for 2.6.33 ;(

Thanks,
-Kame
