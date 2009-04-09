From: Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container-to-host virtual or loopback kind of interface support
Date: Thu, 9 Apr 2009 16:28:02 -0700
Message-ID: <638f07d70904091628o25d11b95oa8614a0585df4cf5@mail.gmail.com>
References: <638f07d70904081549h442c4bb0l401fa08f4980b217@mail.gmail.com>
	<20090409135724.GA26467@us.ibm.com>
	<D02204CF-796A-45F5-B9A2-5B581EB52A2F@gmail.com>
	<20090409191402.GA561@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090409191402.GA561-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 9, 2009 at 12:14 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Elwin Stelzer Eliazer (stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >
> > On Apr 9, 2009, at 6:57 AM, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> Quoting Elwin Stelzer Eliazer (stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >>> Hi,
> >>>
> >>> I am trying to use network namespace for virtualizing some socket
> >>> applications i already have.
> >>> These applications interact with Apache through 'lo' 127.0.0.1:nnn
> >>> sockets
> >>> now.
> >>> When i virtualize, i do not want to run Apache inside the container,
> >>> and has
> >>> to be outside.
> >>> I can not use any non-127.x.x.x IP address for this purpose, or have
> >>> any
> >>> separate "host-only" kind of internal network.
> >>> I would appreciate if someone can let me know the options i have to
> >>> accomplish this, with network namespace, and 2.6.29 or 2.6.30.
> >>
> >> So to be clear, what you want is to have an application in a separate
> >> network namespace from apache, but talking over a shared loopback?
> >>
> >
> > Yes. But I am not very specific about the loopback.
> >
> >> Can you use a veth tunnel pair?  You don't have to tie them to a
> >> bridge so the socket app won't be on the public net.
> >>
> >> -serge
> >
> > Yes I can do without the bridge. But what IP address for the veth? Can
> > it be a 127.x.x.x? My solution cannot have a regular public or private
> > ip that can interfere with external network. The reason I mentioned
> > bridge was it will reduce the ip subnet needed to one. If you can
> > suggest a solution that leverages 127.x.x.x it will be useful.
>
> Actually is there any reason you can't use a unix socket?
>
> -serge
>

Apache listens on IP sockets.
I am proceeding with a solution having a process outside container that will
relay IPC messages to the network space sockets outside the container into
127.x.x.x.

I have another question on netfilter/iptables under namespace; will post it
on a separate thread.

Thanks for your answers.

cheers,
Elwin.
