From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Fri, 31 Oct 2008 11:59:38 -0700
Message-ID: <m1zlkksi91.fsf@frodo.ebiederm.org>
References: <4909B10A.8090403@thomson.net> <4909DEC8.9090102@thomson.net>
	<m14p2tznoz.fsf@frodo.ebiederm.org>
	<200810311046.17506.andreas.aaen@tietoenator.com>
	<490B1384.7030001@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <490B1384.7030001-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Fri,
	31 Oct 2008 15:17:40 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Andreas B Aaen wrote:

>> Ok. Here is my use case.
>> I need a to talk to 500 IPv4 networks with possible overlapping IP
>> addresses. The packages arrive on 500 VLANs. I want one process to listen to a
>> port on each of these networks. I don't want 500 processes that runs in each
>> their network namespace and then communicate with each other through e.g. unix
>> sockets. This just complicates the task.
>
> Why don't you unshare 500 times in the same process ? In each namespace you
> create a socket control and the fd number is the identifier of your namespace.

That is the other good option I have thought of for doing this.
It is certainly a bit easier to implement.

There are problems with application restart.  So I am concerned with
how well use sockets as identifiers will scale.  But I don't have
any problems in principle.

There is a similar use case where simply have several disjoint domains
that you are performing software routing between and except for
configuration the kernel doesn't need any special support.

I do think just using unshare for the creation and not implementing
a newinstance filesystem option for now makes sense.  That way we can
support mounting of /proc/net and sysfs in those network namespaces
without having to teach them how to parse options as well.

Making the application creation loop something like:
for name in $(seq 1 500) ; do 
	unshare(CLONE_NEWNS);
	mkdir /dev/vrf/$name/proc
	mkdir /dev/vrf/$name/sys
	mkdir /dev/vrf/$name/handle
	mount -t netns none /dev/vrf/$name/handle
	mount -t proc/net none /dev/vrf/$name/proc
	mount -t sysfs none /dev/vrf/$name/sys
done

Eric
