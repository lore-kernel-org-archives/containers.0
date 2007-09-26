From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [PATCH] memory controller statistics
Date: Wed, 26 Sep 2007 08:46:57 +0530
Message-ID: <46F9CF29.9000604@linux.vnet.ibm.com>
References: <46E12020.1060203@linux.vnet.ibm.com>
	<20070926014843.161E61BFA33@siro.lan>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070926014843.161E61BFA33-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>> i implemented some statistics for your memory controller.
>>>
>>> it's tested with 2.6.23-rc2-mm2 + memory controller v7.
>>> i think it can be applied to 2.6.23-rc4-mm1 as well.
>>>
>> Thanks for doing this. We are building containerstats for
>> per container statistics. It would be really nice to provide
>> the statistics using that interface. I am not opposed to
>> memory.stat, but Paul Menage recommends that one file has
>> just one meaningful value.
>>
>> The other thing is that could you please report all the
>> statistics in bytes, we are moving to that interface,
>> I've posted patches to do that. If we are going to push
>> a bunch of statistics in one file, please use a format
>> separator like
>>
>> name: value
> 
> i followed /proc/vmstat.
> are you going to convert /proc/vmstat to the format as well?
> 

I see, no I don't plan to convert /proc/vmstat. I wanted
to make it easier for tools to parse the format. Like
you point out /proc/vmstat uses that format, so I guess
this format is just fine.

Thanks for following up.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
