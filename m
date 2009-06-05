From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc-start fails on clone(child_stack=0,
	flags=CLONE_NEWNS|0x6c000000|SIGCHLD) = -1 EINVAL (Invalid argument)
Date: Fri, 5 Jun 2009 08:59:24 -0500
Message-ID: <20090605135924.GA16326@us.ibm.com>
References: <f058a9c30906050630p2bb36451odef8863081c2bef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f058a9c30906050630p2bb36451odef8863081c2bef-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miguel F Mascarenhas Sousa Filipe <miguel.filipe-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Miguel F Mascarenhas Sousa Filipe (miguel.filipe-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hello,
> 
> I'm trying to play with lxc, but I'm unable to start a container
> created with lxc-debian in two diferent linux systems I have.
> 
> linux-2.6.29-gentoo-r5 x86_64.
> linux-2.6.28-11-generic ubuntu x86_64.

I suspect the problem is that your kernel (especially the ubuntu
one) is compiled without CONFIG_NET_NS=y.

> clone(child_stack=0, flags=CLONE_NEWNS|0x6c000000|SIGCHLD) = -1 EINVAL

You are sending clone the flags LCON_NEWNS, CLONE_NEWNET, CLONE_NEWPID,
CLONE_NEWUTS and CLONE_NEWIPC.  Of those, CLONE_NEWNET is the newest
one.

Are you free to recompile your kernel?

thanks,
-serge
