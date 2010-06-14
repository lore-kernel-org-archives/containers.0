From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6][usercr]: Rename/reorg usercr code
Date: Mon, 14 Jun 2010 17:31:17 -0400
Message-ID: <4C169FA5.5020001@cs.columbia.edu>
References: <20100414004927.GA13012@us.ibm.com>	<20100420180733.GA13874@us.ibm.com>
	<4BD4A501.6070106@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BD4A501.6070106-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Patches 1-3 applied (and will be pushed shortly).

Oren.

On 04/25/2010 04:24 PM, Oren Laadan wrote:
> Hi Suka,
> 
> Thanks for the patchset. A couple of comments:
> 
> * I prefer the header exported to users to be checkpoint.h - this
> is consistent with kernel headers, and with future name of a c/r
> library if we opt libcheckpoint.a
> 
> * I also prefer to leave checkpoint.c as a separate file, as is.
> It may gain more functionality in the future. If the goal was to
> only export a single .o file, then the solution IMHO is to instead
> export a single library: libcheckpoint.a
> 
> Unless you have a strong opinion against the above, I'll go ahead
> and pull patches 1-3, leave out 4-6, and update the Makefile to
> create a libcheckpoint.a library.
> 
> Oren.
> 
> 
> Sukadev Bhattiprolu wrote:
>> Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
>> | 
>> | Change the prefix of the USERCR apis to 'cr_' and reorg the code to avoid
>> | duplication and reduce code size.
>> | 
>> | 	[PATCH 1/6] Change API prefix to cr_
>> | 	[PATCH 2/6] Remove flags parameter to cr_checkpoint()
>> | 	[PATCH 3/6] Minor reorg of restart.c
>> | 	[PATCH 4/6] Move checkpoint() into restart.c
>> | 	[PATCH 5/6] Rename restart.c to cr_checkpoint.c
>> | 	[PATCH 6/6] Rename common.h to cr_log.h
>> | 
>> | With this change, USERCR for now "exports" just the following two files:
>> | 
>> | 	cr_checkpoint.o
>> | 	cr_checkpoint.h
>> | 
>> | But this patchset does cause some churn, let me know if you think any of it
>> | is unnecessary/noise.  I have tested for now along with the patch that removes
>> | most exits() from cr_restart(). If the reorg makes sense, will run all tests
>> | once more and resubmit.
>>
>> All tests in cr-tests pass with these two patchsets (on usercr ckpt-v20-dev
>> and linux ckpt-v21-rc2).
>>
>> Pls let me know if there are comments about the patchsets.
>>
>> Thanks,
>>
>> Sukadev
>>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
