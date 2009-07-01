From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Disable CLONE_PARENT for init
Date: Wed,  1 Jul 2009 00:46:54 -0700 (PDT)
Message-ID: <20090701074654.A6C6321D57@magilla.sf.frob.com>
References: <20090701073140.GA14284@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Sukadev Bhattiprolu's message of  Wednesday,
	1 July 2009 00:31:41 -0700 <20090701073140.GA14284-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

> When global or container-init processes use CLONE_PARENT, they create a
> multi-rooted process tree. 

I take this to be the real motivation for your change.
But you don't mention it in the code comment.

> +	 * Swapper process sets the handler for SIGCHLD to SIG_DFL. If init
> +	 * creates a sibling and the sibling exits, the SIGCHLD is sent to
> +	 * the swapper (since the swapper's handler for SIGCHLD is SIG_DFL).
> +	 * But since the swapper does not reap its children, the zombie will
> +	 * remain forever. So prevent init from using CLONE_PARENT.

This would be fixed by having swapper set its SIGCHLD to SIG_IGN instead,
so such children self-reap.  That seems like the better fix for that.

If you want to make this change because of container-init issues, I think
you should just say so independent of this global-init case.


Thanks,
Roland
