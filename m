From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Fri, 23 May 2008 02:57:54 +0530
Message-ID: <4835E55A.1000308@linux.vnet.ibm.com>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48350F15.9070007-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Daisuke Nishimura wrote:
> Hi.
> 
> I updated my swapcgroup patch.
> 
> Major changes from previous version(*1):
> - Rebased on 2.6.26-rc2-mm1 + KAMEZAWA-san's performance
>   improvement patchset v4.
> - Implemented as a add-on to memory cgroup.
>   So, there is no need to add a new member to page_cgroup now.
> - (NEW)Modified vm_swap_full() to calculate the rate of
>   swap usage per cgroup.
> 
> Patchs:
> - [1/4] add cgroup files
> - [2/4] add member to swap_info_struct for cgroup
> - [3/4] implement charge/uncharge
> - [4/4] modify vm_swap_full for cgroup
> 
> ToDo:
> - handle force_empty.
> - make it possible for users to select if they use
>   this feature or not, and avoid overhead for users
>   not using this feature.
> - move charges along with task move between cgroups.
> 

Thanks for looking into this. Yamamoto-San is also looking into a swap
controller. Is there a consensus on the approach?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
