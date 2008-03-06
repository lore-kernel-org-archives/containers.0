From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Date: Thu, 6 Mar 2008 09:33:24 +0900
Message-ID: <20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org>
	<Pine.LNX.4.64.0803051400000.22243@blonde.site>
	<47CEAAB4.8070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47CEAAB4.8070208-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 05 Mar 2008 17:14:12 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > Strongly agree.  Nobody's interested in swap as such: it's just
> > secondary memory, where RAM is primary memory.  People want to
> > control memory as the sum of the two; and I expect they may also
> > want to control primary memory (all that the current memcg does)
> > within that.  I wonder if such nesting of limits fits easily
> > into cgroups or will be problematic.
> 
> This nesting would affect the res_couter abstraction, not the
> cgroup infrastructure. Current design of resource counters doesn't
> allow for such thing, but the extension is a couple-of-lines patch :)
> 
IMHO, keeping res_counter simple is better.

Is this kind of new entry in mem_cgroup not good ?
==
struct mem_cgroup {
	...
	struct res_counter	memory_limit.
	struct res_counter	swap_limit.
	..
}
