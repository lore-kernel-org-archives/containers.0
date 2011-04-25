From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: Re: CLONE_NEWNET + unix domain sockets
Date: Mon, 25 Apr 2011 15:43:34 +0100
Message-ID: <D89FFA505E4B9880AD947451@Ximines.local>
References: <6E3DBEA16997DE780A11C637@Ximines.local>
	<20110425141228.GB29132@hallyn.com>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110425141228.GB29132-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
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
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



--On 25 April 2011 09:12:28 -0500 Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> 
wrote:

> Nope, while there have been discussions about the right thing to do,
> last I knew unix domain sockets were completely tied to the network
> namespace.

OK

> Sockets, like file descriptors, persist as handles in the namespace
> in which they were created.
...
> Likewise, if you connect a socket before CLONE_NEWNET, then you
> can continue to use it after CLONE_NEWNET.  This is by design.  A
> server can (and some do) create hunderds of thousands of network
> namespaces, creating one connected socket in each, with no other
> handle to that ns left other than that socket.

Ah, so the socket persists because of the FD despite its namespace being
unshared, simply because the listen fd persists across the unshare(); I can
thus accept() on a listening socket which is in another namespace, and
generate an fd that works just fine. This what I missed. It is
useful behaviour. Thanks.

-- 
Alex Bligh
