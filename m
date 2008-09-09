From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Tue, 9 Sep 2008 13:07:40 -0400
Message-ID: <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080909152952.GA21207-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sep 9, 2008, at Sep 9, 2008, 11:29 AM, Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> Thanks, Cedric.  Eric is probably right about the long-term fix, but
>>> yeah it might take a while to properly wade through the sunrpc and  
>>> nfs
>>> layers to store the nodename at nfs mount time, and in the  
>>> meantime this
>>> fixes a real oops.
>>
>> A very esoteric oops that hasn't shown up for two years.
>
> But an easily reproducible one.
>
> It's not as though we'll stop looking for the right fix just bc we  
> have
> this "bad" fix in for a short while.
>
>> Please let's look at this and see what it would take to fix this
>> properly.
>
> Of course.  Cedric is looking at the best way to fix it...

If the upper layers are responsible for providing the utsname, you  
will need to fix up lockd and the NFS server's callback client too, at  
least.

>> What are we trying to achieve by reading utsname?
>
> It looks like it gets copied into the sunrpc messages so I assume it  
> is
> a part of the sunrpc spec?

It appears to be used only for RPC's AUTH_SYS credentials.  The  
nodename is used to identify the caller's host.  See RFC 1831,  
Appendix A:

   http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp

I'm not terribly familiar with uts namespaces, though.  Can someone  
explain why we need to distinguish between these for AUTH_SYS if the  
caller is on a remote system?

> I don't want to do this, but we *could* put a conditional in utsname()
> to have it return init_utsname if current->nsproxy is null...

I don't like the idea of an oops in here.  Instead, (for now) it  
should warn and fail to create the client, IMO.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
