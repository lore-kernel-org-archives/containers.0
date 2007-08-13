From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [-mm PATCH 8/9] Memory controller add switch to control what
 type of pages to limit (v4)
Date: Mon, 13 Aug 2007 11:08:58 +0530
Message-ID: <46BFEE72.9080209@linux.vnet.ibm.com>
References: <20070727201103.31565.3104.sendpatchset@balbir-laptop>
	<20070813003348.91E3E1BF943@siro.lan>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070813003348.91E3E1BF943-Pcsii4f/SVk@public.gmane.org>
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
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
>> Choose if we want cached pages to be accounted or not. By default both
>> are accounted for. A new set of tunables are added.
>>
>> echo -n 1 > mem_control_type
>>
>> switches the accounting to account for only mapped pages
>>
>> echo -n 2 > mem_control_type
>>
>> switches the behaviour back
> 
> MEM_CONTAINER_TYPE_ALL is 3, not 2.
> 

Thanks, I'll fix the comment on the top.

> YAMAMOTO Takashi
> 
>> +enum {
>> +	MEM_CONTAINER_TYPE_UNSPEC = 0,
>> +	MEM_CONTAINER_TYPE_MAPPED,
>> +	MEM_CONTAINER_TYPE_CACHED,
>> +	MEM_CONTAINER_TYPE_ALL,
>> +	MEM_CONTAINER_TYPE_MAX,
>> +} mem_control_type;
>> +
>> +static struct mem_container init_mem_container;
> 
>> +	mem = rcu_dereference(mm->mem_container);
>> +	if (mem->control_type == MEM_CONTAINER_TYPE_ALL)
>> +		return mem_container_charge(page, mm);
>> +	else
>> +		return 0;


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
