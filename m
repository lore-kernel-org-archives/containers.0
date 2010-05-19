From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: NFS Kernel server inside a container
Date: Wed, 19 May 2010 21:33:58 +0200
Message-ID: <4BF43D26.7040807@free.fr>
References: <516306.35958.qm@web36107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <516306.35958.qm-xC2hcER8YRCvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/19/2010 05:26 PM, Martin Fick wrote:
> --- On Wed, 5/19/10, Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  wrote:
>
>    
>>> I was wondering if it is possible to run an NFS kernel
>>>        
>> server inside a linux container?
>>      
>>> I tried setting one up on a debian (vserver enabled)
>>>        
>> kernel, and it seems to start the portmap, rpc.statd,
>> rpc.idmapd rpc.mountd daemons inside the container, but I
>> cannot seem to mount the filesystem from a client.  I
>> do get the following error message on server startup:
>>      
>>>     FATAL: Could not load
>>>        
>> /lib/modules/2.6.32-trunk-vserver-686/modules.dep: No such
>> file or directory
>>      
>>>
>>> When trying to mount on the client, after blocking on
>>>        
>> the mount for a while, I get:
>>      
>>>     mount.nfs: mount system call failed
>>>
>>>        
>> It may be possible your network configuration is not
>> correct regarding
>> the nfs server access. Can you ping the nfs server from the
>> container ?
>>
>>      
>>> Any thoughts?  Has anyone else done this?
>>>        
>> Should this be possible in the first place?  Thanks,
>>      
>>>
>>>        
>> I thought NFS was isolated through the mount namespace.
>>
>> I have a nfs server on 172.20.0.1 exporting "/home".
>>
>> On my host (IP 172.20.0.166), I mounted /home via nfs
>>
>> I created a debian system container with its own rootfs and
>> network.
>> Started it. As expected, the nfs mount point is unmounted
>> as it does not
>> belong to the rootfs, and then I remounted /home from my
>> container (IP
>> 172.20.0.42). This mount point is private to the container
>> and not
>> accessible from the other containers.
>>
>> This is what you want to do ? Or did I miss something ?
>>      
> It sounds like you did an NFS client mount inside a
> container. I am actually trying to do the reverse, I
> would like to do kernel server exports from within
> a container.  Specifically, I would like to have
> several data partitions replicated with drbd and to
> be able to export these partitions via NFS
> independently from different containers with
> different IPs.
>    
Oh, ok. Right. I misunderstood. As Michael mentioned, that will need 
some kernel work.
I think nobody is working on that but I recall Denis Lunev from, OpenVZ, 
studied it, a couple of years ago, and said that was a big deal.

> So, for example, from 2 hosts, I might have 6 NFS
> partitions to export and during normal operation
> I would expect each host to make 3 of the
> partitions primary via drbd and to then to
> each launch three containers each with separate
> IPs which will individually export the 3 different
> drbd partitions via NFS.  For failover or load
> balancing, it should then be able to shut down
> any individual container on one host and bring it
> up on the other host without affecting the other
> exports.
>    

Sounds a good idea.

Thanks
   -- Daniel
