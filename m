From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] netns: Delete virtual interfaces during namespace cleanup
Date: Wed, 08 Oct 2008 16:34:26 +0400
Message-ID: <48ECA8D2.4090406@openvz.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org>
	<48EB36FC.4000008@fr.ibm.com>	<48EB3F72.5090201@openvz.org>
	<m1d4ic4pbr.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1d4ic4pbr.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>> I remember that I promised to prepare the wait-extending patch. But I
>> haven't manage to find time for this, sorry :( In a month or two I will
>> finish one time-hungry task and hopefully be able to do it.
>>
>> As far as this particular patch is concerned.
>>
>> All the virtual devices we have now in namespaces (vlan and tunnels)
>> kill themselves *before* this code is called. But even if we try to
>> move this destruction from modules to here, we'll be in a tricky
>> situation, when the e.g. ipip module has already kfree-d the net_ipip
>> structure, while none of ipip devices are released yet.
>>
>> If we try to look in the future - if we ever have a virtual device
>> driver, that will be able to create its devices in namespace, we'll
>> have to destroy all these devices *before* (or inside) this driver's
>> net->exit callback is called, but this patch dies the ->dellink call
>> at the very end, i.e. *after* any potential ->exit callback.
>>
>> Eric - did you see any device, that was ->dellink-ed by this patch?
> 
> macvlan, veth, and dummy interfaces.  Basically
> everything I use this deletes the virtual interfaces, instead
> of sending them back to the initial network namespace.

OK, then.

Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

>>From the looks of the code vlans are also be handled.
> 
> Things like tun/tap and ipip are handled in the exit methods and I
> have no problem with that, although I do wonder if we are handling
> moving or refusing to move them between namespaces properly.
> 
> For devices that don't need a dedicated virtual interface in
> every network namespace this certainly looks like the easiest
> way to handle them, as the driver doesn't need to a thing
> about network namespaces and the right thing just happens.
> 
> Eric
> 
