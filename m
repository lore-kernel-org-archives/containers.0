From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] lxc userspace tools 0.3.0 released
Date: Fri, 17 Oct 2008 22:42:38 +0200
Message-ID: <48F8F8BE.7080509@fr.ibm.com>
References: <48F4AF2E.3000204@fr.ibm.com> <200810161457.45686.dim@openvz.org>
	<48F73358.80208@fr.ibm.com> <200810171208.51783.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810171208.51783.dim-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Mishin <dim-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, igor-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Dmitry Mishin wrote:
> On Thursday 16 October 2008 16:28:08 Daniel Lezcano wrote:
>> Dmitry Mishin wrote:
>>> On Thursday 16 October 2008 13:06:45 Daniel Lezcano wrote:
>>>> Dmitry Mishin wrote:
>>>>> Hi, Daniel!
>>>> Hi Dmitry ! good to see you again :)
>>> Thank you ! :)
>>>
>>>>> I studied a bit lxc tools and have a couple of questions. Could you
>>>>> answer them?
>>>> Of course I can :)
>>>>
>>>>> 1)  Why did you chose such way of a container's configuration storing?
>>>>> IMHO, configuration in one file is better, because this file will be
>>>>> small and could be easily mmap'ed for the following operations instead
>>>>> of multiple readdir() and filesystem lookups.
>>>> I wanted to have the configuration easily hackable, so you can edit
>>>> directly the files inside the directory. For example, if you remove the
>>>> network directory, when you will start the container, the network will
>>>> not be unshared. If you have a single file, that will be more difficult
>>>> to edit especially if it is a binary file.
>>>>
>>>> The container tree contains more than the configuration file, for
>>>> example, it contains some runtime information.
>>>>
>>>> It is true having a mmapped configuration is more efficient but it is
>>>> just for container startup, and there are not thousand of files. The
>>>> application running inside the container is not impacted.
>>> OK, but what if I need some namespace to be shared between containers?
>>> How it will be handled? For example, CT 1 and CT 2 need to share network
>>> namespace, but keep it separated from host one.
>> I think that can be solved by nested container, a container 1, unsharing
>> the network, and inside create 2 containers without unsharing the network.
>>
>> Example:
>> 	in a script called myscript.sh:
>> 		#!/bin/bash
>> 		lxc-execute -n ctr1 echo "hello1" &
>> 		lxc-execute -n ctr2 echo "hello2"
>>
>> 	in the shell:
>> 	lxc-create -n mynetwork -f myconf
>> 	lxc-execute -n mynetwork ./myscript.sh
> I mean how it will be handled from configuration layout POV?
> 
>>
>> Do you have an example, an use case for this kind of configuration ?
> For example, web server and dns server for the same domain, hosted on the 
> external node.

Ok I see, thanks.

> As you mentioned, the goal of this tool is to provide ability for kernel 
> hackers to test namespaces support in mainstream. Thus it should be flexible 
> as possible and do not add limitations over current functionality. Current 
> design of configuration storing is likely to be a week place in this sense. 
> At least I do not understand yet how namespaces inheritance could be 
> reflected in it.

I don't think it is a current limitation as I shown in the previous 
example. Not being able to define a configuration for a nested container 
is not a big issue right now because the nested container are not fully 
supported (eg. network devices being pushed back to init_net).

The configuration storing is I think a good approach and it is not an 
API like the cgroup, it can be changed at any time. The advantage of 
having a tree file for a container will appear more clear with the 
future functionalities.

If the nested containers become a must-have and asked by people, the lxc 
tools will be changed in this way. We can imagine to do like the cgroup 
and create in the container directory a new container directory to 
reflect the hierarchy and we access a container by doing for example 
"lxc-stop -n foo/bar" (bar is a child of foo). We can imagine to 
implement a fuse for containers and create / destroy when doing 
mkdir/rmdir, as well as create a directory when doing lxc_create.

The configuration could be something like:

Create a nested container with two configuration files:
	lxc-create -n foo/bar -f foo.conf -f bar.conf

And so execute:
	lxc-execute -n foo/bar /usr/sbin/httpd /bin/bash

will unshare 'foo', exec 'httpd' and so unshare 'bar' (under 'foo') and 
exec 'bash'

Well these are random thoughts... :)

Thanks
  -- Daniel
