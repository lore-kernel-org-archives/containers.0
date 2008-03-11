From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Date: Tue, 11 Mar 2008 21:29:38 +0530
Message-ID: <47D6AC6A.1060404@linux.vnet.ibm.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
	<6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
	<20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com>
	<47D64E0A.3090907@linux.vnet.ibm.com>
	<6599ad830803110856j5333f032n2e26fb51111a839c@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830803110856j5333f032n2e26fb51111a839c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Mar 11, 2008 at 2:16 AM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> Paul Menage wrote:
>>  > On Tue, Mar 11, 2008 at 2:13 AM, KAMEZAWA Hiroyuki
>>  > <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>  >>  or remove all relationship among counters of *different* type of resources.
>>  >>  user-land-daemon will do enough jobs.
>>  >>
>>  >
>>  > Yes, that would be my preferred choice, if people agree that
>>  > hierarchically limiting overall virtual memory isn't useful. (I don't
>>  > think I have a use for it myself).
>>  >
>>
>>  Virtual limits are very useful. I have a patch ready to send out.
>>  They limit the amount of paging a cgroup can do (virtual limit - RSS limit).
> 
> Ah, from this should I assume that you're talking about virtual
> address space limits, not virtual memory limits?
> 
> My comment above was referring to Pavel's proposal to limit total
> virtual memory (RAM + swap) for a cgroup, and then limit swap as a
> subset of that, which basically makes it impossible to limit the RAM
> usage of cgroups properly if you also want to allow swap usage.
> 
> Virtual address space limits are somewhat orthogonal to that.
> 


Yes, I was referring to Virtual address limits (along the lines of RLIMIT_AS). I
guess it's just confusing terminology. I have patches for Virtual address
limits. I should send them out soon.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
