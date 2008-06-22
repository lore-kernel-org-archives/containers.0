From: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: v2.6.26-rc7/cgroups: circular locking dependency
Date: Sun, 22 Jun 2008 13:50:49 +0400
Message-ID: <20080622095049.GB7285__2155.5989668288$1214128386$gmane$org@cvg>
References: <20080621173859.GA6846@damson.getinternet.no>
	<20080622091013.GA7285@cvg>
	<19f34abd0806220242p62b9a044la6dd8843e5055f84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <19f34abd0806220242p62b9a044la6dd8843e5055f84-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

[Vegard Nossum - Sun, Jun 22, 2008 at 11:42:50AM +0200]
| On Sun, Jun 22, 2008 at 11:10 AM, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
| > [Vegard Nossum - Sat, Jun 21, 2008 at 07:38:59PM +0200]
| > |  =======================================================
| > |  [ INFO: possible circular locking dependency detected ]
| > |  2.6.26-rc7 #25
| > |  -------------------------------------------------------
| > |  bash/10032 is trying to acquire lock:
| > |   (&cpu_hotplug.lock){--..}, at: [<c015efbc>] get_online_cpus+0x2c/0x40
| > |
| > |  but task is already holding lock:
| > |   (cgroup_mutex){--..}, at: [<c0160e6f>] cgroup_lock+0xf/0x20
| 
| ...
| 
| > Hi Vegard,
| >
| > would be interesting to see your config please
| 
| Here is my config and vmlinux:
| 
| http://www.kernel.org/pub/linux/kernel/people/vegard/kernels/20080621-v2.6.26-rc7/
| 
| By the way, I was doing CPU hotplug/unplug at the time.
| 
| Thanks :)
| 
| 
| Vegard
| 
| -- 
| "The animistic metaphor of the bug that maliciously sneaked in while
| the programmer was not looking is intellectually dishonest as it
| disguises that the error is the programmer's own creation."
| 	-- E. W. Dijkstra, EWD1036
| 

Thanks Vegard,

actually i'm not that spec in this area ;) but will take a look

		- Cyrill -
