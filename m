From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Date: Thu, 01 Oct 2009 10:07:43 +0200
Message-ID: <4AC4634F.6070901@free.fr>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>
	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>
	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>
	<87eipoo0po.fsf@caffeine.danplanet.com> <4AC39CE5.9080908@free.fr>
	<877hvgnv6z.fsf@caffeine.danplanet.com>
	<4AC3D6DC.9010500@free.fr> <20090930224249.GA22977@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090930224249.GA22977-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>   
>> Dan Smith wrote:
>>     
>>> The header file makes it pretty clear what is going on, 
>>>       
>> Certainly for you.
>>     
>
> If you're worried about hooking lxc-restart up and that
> being a mess, 
Yep, I am worried about that too :)

> i have said that as soon as something hits -mm,
> I will hook up lxc-restart.  I do agree, the userspace code
> would be much simpler if we didn't need to do all of the
> process tree creation in userspace :)
Yes and I know there were discussions about this point several times for 
the proctree, I won't argue with kernel vs user proctree creation.
But what I understood is you will continue to parse the statefile to 
recreate some other resources like a subset of the network and here I am 
lost.
Who in the linux community will understand what is checkpointed and what 
is restored from the kernel or from the userspace ?

Does this imply someone has to use a specific tool like "restart.c" 
within its own tools, assuming this tool is installed in the system or 
shall he copy-paste the code of the GPL licensed restart.c to its LGPL 
licensed tools ?

I am not arguing against the Checkpoint / Restart, IMO the general 
approach is good.
But I am just worried about who will be able to implement a CR solution 
using what is provided by the kernel, except a few people who 
implemented it.

>   I *would* prefer if
> we didn't have to parse the image in userspace.  But the
> moment it was decided that portability across kernel versions
> woudl be done by having userspace process the image, we lost
> that fight.
>   
Yeah, a big deal.

Thanks
    -- Daniel
