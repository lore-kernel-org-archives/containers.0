From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 04:32:10 -0400
Message-ID: <49C0B18A.90208@cs.columbia.edu>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<49B99144.9000106@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49B99144.9000106-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Daniel Lezcano wrote:
> Dan Smith wrote:
>> NL> I'd like there to be some discussion about this, because namespace
>> NL> creation seems like a significant addition to the semantics of
>> NL> restart as I understand it.
>>
>> Indeed.
>>
>> NL> Is namespace creation during restart unavoidable, or merely
>> NL> desirable?  Is there a case for requiring the user to provide a
>> NL> suitable namespace environment before attempting restart?
>>
>> Information about the namespaces has to be saved at checkpoint time no
>> matter what, right?  I guess I don't see any compelling reason to not
>> have the restart operation replicate the environment of the original
>> process.  Otherwise we require userspace to read and interpret the
>> checkpoint stream and selectively feed the bits that the kernel is
>> responsible for to the kernel and process the rest itself (or have the
>> kernel ignore those records).
>>   
> 
> Assuming you have a process and this one unshared the network 100 times 
> and each time opens a socket, how do you checkpoint these namespaces ?
> 
>> What's the argument for depending on userspace to set this up?
>>   
> Maybe, CR of the namespaces is more complicate topic than it looks like 

s/Maybe/Surely/ ...

> and the CR itself is big enough to not complicate things. IMHO, I would 
> recommend as the first step to forbid the unshare inside a container and 
> let the container implementation to save the configuration with the 
> statefile in order to recreate it at the restart
> 

Agreed.

Oren.
