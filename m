From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Sat, 9 Dec 2017 10:28:08 -0800
Message-ID: <f8ea78be-9bbf-2967-7b12-ac93bb85b0bc__1211.89648421041$1512844719$gmane$org@schaufler-ca.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
	<7ebca85a-425c-2b95-9a5f-59d81707339e@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7ebca85a-425c-2b95-9a5f-59d81707339e-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/9/2017 2:20 AM, Micka=EF=BF=BDl Sala=EF=BF=BDn wrote:
> On 12/10/2017 18:33, Casey Schaufler wrote:
>> On 10/12/2017 7:14 AM, Richard Guy Briggs wrote:
>>> Containers are a userspace concept.  The kernel knows nothing of them.
>>>
>>> The Linux audit system needs a way to be able to track the container
>>> provenance of events and actions.  Audit needs the kernel's help to do
>>> this.
>>>
>>> Since the concept of a container is entirely a userspace concept, a
>>> registration from the userspace container orchestration system initiates
>>> this.  This will define a point in time and a set of resources
>>> associated with a particular container with an audit container ID.
>>>
>>> The registration is a pseudo filesystem (proc, since PID tree already
>>> exists) write of a u8[16] UUID representing the container ID to a file
>>> representing a process that will become the first process in a new
>>> container.  This write might place restrictions on mount namespaces
>>> required to define a container, or at least careful checking of
>>> namespaces in the kernel to verify permissions of the orchestrator so it
>>> can't change its own container ID.  A bind mount of nsfs may be
>>> necessary in the container orchestrator's mntNS.
>>> Note: Use a 128-bit scalar rather than a string to make compares faster
>>> and simpler.
>>>
>>> Require a new CAP_CONTAINER_ADMIN to be able to carry out the
>>> registration.
>> Hang on. If containers are a user space concept, how can
>> you want CAP_CONTAINER_ANYTHING? If there's not such thing as
>> a container, how can you be asking for a capability to manage
>> them?
>>
>>>   At that time, record the target container's user-supplied
>>> container identifier along with the target container's first process
>>> (which may become the target container's "init" process) process ID
>>> (referenced from the initial PID namespace), all namespace IDs (in the
>>> form of a nsfs device number and inode number tuple) in a new auxilliary
>>> record AUDIT_CONTAINER with a qualifying op=3D$action field.
> Here is an idea to avoid privilege problems or the need for a new
> capability: make it automatic. What makes a container a container seems
> to be the use of at least a namespace.

You might think so, but I am assured that you can have a container
without using namespaces. Intel's "Clear Containers", which use
virtualization technology, are one example. I have considered creating
"Smack Containers" using mandatory access control technology, more
to press the point that "containers" is a marketing concept, not
technology.

>  What about automatically create
> and assign an ID to a process when it enters a namespace different than
> one of its parent process? This delegates the (permission)
> responsibility to the use of namespaces (e.g. /proc/sys/user/max_* limit).

That gets ugly when you have a container that uses user, filesystem,
network and whatever else namespaces. If all containers used the same
set of namespaces I think this would be a fine idea, but they don't.

> One interesting side effect of this approach would be to be able to
> identify which processes are in the same set of namespaces, even if not
> spawn from the container but entered after its creation (i.e. using
> setns), by creating container IDs as a (deterministic) checksum from the
> /proc/self/ns/* IDs.
>
> Since the concern is to identify a container, I think the ability to
> audit the switch from one container ID to another is enough. I don't
> think we need nested IDs.

Because a container doesn't have to use namespaces to be a container
you still need a mechanism for a process to declare that it is in fact
in a container, and to identify the container.

>
> As a side note, you may want to take a look at the Linux-VServer's XID.
>
> Regards,
>  Micka=EF=BF=BDl
>
