From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [PATCH] memory controller statistics
Date: Fri, 05 Oct 2007 09:21:06 +0530
Message-ID: <4705B4AA.4070604@linux.vnet.ibm.com>
References: <20070907033942.4A6541BFA52@siro.lan>
	<20071004051332.9BE2C1BF95B@siro.lan>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071004051332.9BE2C1BF95B-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
>> hi,
>>
>> i implemented some statistics for your memory controller.
>>
>> it's tested with 2.6.23-rc2-mm2 + memory controller v7.
>> i think it can be applied to 2.6.23-rc4-mm1 as well.
>>
>> YAMOMOTO Takshi
>>
>> todo: something like nr_active/inactive in /proc/vmstat.
> 
> here's the version i'm working on currently.  any comments?
> 
> changes from the previous version:
> 
> - adapt to 2.6.23-rc8-mm2, container -> cgroup rename.
> - reflect some of comments on this list.
> 	- rename some macros as suggested by balbir
> 	- sprinkle some inlines as suggested by balbir.
> 	- remove "isolate" statistics
> 	- remove PAGE_CONTAINER_CACHE hack and
> 	  add "flags" member to page_container instead.
> 	- make counters atomic_long_t.
> 	- add some comments.
> 	- coding style.
> - implement nr_active/nr_inactive.  they show numbers of pages on
>   per-cgroup lru lists.
> 
> todo:
> - consider to make counters per-cpu.
> - more statistics.
> 
> YAMAMOTO Takashi

Hi, YAMAMOTO-San

Looks much better, I did a quick review, it looks nice to me.
I'll test the patches and get back.

Thank you for working on this,

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
