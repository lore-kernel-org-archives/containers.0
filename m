From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Fri, 23 May 2008 13:27:23 +0900
Message-ID: <483647AB.8090104@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<4835E55A.1000308@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4835E55A.1000308-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi.

On 2008/05/23 6:27 +0900, Balbir Singh wrote:
> Daisuke Nishimura wrote:
>> Hi.
>>
>> I updated my swapcgroup patch.
>>
>> Major changes from previous version(*1):
>> - Rebased on 2.6.26-rc2-mm1 + KAMEZAWA-san's performance
>>   improvement patchset v4.
>> - Implemented as a add-on to memory cgroup.
>>   So, there is no need to add a new member to page_cgroup now.
>> - (NEW)Modified vm_swap_full() to calculate the rate of
>>   swap usage per cgroup.
>>
>> Patchs:
>> - [1/4] add cgroup files
>> - [2/4] add member to swap_info_struct for cgroup
>> - [3/4] implement charge/uncharge
>> - [4/4] modify vm_swap_full for cgroup
>>
>> ToDo:
>> - handle force_empty.
>> - make it possible for users to select if they use
>>   this feature or not, and avoid overhead for users
>>   not using this feature.
>> - move charges along with task move between cgroups.
>>
> 
> Thanks for looking into this. Yamamoto-San is also looking into a swap
> controller. Is there a consensus on the approach?
> 
Not yet, but I think we should have some consensus each other
before going further.


Thanks,
Daisuke Nishimura.
