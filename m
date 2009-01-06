From: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Subject: Re: [RFC][PATCH 4/4] Represent RPC Callers
Date: Tue, 06 Jan 2009 08:04:22 -0500
Message-ID: <1231247062.7127.36.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011315.229045829@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090106011315.229045829-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-01-05 at 17:13 -0800, Matt Helsley wrote:
> plain text document attachment (move-rpc-client-nodename-cache.patch)
> Currently RPC needs to know the nodename (often the same as the hostname) which
> should be used for UNIX-style authentication and file-lock tracking. Because
> hostname can change between RPC calls and some sequences of RPC calls may
> require consistent names between calls RPC currently saves the nodename with
> the RPC client structure.
> 
> This is doesn't always work because RPC clients may be discarded over the
> lifetime of a higher level service -- like those that compose NFS. Specifically
> this is known to happen during shutdown.
> 
> Hence RPC should expect the nodename to be saved by the caller when sequences
> of RPC calls requiring consistent nodenames may be needed (e.g. NFS). To enable
> this we introduce an RPC caller structure that allows RPC to query the caller
> for this information.
> 
> This patch is not complete but is meant to indicate the direction I'm planning
> on going. I'd like to know if there are any objections or if anyone sees a
> better way to handle this.

You're planning on slowing down every RPC call in order to fix a problem
on client shutdown? Why?

Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
