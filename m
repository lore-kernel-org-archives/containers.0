From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
 namespace is unshared
Date: Tue, 09 Sep 2008 17:40:54 +0200
Message-ID: <48C69906.5070703@fr.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080909152952.GA21207-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> Thanks, Cedric.  Eric is probably right about the long-term fix, but
>>> yeah it might take a while to properly wade through the sunrpc and nfs
>>> layers to store the nodename at nfs mount time, and in the meantime this
>>> fixes a real oops.
>> A very esoteric oops that hasn't shown up for two years.
> 
> But an easily reproducible one.
> 
> It's not as though we'll stop looking for the right fix just bc we have
> this "bad" fix in for a short while.
> 
>> Please let's look at this and see what it would take to fix this
>> properly.
> 
> Of course.  Cedric is looking at the best way to fix it...

yes. well, my eyes are making progress in the NFS code. it will take some 
time :)

>> What are we trying to achieve by reading utsname?
> 
> It looks like it gets copied into the sunrpc messages so I assume it is
> a part of the sunrpc spec?
> 
> I don't want to do this, but we *could* put a conditional in utsname()
> to have it return init_utsname if current->nsproxy is null...

I nearly did that one but it will hide future misusage of utsname(). So 
I think it's better to keep it that way, and let the machine oops when
we need to fix our code. 

C.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
