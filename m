From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Date: Thu, 1 Oct 2009 09:55:12 -0500
Message-ID: <20091001145512.GA17916@us.ibm.com>
References: <20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>
	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>
	<87eipoo0po.fsf@caffeine.danplanet.com> <4AC39CE5.9080908@free.fr>
	<877hvgnv6z.fsf@caffeine.danplanet.com>
	<4AC3D6DC.9010500@free.fr> <20090930224249.GA22977@us.ibm.com>
	<4AC4634F.6070901@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC4634F.6070901-GANU6spQydw@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Serge E. Hallyn wrote:
>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>>   
>>> Dan Smith wrote:
>>>     
>>>> The header file makes it pretty clear what is going on,       
>>> Certainly for you.
>>>     
>>
>> If you're worried about hooking lxc-restart up and that
>> being a mess, 
> Yep, I am worried about that too :)
>
>> i have said that as soon as something hits -mm,
>> I will hook up lxc-restart.  I do agree, the userspace code
>> would be much simpler if we didn't need to do all of the
>> process tree creation in userspace :)
> Yes and I know there were discussions about this point several times for  
> the proctree, I won't argue with kernel vs user proctree creation.
> But what I understood is you will continue to parse the statefile to  
> recreate some other resources like a subset of the network and here I am  
> lost.

If network devices end up being recreated in userspace - either the
ones for the root restarted container, or all the devices including
for any child network namespaces - then I believe they will be
considered container objects.  All the container information is at the
top of the checkpoint file, so the program coordinating the restart
will see all of the information before the task hierarchy.  Actually, I
thought linux-2.6/Documentation/checkpoint/readme.txt used to
explicitly show a 'container information' section between the
image header and task hierarchy.  Oren?

> Who in the linux community will understand what is checkpointed and what  
> is restored from the kernel or from the userspace ?

It should all be documented linux-2.6/Documentation/checkpoint/.  But
right now it's not even settled whether process creation in userspace
is going to be the final acceptable way, so documenting speculation
about how we're going to do network devices just seems too certain to
not end up matching reality.

> Does this imply someone has to use a specific tool like "restart.c"  
> within its own tools, assuming this tool is installed in the system or  
> shall he copy-paste the code of the GPL licensed restart.c to its LGPL  
> licensed tools ?

Hmm, I think a tiny little lgpl library, maybe even shipping under the
kernel tree, implementing a generic, whole-container and sub-tree
checkpoint and restart, makes very good sense.

It certainly does NOT make sense to require multiple projects to track
all changes to the checkpoint image format as the kernel changes...

-serge
