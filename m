From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Simplify memory controller and resource counter I/O
Date: Fri, 05 Oct 2007 09:01:58 +0530
Message-ID: <4705B02E.8040701@linux.vnet.ibm.com>
References: <46F9DD4F.50806@google.com>
	<6599ad830710041755w3ed8b1fgd3dfbe7a8e0fc6c5@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710041755w3ed8b1fgd3dfbe7a8e0fc6c5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Hi Balbir,
> 
> Any thoughts on this patch?
> 

Hi, Paul,

I remember seeing this patch, sorry for not responding earlier

> Cheers,
> 
> Paul
> 
> On 9/25/07, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> Simplify the memory controller and resource counter I/O routines
>>
>> This patch strips out some I/O boilerplate from resource counters and
>> the memory controller. It also adds locking to the resource counter
>> reads and writes, and forbids writes to the root memory cgroup's limit
>> file.
>>

Forbidding writing to the root resource counter is a policy decision
I am unable to make up my mind about. It sounds right, but unless
we have a notion of unlimited resources, I am a bit concerned about
taking away this flexibility.

>> One arguable drawback to this patch is that the use of memparse() is
>> lost in the cleanup. Having said that, given the existing of shell
>> arithmetic, it's not clear to me that typing
>>

memparse(), makes it so much easier, we need to use it.

>> echo $[2<<30] > memory.limit
>>

Very geeky! I don't like it personally

>> is especially harder than
>>
>> echo 2G > memory.limit
>>
>> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>

I like the read_uint() and write_uint() overall, but in the case
of setting the limit, I'd still like the flexibility of having
a strategy pattern that would make the UI more friendly.

Do read_uint() and write_uint(), just read and write unsigned
integers?

[snip]

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
