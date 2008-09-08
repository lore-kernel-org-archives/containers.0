From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
	namespace is unshared
Date: Mon, 8 Sep 2008 10:43:53 -0500
Message-ID: <20080908154353.GA21168@us.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080908151932.GA19023@us.ibm.com> <48C546C0.504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C546C0.504-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> >> On a system with nfs mounts, if a task unshares its mount namespace,
> >> a oops can occur when the system is rebooted if the task is the last
> >> to unreference the nfs mount. It will try to create a rpc request
> >> using utsname() which has been invalidated by free_nsproxy().
> >>
> >> The patch fixes the issue by using the global init_utsname() but at
> >> the same time, it breaks the capability of identifying rpc clients
> >> per uts namespace.
> >>
> >> Any better suggestions ?
> > 
> > But the utsname gets freed after the mnt_ns, so the analysis seems
> > wrong somehow.
> 
> yes but switch_task_namespaces() assigns ->nsproxy to NULL. the result
> is the same.
> 
> > I trust addr2line or whatever verified that rpc_create+0x332/0x42f is
> > exactly at the call to utsname()?
> 
> yes. it points to net/sunrpc/clnt.c:216
> 
> 	clnt->cl_nodelen = strlen(utsname()->nodename);

Pavel, at the mini-summit you mentioned sunrpc transports as one
example of the mini-namespaces openvz currently implements.  We
then apparently went off on a bit of a tangent
(http://wiki.openvz.org/Containers/Mini-summit_2008_notes#Namespaces_and_containers)
after Dave asked for a list of mini-namespaces openvz implements.

What exactly is openvz doing with sunrpc transports, and would it
be a better solution to this problem?

thanks,
-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
