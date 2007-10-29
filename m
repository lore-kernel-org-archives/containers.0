From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
 in unuse_pte()
Date: Tue, 30 Oct 2007 03:31:38 +0530
Message-ID: <47265842.5040506@linux.vnet.ibm.com>
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
	<Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
	<4713A2F2.1010408@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com>
	<471F3732.5050407@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com>
	<4724F0BC.1020209@linux.vnet.ibm.com>
	<20071028203219.GA7145@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710292101510.23980@blonde.wat.veritas.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0710292101510.23980-VFT1Jj/mpSzq8/QPP7pA5326JSxr+BKB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> On Mon, 29 Oct 2007, Balbir Singh wrote:
>> On Mon, Oct 29, 2007 at 01:57:40AM +0530, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>
>> [snip]
>>  
>>> Without your mem_cgroup mods in mm/swap_state.c, unuse_pte makes
>>> the right assignments (I believe).  But I find that swapout (using
>>> 600M in a 512M machine) from a 200M cgroup quickly OOMs, whereas
>>> it behaves correctly with your mm/swap_state.c.
>>>
>> On my UML setup, I booted the UML instance with 512M of memory and
>> used the swapout program that you shared. I tried two things
>>
>>
>> 1. Ran swapout without any changes. The program ran well without
>>    any OOM condition occuring, lot of reclaim occured.
>> 2. Ran swapout with the changes to mm/swap_state.c removed (diff below)
>>    and I still did not see any OOM. The reclaim count was much lesser
>>    since swap cache did not get accounted back to the cgroup from
>>    which pages were being evicted.
>>
>> I am not sure why I don't see the OOM that you see, still trying. May be
>> I missing something obvious at this late hour in the night :-)
> 
> I reconfirm that I do see those OOMs.  I'll have to try harder to
> analyze how they come about: I sure don't expect you to debug a
> problem you cannot reproduce.  But what happens if you try it
> native rather than using UML?
> 
> Hugh

On a real box - a powerpc machine that I have access to

1. I don't see the OOM with the mods removed (I have swap
   space at-least twice of RAM - with mem=512M, I have at-least
   1G of swap).
2. Running under the container is much much faster than running
   swapout in the root container. The machine is almost unusable
   if swapout is run under the root container

At this momemnt, I suspect one of two things

1. Our mods to swap_state.c are different
2. Our configuration is different, main-memory to swap-size ratio


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
