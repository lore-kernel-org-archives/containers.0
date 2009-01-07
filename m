From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/4] sunrpc: Improve UTS namespace workaround
Date: Tue, 06 Jan 2009 19:02:12 -0800
Message-ID: <1231297332.14345.334.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011315.100081168@us.ibm.com>
	 <E184097A-C995-4C92-9608-A97B43E750E0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E184097A-C995-4C92-9608-A97B43E750E0-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Argh, missed some questions I should've answered earlier...

On Tue, 2009-01-06 at 11:02 -0500, Chuck Lever wrote:
> Matt-
> 
> Thanks for pursuing a permanent fix for this.
> 
> On Jan 5, 2009, at Jan 5, 2009, 8:13 PM, Matt Helsley wrote:
> 
> > We can improve upon a workaround applied in commit
> > 63ffc23d307c9534c732edd87895e37b223004a3 ( http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=63ffc23d307c9534c732edd87895e37b223004a3 
> >  )
> >
> > The original problem was:
> >
> > "On a system with nfs mounts, if a task unshares its mount namespace,
> > a oops can occur when the system is rebooted if the task is the last
> > to unreference the nfs mount. It will try to create a rpc request
> > using utsname() which has been invalidated by free_nsproxy()."
> >
> > Cedric worked around this by always using the initial uts namespace  
> > for RPC.
> > Critically this workaround meant that RPC clients in uts namespaces  
> > can never
> > report the changed nodename when utilizing RPC.
> >
> > Fix that by storing the nodename in the NFS server structure (part  
> > of the NFS
> > super block) and, when an RPC client is operating on behalf of NFS,  
> > reporting
> > that nodename. This solves the problem for NFS clients but leaves  
> > any other
> > RPC users out in the cold.
> >
> > Rather than caching the nodename in the client structure RPC should  
> > obtain the
> > nodename from RPC callers. It would then be up to those services  
> > making RPC
> > calls to cache the nodename for as long as necessary -- somewhat  
> > like this patch
> > does with NFS.
> 
> Instead of having the RPC client call the consumer back, why can't you  
> pass the nodename as an argument to each RPC call; say, via the  
> rpc_message structure?

I suspect it would work and it would avoid the layering violation you
pointed out.

> > NOTE: Part of Cedric's workaround -- use of the initial uts  
> > namespace -- is
> > still necessary because non-NFS RPC callers still rely on the  
> > nodename cached
> > with the RPC client struct.
> 
> In the long run I think it would be more useful to spell out where  
> each consumer gets its nodename value, rather than having a convenient  
> default value.  A default would encourage exposing nodenames  
> inappropriately due to sloppy coding and incorrect assumptions (on the  
> developer's part) about a complex API.

You make some good points here. I'll add your idea to my list of patches
to try writing:
	1. Store a reference to the uts namespace with the credentials
	2. Pass the nodename directly for each RPC call (via rpc_message
		perhaps)

<snip>

> > Index: linux-2.6.28/include/linux/sunrpc/clnt.h
> > ===================================================================
> > --- linux-2.6.28.orig/include/linux/sunrpc/clnt.h
> > +++ linux-2.6.28/include/linux/sunrpc/clnt.h
> > @@ -19,6 +19,7 @@
> > #include <asm/signal.h>
> >
> > struct rpc_inode;
> > +struct nfs_server;
> >
> > /*
> >  * The high-level client handle
> > @@ -50,6 +51,7 @@ struct rpc_clnt {
> >
> > 	int			cl_nodelen;	/* nodename length */
> > 	char 			cl_nodename[UNX_MAXNODENAME];
> > +	struct nfs_server	*cl_nfs_server;
> 
> This is a layering violation...  I would rather avoid introducing new  
> strong data structure dependencies on one of RPC's consumers.

<snip>

I addressed your other comments in an earlier reply.

Thanks!

Cheers,
	-Matt Helsley

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
