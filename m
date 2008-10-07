From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] netns: Delete virtual interfaces during namespace cleanup
Date: Tue, 07 Oct 2008 14:07:00 +0200
Message-ID: <48EB50E4.3060303@fr.ibm.com>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org> <48EB36FC.4000008@fr.ibm.com>
	<m1ej2s7kmj.fsf@frodo.ebiederm.org> <48EB4679.1040602@fr.ibm.com>
	<m1fxn839y3.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1fxn839y3.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> 
>> Perhaps, I am misunderstanding your sentence :) But just in case, let me clarify
>> my idea.
>>
>> If you have a TCP connection with a send queue not empty (the kernel has
>> buffered the data the application has sent), when your process exits because the
>> last socket write was done in userspace, the TCP socket will be orphan but still
>> there taking a ref count on your network namespace. Hence the process and the
>> network namespace life cycles is not correlated. This is a correct behavior, it
>> is not a bug.
> 
> Agreed, letting the network stack finish sending the last bits of data from
> sockets is not a bug.
> 
> The problem I see is having a veth device that exists in a child container,
> and the application waiting for the child device to return to the current network
> namespace.  Since we always return network devices to the initial network namespace
> waiting for a device in a child container does not work in a recursive container.
> And thus is a bug.

I agree.

>> Can a process outside of the network namespace look at this directory even if
>> there are no more processes running inside the namespace ?
> 
> If you mount it somewhere besides /proc/self/net yes.
> 
> Say: mount --bind /proc/self/net /tmp/net

Ok, thanks.

>>> That is simple and will work quite nicely in the long term, and gives
>>> us a lot more visibility than a simple this namespace has exited bit.
>> This is nice :)
>>
>> Shouldn't you send /proc/net filesystem patch before sending the virtual network
>> devices autodestroy patch ?
> 
> Well there is the cheap trick with this patch of waiting until the local end
> of veth dies.

I actually use veth, macvlan, empty netns and physical. But if you are 
planning the send netns fs soon, I guess I can live with that a time.

Thanks.
   -- Daniel
