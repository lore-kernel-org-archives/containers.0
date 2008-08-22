From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 1/9] Create trivial sys_checkpoint/sys_restart
	syscalls
Date: Fri, 22 Aug 2008 17:20:14 -0400
Message-ID: <48AF2D8E.9000405__28478.1165457845$1219440148$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0808202302510.17436@takamine.ncl.cs.columbia.edu>
	<1219433578.20559.98.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219433578.20559.98.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Wed, 2008-08-20 at 23:03 -0400, Oren Laadan wrote:
>> 6/unistd_32.h
>> index d739467..88bdec4 100644
>> --- a/include/asm-x86/unistd_32.h
>> +++ b/include/asm-x86/unistd_32.h
>> @@ -338,6 +338,8 @@
>>   #define __NR_dup3             330
>>   #define __NR_pipe2            331
>>   #define __NR_inotify_init1    332
>> +#define __NR_checkpoint                333
>> +#define __NR_restart           334
>>
>>   #ifdef __KERNEL__
> 
> Uh oh.  These got whitespace mangled somehow.  I'll look through them,
> but probably can't produce patches on top of them for now.
> 

Oops .. not sure what happened.
I'll re-send after addressing the recent comments.

Oren.
