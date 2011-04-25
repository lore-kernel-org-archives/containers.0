From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: CLONE_NEWNET + unix domain sockets
Date: Mon, 25 Apr 2011 09:12:28 -0500
Message-ID: <20110425141228.GB29132@hallyn.com>
References: <6E3DBEA16997DE780A11C637@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6E3DBEA16997DE780A11C637-F+tRR8lnwRmNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alex Bligh (alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org):
> This is probably a bit of a newbie question, but:
> 
> I have a parent and a child process. The child does
>   unshare(CLONE_NEWNET)
> after the fork(). It does not unshare the filings system
> namespace or anything else.
> 
> I want the child to expose a unix domain socket, of type SOCK_STREAM.
> Both act as servers, i.e. they listen on the service, accept(), then
> handle the resultant connections. The socket needs to be accessed
> both by the parent and by other processes (preferably processes
> with both network namespaces, but primarily from the parent's).
> 
> If I create and bind the socket in the child after the unshare(),
> then I cannot connect to it from the parent or processes sharing
> the parent namespace. This seems surprising, as the documentation
> for CLONE_NEWNET suggests only the networking space is separated,
> and that would not normally appear to include UNIX domain sockets
> (I would have thought they would be CLONE_NEWNS or CLONE_NEWIPC).

Nope, while there have been discussions about the right thing to do,
last I knew unix domain sockets were completely tied to the network
namespace.

> If I'm wrong in this assumption, and CLONE_NEWNET should isolate
> unix domain sockets, something surprising still happens: if I create
> the listen socket before the CLONE_NEWNET, then everything
> works as intended, even though I am creating new fds via
> accept() after the unshare(), i.e. the unix domain socket space
> does not appear to be isolated.
> 
> It appears to be working by doing:
>   bind()
>   listen()
>   unshare()
>   accept()
> 
> but I don't understand why, or what the semantics are for interaction
> between unshare(CLONE_NEWNET) and unix domain sockets. Any ideas?

Sockets, like file descriptors, persist as handles in the namespace
in which they were created.  So if you open a file, then unshare
mounts ns and pivot_root into a directory which doesn't have a path
to that file, you can still use the file descriptor, and, if it is
directory, use openat to look underneath it.

Likewise, if you connect a socket before CLONE_NEWNET, then you
can continue to use it after CLONE_NEWNET.  This is by design.  A
server can (and some do) create hunderds of thousands of network
namespaces, creating one connected socket in each, with no other
handle to that ns left other than that socket.

It's not so surprising so long as you remember that the namespace
deals only with name to object resolution.  Once you have the socket,
you are not having to resolve a name.

-serge
