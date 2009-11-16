From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] [RFC] checkpoint/restart timerfd
Date: Mon, 16 Nov 2009 13:56:54 -0500
Message-ID: <4B01A076.7010102@cs.columbia.edu>
References: <96703bfb68e1626100dd5fa6ce033ec204bcb58b.1258159772.git.matthltc@us.ibm.com>
	<20091116040403.GK891@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091116040403.GK891-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Fri, Nov 13, 2009 at 04:49:35PM -0800, Matt Helsley wrote:
>> Support checkpoint/restart of timers specified via timerfd. Checkpoint
>> essentially does the timerfd_gettime() syscall and saves the expired flags
>> and tick count. This ensures there will be no lost expirations/ticks
>> between checkpoint restart.
>>
>> This should largely work as expected since the time returned from gettime
>> is always relative.
>>
>> However, like any time-sensitive state, timerfds set with TFD_TIMER_ABSTIME
>> may expire/tick at the "wrong time" because that time has long since passed.
>> Short of introducing time namespaces there's almost nothing that can be done
>> to checkpoint these uses of timerfd. Would it make more sense to mark timerfds
>> which were (re)set with TFD_TIMER_ABSTIME and refuse to checkpoint them rather
>> than deliver a "best-effort" expiration/tick?
>>
>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> --
>> NOTE: Compiles, untested.
>> ---
>>  fs/timerfd.c                   |  113 ++++++++++++++++++++++++++++++++++++----
> 
> Argh. Missed the "restore" path which requires installing a handler for
> these files in checkpoint/file.c. Fixed.

So in that missing part (here and in signalfd), make sure it also
compiles without CONFIG_{SIGNAL,TIMER}_FD. And ignore this comment
if you already did...

Oren.
