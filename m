From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 18:01:32 -0600
Message-ID: <20090107000132.GA22261@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <FB1BAB9F-25D4-449F-A66D-D1CC705F3741@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <FB1BAB9F-25D4-449F-A66D-D1CC705F3741-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Chuck Lever (chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
> On Jan 6, 2009, at Jan 6, 2009, 3:02 PM, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> We can often specify the UTS namespace to use when starting an RPC  
>>> client.
>>> However sometimes no UTS namespace is available (specifically during 
>>> system
>>> shutdown as the last NFS mount in a container is unmounted) so fall
>>> back to the initial UTS namespace.
>>
>> So what happens if we take this patch and do nothing else?
>
> I thought the point of this was to prevent incorrect container nodenames 
> from leaking onto the network.

But define incorrect.  If container B does an nfs mount, container c
is launched with a tree in that mount, container B dies, and container C
umounts it.  Should the umount belong to container B (for having
mounted it), container C (for having umount it), or the init_utsname
(for being the physical host/kernel)?

I get the feeling that consensus on this thread is that init_utsname
is actually the best choice, but OTOH if I have 3 containers on my
host, for apache, mysql, and postfix servers, and each is doing
nfs mounts from a physically remote machine, maybe I care about
having them report separate nodenames?

(that's a question, I really don't know...)

-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
