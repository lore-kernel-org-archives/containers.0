From: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] protect cap_netlink_recv from user namespaces
Date: Mon, 07 Nov 2011 14:35:10 -0500
Message-ID: <1320694510.10093.23.camel@localhost>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-7-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320445482-8459-7-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2011-11-04 at 22:24 +0000, Serge Hallyn wrote:
> From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> cap_netlink_recv() was granting privilege if a capability is in
> current_cap(), regardless of the user namespace.  Fix that by
> targeting the capability check against the user namespace which
> owns the skb.
> 
> Caller passes the user ns down because sock_net is static inline defined in
> net/sock.h, which we'd rather not #include at the cap_netlink_recv function.

This is wrong at least in relation to audit.  I don't know the other
code well enough to know if I think it's ok there.  Lets say I have
(CAP_SYS_ADMIN | CAP_SETUID | CAP_SETGID) and I create a new task with
CLONE_NEWNAME.  This task then immediately does the needful to remove
all audit rules (which supposedly requires CAP_AUDIT_CONTROL).  That's
going to succeed because the task is init in it's namespace, aka:

        /* The creator of the user namespace has all caps. */
        if (targ_ns != &init_user_ns && targ_ns->creator == cred->user)
                return 0;

But it just screwed with a global resource.  aka audit.  I don't know
the meaning of these others, but it seems to me probably most or all of
them should be against the init_user_ns, not the namespace the skb came
from....

What am I missing?

-Eric
