From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Sat, 25 Apr 2009 00:27:25 -0700
Message-ID: <m1iqktw5uq.fsf@fess.ebiederm.org>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
	<20090409135724.GA26467@us.ibm.com>
	<D02204CF-796A-45F5-B9A2-5B581EB52A2F@gmail.com>
	<20090409191402.GA561@us.ibm.com>
	<638f07d70904091628o25d11b95oa8614a0585df4cf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <638f07d70904091628o25d11b95oa8614a0585df4cf5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Elwin Stelzer Eliazer's message of "Thu\,
	9 Apr 2009 16\:28\:02 -0700")
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
>
> Apache listens on IP sockets.
> I am proceeding with a solution having a process outside container that will
> relay IPC messages to the network space sockets outside the container into
> 127.x.x.x.

You can also just pass in the socket if you want.

> I have another question on netfilter/iptables under namespace; will post it
> on a separate thread.
>
> Thanks for your answers.

Eric
