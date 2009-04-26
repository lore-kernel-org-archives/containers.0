From: Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Sun, 26 Apr 2009 01:08:14 -0700
Message-ID: <638f07d70904260108s3ca2eb5cpcbed37d5ba002d42@mail.gmail.com>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
	<20090409135724.GA26467@us.ibm.com>
	<D02204CF-796A-45F5-B9A2-5B581EB52A2F@gmail.com>
	<20090409191402.GA561@us.ibm.com>
	<638f07d70904091628o25d11b95oa8614a0585df4cf5@mail.gmail.com>
	<m1iqktw5uq.fsf@fess.ebiederm.org>
	<638f07d70904250738j987ed6j685372651346634a@mail.gmail.com>
	<m1k558va5u.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1k558va5u.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thank you for your response.
Let me explain my requirements more, and in this context, i would like to
know your response.

A reverse web and applications proxy is the user space application that we
are virtualizing using network namespace and LXC.
Local apache server and other apps are accessed through several sockets on
127.0.0.1 now and this has to be virtualized.
The proxy under each LXC must handle hundreds of proxied sessions.
The socket connections to local web and other apps server are dynamic, and
corresponds to the dynamic external proxy sessions, and these can not be
created upfront.

I posted two other questions also, for which i never got a response from
this list.

1. Can i have netfilter/iptables rules corresponding to each container, that
has overlapping IP address space? In other words, are netfilter/iptables
rules handling virtualized as part of network namespace. Some preliminary
tests seem to work. How do i know the development or proper release status
on this feature?

2. Can the /dev/tun based PPP interface be part of a container? Like veth or
macvlan what is the type for this?

Looking forwards for your suggestions and the options i have for these needs
using LXC/namespace, as of 2.6.29. Do you still think i can avoid the relay
daemon?

Your clear answers on these will be appreciated.

Thanks in advance.

regards,
Elwin.


On Sat, Apr 25, 2009 at 11:51 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>wrote:

> Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
> > Can you explain your answer more on what you refer as "pass in the
> socket"?
> > To my understanding, apache listens only on TCP/IP sockets.
>
> I don't know your entire workflow, and I wasn't talking about modifying
> apache.
>
> However it is possible to pass sockets between network namespaces if you
> do the proper things when you set them up at the beginning.  So instead
> of a relay daemon you could open the socket you will use to talk to
> apache and pass it to your application, over a unix domain socket,
> or if you can possible at the creation of the network namespace.
>
> Eric
>
