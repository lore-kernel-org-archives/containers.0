From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Mon, 27 Apr 2009 21:19:35 -0700
Message-ID: <m1iqkpv294.fsf@fess.ebiederm.org>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
	<20090409135724.GA26467@us.ibm.com>
	<D02204CF-796A-45F5-B9A2-5B581EB52A2F@gmail.com>
	<20090409191402.GA561@us.ibm.com>
	<638f07d70904091628o25d11b95oa8614a0585df4cf5@mail.gmail.com>
	<m1iqktw5uq.fsf@fess.ebiederm.org>
	<638f07d70904250738j987ed6j685372651346634a@mail.gmail.com>
	<m1k558va5u.fsf@fess.ebiederm.org>
	<638f07d70904260108s3ca2eb5cpcbed37d5ba002d42@mail.gmail.com>
	<m1fxfvp04e.fsf@fess.ebiederm.org>
	<638f07d70904271500u1f0a13cbif1c5db64bdb520ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <638f07d70904271500u1f0a13cbif1c5db64bdb520ab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Elwin Stelzer Eliazer's message of "Mon\,
	27 Apr 2009 15\:00\:38 -0700")
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

> Thanks Eric for your detailed response.
>
> On the PPP interfaces under namespace, how do i configure them under lxc
> config? Are there other types like "veth" and "macvlan" for PPP?

veth and macvlan are created with
ip link add .... type veth ....
ip link add .... type macvlan ...

ppp is created normally.

I have never run lxc and find it's interface inflexible for my needs so I don't
know the specifics there.

> And i believe the container app that opens the /dev/tun gets ownership of the
> file handle, and several container apps can open this in parallel, and they do
> not interfere. Even if the containers do not have separate rootfs, this is the
> case. Please confirm on these.

It is the tun SETIFF ioctl that specifies which interface a tun device connect to.
But yes several tun/tap  work just in a container.

 Eric
