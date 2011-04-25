From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: CLONE_NEWNET + unix domain sockets
Date: Mon, 25 Apr 2011 14:56:25 +0100
Message-ID: <6E3DBEA16997DE780A11C637@Ximines.local>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is probably a bit of a newbie question, but:

I have a parent and a child process. The child does
  unshare(CLONE_NEWNET)
after the fork(). It does not unshare the filings system
namespace or anything else.

I want the child to expose a unix domain socket, of type SOCK_STREAM.
Both act as servers, i.e. they listen on the service, accept(), then
handle the resultant connections. The socket needs to be accessed
both by the parent and by other processes (preferably processes
with both network namespaces, but primarily from the parent's).

If I create and bind the socket in the child after the unshare(),
then I cannot connect to it from the parent or processes sharing
the parent namespace. This seems surprising, as the documentation
for CLONE_NEWNET suggests only the networking space is separated,
and that would not normally appear to include UNIX domain sockets
(I would have thought they would be CLONE_NEWNS or CLONE_NEWIPC).

If I'm wrong in this assumption, and CLONE_NEWNET should isolate
unix domain sockets, something surprising still happens: if I create
the listen socket before the CLONE_NEWNET, then everything
works as intended, even though I am creating new fds via
accept() after the unshare(), i.e. the unix domain socket space
does not appear to be isolated.

It appears to be working by doing:
  bind()
  listen()
  unshare()
  accept()

but I don't understand why, or what the semantics are for interaction
between unshare(CLONE_NEWNET) and unix domain sockets. Any ideas?

-- 
Alex Bligh
