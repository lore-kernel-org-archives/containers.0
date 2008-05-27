From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Tue, 27 May 2008 19:16:40 +0530
Message-ID: <483C10C0.7040503@linux.vnet.ibm.com>
References: <483647AB.8090104@mxp.nes.nec.co.jp>
	<20080527073118.0D92B5A0E@siro.lan>
	<483BBB4C.3040501@linux.vnet.ibm.com>
	<483BC690.6010206@mxp.nes.nec.co.jp>
	<483C0A0D.50909@linux.vnet.ibm.com>
	<483C0FB2.7080706@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <483C0FB2.7080706-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Daisuke Nishimura wrote:
> On 2008/05/27 22:18 +0900, Balbir Singh wrote:
>> Daisuke Nishimura wrote:
>>> On 2008/05/27 16:42 +0900, Balbir Singh wrote:
>>>> YAMAMOTO Takashi wrote:
>>>>> hi,
>>>>>
>>>>>>> Thanks for looking into this. Yamamoto-San is also looking into a swap
>>>>>>> controller. Is there a consensus on the approach?
>>>>>>>
>>>>>> Not yet, but I think we should have some consensus each other
>>>>>> before going further.
>>>>>>
>>>>>>
>>>>>> Thanks,
>>>>>> Daisuke Nishimura.
>>>>> while nishimura-san's one still seems to have a lot of todo,
>>>>> it seems good enough as a start point to me.
>>>>> so i'd like to withdraw mine.
>>>>>
>>>>> nishimura-san, is it ok for you?
>>>>>
>>> Of cource.
>>> I'll work hard to make it better.
>>>
>>>> I would suggest that me merge the good parts from both into the swap controller.
>>>> Having said that I'll let the two of you decide on what the good aspects of both
>>>> are. I cannot see any immediate overlap, but there might be some w.r.t.
>>>> infrastructure used.
>>>>
>>> Well, you mean you'll make another patch based on yamamoto-san's
>>> and mine?
>>>
>>> Basically, I think it's difficult to merge
>>> because we charge different objects.
>>>
>> Yes, I know - that's why I said infrastructure, to see the grouping and common
>> data structure aspects. I'll try and review the code.
>>
> OK.
> 
> I'll wait for your patch.

Hi, Daisuke-San

I am not sending out any patch (sorry for the confusion, if I caused it). I am
going to review the swapcgroup patchset.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
