From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc userspace tools 0.3.0 released
Date: Thu, 16 Oct 2008 12:35:49 +0200
Message-ID: <48F71905.2050504@fr.ibm.com>
References: <48F4AF2E.3000204@fr.ibm.com>
	<7fac565a0810160122n7afa6e71l929be8cb08ba05c6@mail.gmail.com>
	<48F70E53.9070002@fr.ibm.com>
	<7fac565a0810160256mc3de8b5raf4bab31470b051a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7fac565a0810160256mc3de8b5raf4bab31470b051a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Eremenko <al4321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexey Eremenko wrote:
> Well, Thanks for explanation...
> 
> libvirt uses liblxc or uses kernelspace containers directly ?

kernelspace containers directly.

>>> 2. What portion of code is shared between the two ?
>> I am not sure I understand the question. Do you mean : "is liblxc using
>> OpenVZ code ?"
>>
> 
> Here I mean that OpenVZ and LXC have kernelspace code shared - at
> least partially.
> (because OpenVZ developers are the ones who are developing kernelspace
> LXC and pushing code upstream)
> 
> Do you know how much of it ?

Well OpenVZ guys are part of the container community, we are working 
together to push upstream the kernel code, this is not only an OpenVZ 
effort.

The userspace code is using a set of services provided by the kernel. So 
instead of talking about shared kernel code, IMO, we can talk about the 
used services by both OpenVZ and liblxc.

I can not give a full detail of what are the services used by OpenVZ but 
I think it is reasonable to say liblxc uses at least a subset of what is 
using OpenVZ.

Here is the detail of the kernel features used by the liblxc:
  * cgroup with cgroup scheduler and all the subsystems
  * freezer
  * ipc namespace
  * pid namespace
  * uts namespace
  * network namespace
  * mount namespace

> I think userspace is not shared at all.

Correct :)
