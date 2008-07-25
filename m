From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 15:08:42 -0400
Message-ID: <488A24BA.4060204@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<4889D5EE.4010601@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0807251820440.20617@blonde.site>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807251820440.20617-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> On Fri, 25 Jul 2008, Balbir Singh wrote:
>> I'll try and recreate the problem and fix it. If memrlimit_cgroup_uncharge_as()
>> created the problem, it's most likely related to mm->owner not being correct and
>> we are dereferencing the wrong memory.
>>
>> Thanks for the bug report, I'll look further.
> 
> Good luck!  I have only seen it once, on a dual-core laptop; though
> I don't remember to try swapoff while busy as often as I should (be
> sure to alternate between a couple or more of swapareas, so you can
> swap a new one on just before swapping an old one off, to be pretty
> sure of success).
> 

Thanks, that's very useful information. I would have never tried juggling swap
devices otherwise.

> May be easier to find in the source: my suspicion is that a bad
> mm_users assumption will come into it.  But I realize now that it
> could be entirely unrelated to memrlimit, just that uncharge_as
> was the one to get hit by bad refcounting elsewhere.
> 
> Oh, that reminds me, I never reported back on my res_counter warnings
> at shutdown: never saw them again, once I added in the set of changes
> you came up with shortly after that - thanks.
> 

I am glad those messages are gone, thanks for the bug report. I find bug fixing
more exciting that kernel development on most occasions.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
