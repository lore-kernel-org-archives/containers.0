From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Wed, 03 Sep 2008 14:15:27 +0200
Message-ID: <48BE7FDF.3080202__46846.64915917$1220444403$gmane$org@fr.ibm.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<48BA454F.7050308@cs.columbia.edu> <48BAD637.2050505@fr.ibm.com>
	<200809031543.24001.amirkin@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200809031543.24001.amirkin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <amirkin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrey Mirkin wrote:
> On Sunday 31 August 2008 21:34 Cedric Le Goater wrote:
>> Oren Laadan wrote:
>>> Dave, Serge:
>>>
>>> I'm currently away so I must keep this short. I think we have so far
>>> more discussion than an actual problem. I'm happy to coordinate with
>>> every interested party to eventually see this work go into main stream.
>> thanks. We do need a moderator and federator.
>>
>>> My only concerns are twofold: first, to get more feedback I believe we
>>> need to get the code a bit more usable; including FDs is an excellent
>>> way to actually do that. That will add significant value to the patch.
>> hmm, yes and no.
>>
>> fd's are a must have but I would be more interested to see an external
>> checkpoint/restart and signal support first. why ? because it would be
>> already usable for most computational programs in HPC, like this stupid
>> one :
>>
>> 	https://www.ccs.uky.edu/~bmadhu/pi/pi1.c
>>
>> signals are required because it's how 'load' and/or 'system' managers
>> interact with the jobs they spawn. external checkpoint/restart for the
>> same reason.
> 
> I'm sorry for being out of discussion for so long time.
> I've just sent a patchset with external checkpoint/restart as it is 
> implemented in OpenVZ.
> External checkpoint/restart also is very usefull if we will have container's 
> infrastructure in mainstream.
> It won't be very hard to add support for signals in my patchset. I'll wait for 
> some time for comments and will add support for signals in next version.

OK.

Then, we should be able to have a simple C/R framework (user and kernel) if we
integrate your patchset or Oren's with Daniel's user tools :

	http://lxc.cvs.sourceforge.net/lxc/

I was just starting to work on Oren's patchset when you sent yours :) 

Thanks,

C.
