From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Fri, 31 Oct 2008 12:32:01 -0700
Message-ID: <m13aicsgr2.fsf@frodo.ebiederm.org>
References: <4909B10A.8090403@thomson.net> <4909DEC8.9090102@thomson.net>
	<m14p2tznoz.fsf@frodo.ebiederm.org>
	<200810311046.17506.andreas.aaen@tietoenator.com>
	<490B1384.7030001@fr.ibm.com> <m1zlkksi91.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1zlkksi91.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's message
	of "Fri, 31 Oct 2008 11:59:38 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivien Chappelier <vivien.chappelier@t>
List-Id: containers.vger.kernel.org


Thinking it over a little more I have the following thought.

For binding a socket to a namespace let's use the a fd arg.
That way we can either supply another existing network socket
or the result of an open call.  Simple, and faster if you
are creating more than one socket in the other network namespace.

I really don't like the idea of binding a socket into a namespace.
Especially after looking at the arguments to socket(2).
The network namespace may be incomplete and you may create a socket
in a network namespace that way that we could not exist normally.
That plus it puts lots of races in code that finds the namespace of
a socket.


So in some form let's implement socketat. 
int socketat(int ns, int domain, int type, int protocol, int flags);

We need the flags field so we can accomodate the O_CLOEXEC flag.


That should be very straight forward.  Implementable now, without
a magic filesystem.   And then the filesystem would just provide
the global naming and process independence.

Eric
