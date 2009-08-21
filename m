From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/8] Use vmalloc for large cgroups pidlist allocations
Date: Fri, 21 Aug 2009 08:53:01 +0800
Message-ID: <4A8DEFED.5090408__11815.498423721$1250816184$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235827.22531.60306.stgit@menage.mtv.corp.google.com>
	<20090820141400.f6d3d5a6.akpm@linux-foundation.org>
	<20090820163510.27942b62@bike.lwn.net>
	<alpine.DEB.2.00.0908201542440.29906@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0908201542440.29906-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

David Rientjes wrote:
> On Thu, 20 Aug 2009, Jonathan Corbet wrote:
> 
>> On Thu, 20 Aug 2009 14:14:00 -0700
>> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>>
>>> Hang on.  Isn't this why Dave just wrote and I just rush-merged
>>> lib/flex_array.c?
>>>
>>> Was that code evaluated for this application and judged unsuitable?  If so,
>>> for what reason?
>> Should it be helpful: I wrote an overview of the flex_array API here:
>>
>> 	http://lwn.net/Articles/345273/
>>
>> I could format it up for addition to Documentation/ if people want.
>>
> 
> It's definitely helpful for this use case, flex array can store 261,632 
> pid_t's on 64 bit.
> 

flex_array surely can be used here, or implement Paul's proposal:
	http://lkml.org/lkml/2009/7/15/226

Note both solutions will probably make the output pid list unsorted.
Or maybe we can implement flex_array_sort().
