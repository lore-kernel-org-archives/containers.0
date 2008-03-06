From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Date: Thu, 06 Mar 2008 15:25:09 +0300
Message-ID: <47CFE2A5.4000407@openvz.org>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
	<20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
	<47CFD957.3060402@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47CFD957.3060402-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Daisuke Nishimura wrote:
> Hi.
> 
>> At first look, remembering mm struct is not very good.
>> Remembering swap controller itself is better.
> 
> The swap_cgroup when the page(and page_cgroup) is allocated and
> the swap_cgroup when the page is going to be swapped out may be
> different by swap_cgroup_move_task(), so I think swap_cgroup
> to be charged should be determined at the point of swapout.

No. Since we now do not account for the situation, when pages are
shared between cgroups, we may think, that the cgroup, which the 
page was allocated by and the cgroup, which this pages goes to swap 
in are the same.

> Instead of pointing mm_struct from page_cgroup, it would be
> better to determine the mm_struct which the page to be swapped
> out is belongs to by rmap, and charge swap_cgroup of the mm_struct.
> In this implementation, I don't need to add new member to page_cgroup.
> 
> What do you think ?
> 
> 
> Thanks,
> Daisuke Nishimura.
> 
