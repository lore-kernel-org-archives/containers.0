From: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/3] change clone_flags type to u64
Date: Thu, 10 Apr 2008 17:11:53 +0400
Message-ID: <47FE1219.5010405@parallels.com>
References: <20080409222611.GA28087@us.ibm.com>	<20080409223231.GA28267@us.ibm.com>	<871w5enmk7.fsf@basil.nowhere.org>
	<47FE073B.3060007@fr.ibm.com>
	<20080410125205.GG10019@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080410125205.GG10019-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

The was no real rationale except for some people seeing "clone" functionality
as the match and the fact that FS_NAMESCAPE was done so made them believe it is a good way to go.
And I warned about flags limitation at the beginning.
Both OpenVZ/vserver suggested to use a special syscall for handling this.
Maybe it is a good point to switch to it now finally and stop worring about all this?

Andi Kleen wrote:
>> I guess that was a development rationale. 
> 
> But what rationale? It just doesn't make much sense to me.
> 
>> Most of the namespaces are in 
>> use in the container projects like openvz, vserver and probably others 
>> and we needed a way to activate the code.
> 
> You could just have added it to feature groups over time.
> 
>> Not perfect I agree.
>>  
>>> With your current strategy are you sure that even 64bit will
>>> be enough in the end? For me it rather looks like you'll
>>> go through those quickly too as more and more of the kernel
>>> is namespaced.
>> well, we're reaching the end. I hope ! devpts is in progress and
>> mq is just waiting for a clone flag.
> 
> Are you sure?
> 
>>  
>>> Also I think the user interface is very unfriendly. How
>>> is a non kernel hacker supposed to make sense of these 
>>> myriads of flags? You'll be creating another 
>>> CreateProcess123_extra_args_extended() 
>>> in the end I fear.
>> well, the clone interface is a not friendly interface anyway. glibc wraps 
>> it
> 
> But only for the stack setup which is just a minor detail. 
> 
> The basic clone() flags interface used to be pretty sane and usable 
> before it could overloaded with so many tiny features.
> 
> I especially worry on how user land should keep track of changing kernel
> here. If you add new feature flag for lots of kernel features it is
> reasonable to expect that in the future there will be often new features.
> 
> Does this mean user land needs to be updated all the time? Will this
> end up like another udev? 
> 
>> We will need a user library, like we have a libphtread or a libaio, to
> 
> That doesn't make sense. The basic kernel syscalls should be usable,
> not require some magic library that would likely need intimate 
> knowledge of specific kernel versions to do any good.
> 
>> but we still need a way to extend the clone flags because none are left.
> 
> Can we just take out some again that were added in the .25 cycle and
> readd them once there is a properly thought out interface?  That would
> leave at least one.
> 
> -Andi
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
