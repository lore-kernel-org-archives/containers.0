From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Thu, 9 Apr 2009 08:57:24 -0500
Message-ID: <20090409135724.GA26467@us.ibm.com>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <638f07d70904081549h442c4bb0l401fa08f4980b217-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Elwin Stelzer Eliazer (stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hi,
> 
> I am trying to use network namespace for virtualizing some socket
> applications i already have.
> These applications interact with Apache through 'lo' 127.0.0.1:nnn sockets
> now.
> When i virtualize, i do not want to run Apache inside the container, and has
> to be outside.
> I can not use any non-127.x.x.x IP address for this purpose, or have any
> separate "host-only" kind of internal network.
> I would appreciate if someone can let me know the options i have to
> accomplish this, with network namespace, and 2.6.29 or 2.6.30.

So to be clear, what you want is to have an application in a separate
network namespace from apache, but talking over a shared loopback?

Can you use a veth tunnel pair?  You don't have to tie them to a
bridge so the socket app won't be on the public net.

-serge
