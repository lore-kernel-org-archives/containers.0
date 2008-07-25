From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: C/R minisummit notes (namespace naming)
Date: Fri, 25 Jul 2008 15:52:56 -0400
Message-ID: <488A2F18.9030503@cs.columbia.edu>
References: <4887163F.5090801@fr.ibm.com>
	<m1zlo7a9nq.fsf@frodo.ebiederm.org>	<20080725191356.GE28136@us.ibm.com>
	<488A28E4.6080902@fr.ibm.com> <20080725193458.GA12356@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080725193458.GA12356-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>> Serge E. Hallyn wrote:
>>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>>> Currently we have three possibilities on how to name pid namespaces.
>>>> - indirect via processes
>>>> - pids
>>>> - names in the filesystem
>>>>
>>>> We discussed this a bit in the hallway track and pids are look like the way
>>>> to go. Pavel has a patch in progress to help sort this out.
>>>>
>>>> The practical problem we have today is that we need a way to wait for the network
>>>> namespace in particular and namespaces in general to exit.
>>>>
>>>> At a first glance waitid(P_NS, <pid>,....) looks like a useful way to achieve
>>>> this.  After looking at wait a bit more it really is fundamentally just an exit
>>>> status reaper of zombies, that has the option of blocking when the zombies
>>>> do not yet exist.  In any kind of event loop you would wait for SIGCHLD either
>>>> as a signal or with signalfd.
>>>>
>>>> So how shall we wait for a namespace to exit?  My brainstorm tonight suggests
>>>> inotify_add_watch(ifd, "/proc/ns/<pid>", IN_DELETE);
>>>>
>>>> Eric
>>> I'm sorry, I'm still not quite clear on...
>>>
>>> Why?
>>>
>>> You care about when the tasks exit, and you care about when network
>>> devices, for instance, need to be deleted (which you can presumably
>>> get uevents for, when they get moved back into init_net_ns).
>>>
>>> Why do you care when the struct net actually gets deleted?
>> IMO, if we consider a container being an aggregation of different  
>> namespaces, we should consider the container dies when all the  
>> namespaces are dead.
>>
>> One good example is an application ran inside a container and doing a  
>> bulk data writing over the network. When the application finish its last  
>>  call to "send" it will exits. At this point, there is no more processes 
>> running inside the container but we can not consider the container is 
>> dead because there are still some pending datas in the socket to be 
>> delivered to the peer.
>>
>> Eric will post a patch to automatically destroy the virtual devices when  
>> the netns is destroyed, so there is no way to know if a network  
>> namespace is dead or not as the uevent socket will not deliver an event  
>> outside of the container.
> 
> My question remains: who cares?
> 

In the context of CR, you'd care if you migrate a container including its
network stack. In that case, you wanna make sure that:
(1) you save sockets that have data in their (send) queue but otherwise
not attached to any specific process, and
(2) you disable these sockets at the source machine as soon as you enable
the container on the target machine.

Rethinking this, Serge is probably right because one you migrate the network
to the target node, you disable the network (of that container) on the source
node, so you don't care about #2 there anymore...

Oren.
