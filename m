From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
 namespace is unshared
Date: Wed, 10 Sep 2008 11:23:05 +0200
Message-ID: <48C791F9.8090606@fr.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com> <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com> <m1fxo9mba5.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1fxo9mba5.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> writes:
> 
>> If the upper layers are responsible for providing the utsname, you will need to
>> fix up lockd and the NFS server's callback client too, at  least.
> 
> Actually looking at the code.  It looks like a proper fix may be  even simpler.
> Why do we have both clnt->cl_server and clnt->cl_nodename?    Or is cl_server
> the other side of the connection?
> 
>>>> What are we trying to achieve by reading utsname?
>>> It looks like it gets copied into the sunrpc messages so I assume it is
>>> a part of the sunrpc spec?
>> It appears to be used only for RPC's AUTH_SYS credentials.  The nodename is used
>> to identify the caller's host.  See RFC 1831,  Appendix A:
>>
>>   http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp
> 
> Thanks that helps a lot.
> 
>> I'm not terribly familiar with uts namespaces, though.  Can someone explain why
>> we need to distinguish between these for AUTH_SYS if the  caller is on a remote
>> system?
> 
> Semantically processes in different uts namespaces are on different machines.
> 
>> I don't like the idea of an oops in here.  Instead, (for now) it should warn and
>> fail to create the client, IMO.
> 
> Which is interesting when the problem happens during NFS unmount.  Although
> frankly it could fail anyway.
> 
> It seems strange that we are creating a client during unmount anyway.

the task exiting brings down the lockd thread and unregisters the lockd service 
with the portmapper. This is done with a rpc call which creates a client and a
request.

that's how I understand the code and the oops.


C.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
