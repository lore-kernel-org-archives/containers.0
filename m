From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] cr_tests: Fix hang when robust futex lists are
	not	restored during restart
Date: Thu, 09 Jul 2009 16:14:00 -0400
Message-ID: <4A564F88.6090109@cs.columbia.edu>
References: <20090709192207.GJ32310@count0.beaverton.ibm.com>	<20090709200040.GA21053@us.ibm.com>
	<20090709200649.GL32310@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090709200649.GL32310-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Thu, Jul 09, 2009 at 03:00:40PM -0500, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> The robust futex test can hang if the kernel fails to properly set the robust
>>> list pointer. This currently happens during restart. The test should not
>>> hang and instead should report failure.
>>>
>>> Use a timeout to ensure that hangs are caught and reported as failure.
>>> The timeout should return ETIMEDOUT. This limits the total amount of time
>>> checkpoint/restart can take so a suitable timeout is essential here.
>>>
>>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> Reported-by: Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> Hey Matt,
>>
>> last month you sent out a (short) kernel patch for robust futexes.
>> Was that supposed to be enough to fully support c/r of robust futexes?
>>
>> -serge
> 
> Yup. I need to get the update of that patch sent out but the old version
> should still work I think.
> 

Right. Let's get it in for v17.

Oren.
