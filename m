From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc userspace tools 0.3.0 released
Date: Thu, 16 Oct 2008 11:50:11 +0200
Message-ID: <48F70E53.9070002@fr.ibm.com>
References: <48F4AF2E.3000204@fr.ibm.com>
	<7fac565a0810160122n7afa6e71l929be8cb08ba05c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7fac565a0810160122n7afa6e71l929be8cb08ba05c6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Tue, Oct 14, 2008 at 2:39 PM, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
>> Hi,
>>
>> a new version of lxc has been released.
>>
>>        https://sourceforge.net/projects/lxc/
>>
>> This version takes into account the control group and provides the
>> checkpoint / restart for external checkpoint.
>>
>> It includes a lot of small improvements and fixes, full details are in
>> the ChangeLog file.
>>
>> Thanks.
>>   -- Daniel
> 
> Hi !
> 
> I'm glad to hear about progress of Linux containers.
> 
> But I have a few questions:
> 1. How does LXC compare to OpenVZ ?

I used OpenVZ a few years ago, so perhaps I am wrong comparing OpenVZ 
and LXC, I know the openvz devel mailling list is tied with the 
containers@ mailing, so I hope if I am wrong someone will correct me :)

Just to clarify to avoid confusion. There is a LXC project inside the 
libvirt and there is the lxc userspace tools (liblxc). We are talking 
about the liblxc.

The liblxc is a low level component. There is a library and a set of 
command lines.

The library provides a set of API to manage the containers. That allows 
people to start, stop, create, destroy, monitor, etc ... containers.
On top of that, there is a set of command lines relying on this library 
to play with the containers in a shell.

OpenVZ is a full featured container, providing a lot of services. A 
single command 'vzctl' manages the containers.

The liblxc follows what is in mainline and what will be in mainline. So 
the liblxc can be used with a vanilla kernel or the development kernel 
we are working on.

OpenVZ provides more than what is existing in mainline, that means it 
needs a modified kernel, even if the different features are little by 
little pushed upstream and the OpenVZ kernel patch is being smaller.

The liblxc takes into account two families of containers, the system 
containers and the application containers. The first one launches a full 
distro like a debian, the first process is the 'init' process, the 
system configuration is done by the different services of the distros. 
The second one, launches only an application (that can be 'bash', 
'sshd', or something else), and setup the container (network, mount 
points, etc ...) because there is no services to do that.

OpenVZ, AFAIK, supports the system container but not the application 
containers.

To summarize:

  * OpenVZ is a mature project with a lot of features, (for example the 
migration, checkpoint/restart), aiming to create system container using 
a shell command.

  * Liblxc is a low level component following what is in mainline, (or 
in a near future), with the objective to be simple to use.


> 2. What portion of code is shared between the two ?

I am not sure I understand the question. Do you mean : "is liblxc using 
OpenVZ code ?"
