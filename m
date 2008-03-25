From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Tue, 25 Mar 2008 21:35:44 +0900
Message-ID: <47E8F1A0.5080209@mxp.nes.nec.co.jp>
References: <47E88129.1010705@mxp.nes.nec.co.jp>
	<20080325085723.698C11E936D@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080325085723.698C11E936D-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>>> Daisuke Nishimura wrote:
>>>>> Hi, Yamamoto-san.
>>>>>
>>>>> I'm reviewing and testing your patch now.
>>>>>
>>>> In building kernel infinitely(in a cgroup of
>>>> memory.limit=64M and swap.limit=128M, with swappiness=100),
>>>> almost all of the swap (1GB) is consumed as swap cache
>>>> after a day or so.
>>>> As a result, processes are occasionally OOM-killed even when
>>>> the swap.usage of the group doesn't exceed the limit.
>>>>
>>>> I don't know why the swap cache uses up swap space.
>>>> I will test whether a similar issue happens without your patch.
>>>> Do you have any thoughts?
>>> my patch tends to yield more swap cache because it makes try_to_unmap
>>> fail and shrink_page_list leaves swap cache in that case.
>>> i'm not sure how it causes 1GB swap cache, tho.
>>>
>> Agree.
>>
>> I suspected that the cause of this problem was the behavior
>> of shrink_page_list as you said, so I thought one of Rik's
>> split-lru patchset:
>>
>>   http://lkml.org/lkml/2008/3/4/492
>>   [patch 04/20] free swap space on swap-in/activation
>>
>> would reduce the usage of swap cache to half of the total swap.
>> But it didn't help, so I think there may be some other causes.
> 
> do you mean you tested with the patch in the url?
> i don't think remove_exclusive_swap_page works for us
> because our page has more references than it expects.
> ie. ptes, cache, isolate_page
> 
umm... you are right.

I missed the fact that isolate_page increases page count.


Thanks,
Daisuke Nishimura.
