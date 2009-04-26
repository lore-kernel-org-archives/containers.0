From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Sun, 26 Apr 2009 14:37:37 -0700
Message-ID: <m1fxfvp04e.fsf@fess.ebiederm.org>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
	<20090409135724.GA26467@us.ibm.com>
	<D02204CF-796A-45F5-B9A2-5B581EB52A2F@gmail.com>
	<20090409191402.GA561@us.ibm.com>
	<638f07d70904091628o25d11b95oa8614a0585df4cf5@mail.gmail.com>
	<m1iqktw5uq.fsf@fess.ebiederm.org>
	<638f07d70904250738j987ed6j685372651346634a@mail.gmail.com>
	<m1k558va5u.fsf@fess.ebiederm.org>
	<638f07d70904260108s3ca2eb5cpcbed37d5ba002d42@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <638f07d70904260108s3ca2eb5cpcbed37d5ba002d42-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Elwin Stelzer Eliazer's message of "Sun\,
	26 Apr 2009 01\:08\:14 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Thank you for your response.
>
> Let me explain my requirements more, and in this context, i would like to know
> your response.
>
> A reverse web and applications proxy is the user space application that we are
> virtualizing using network namespace and LXC.
> Local apache server and other apps are accessed through several sockets on
> 127.0.0.1 now and this has to be virtualized.
> The proxy under each LXC must handle hundreds of proxied sessions.
> The socket connections to local web and other apps server are dynamic, and
> corresponds to the dynamic external proxy sessions, and these can not be
> created upfront.
>
> I posted two other questions also, for which i never got a response from this
> list.
>
> 1. Can i have netfilter/iptables rules corresponding to each container, that
> has overlapping IP address space? In other words, are netfilter/iptables rules
> handling virtualized as part of network namespace. Some preliminary tests seem
> to work. How do i know the development or proper release status on this
> feature?

Yes.

The easiest way to know the status is to read the code.
Short of the that the easiest way to know is to try it.

In the network namespace either the feature should fail gracefully
in a network namespace or after the code has been updated it should
work.

By and large all of ipv4 and ipv6 and iptables is expected to work.

> 2. Can the /dev/tun based PPP interface be part of a container? Like veth or
> macvlan what is the type for this?

Yes.  tun/tap is a well tested path.  ppp looks like it has also been converted.

> Looking forwards for your suggestions and the options i have for these needs
> using LXC/namespace, as of 2.6.29. Do you still think i can avoid the relay
> daemon?

Apache is creating the connections on demand to your client.  Interesting.

I am too familiar with that setup.  In all honesty the easy thing to
do would be to have real ip address on something like the 192.168.0.0/16
network for each virtual machine.

Baring that it is possible to have your proxy receive the connections
and pass them via a unix domain socket created at the beginning of
time to your client.  If you have the proxy already it quite possibly
isn't worth it.

Eric
