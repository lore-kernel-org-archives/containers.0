From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Thu, 30 Oct 2008 16:07:56 -0700
Message-ID: <m14p2tznoz.fsf@frodo.ebiederm.org>
References: <4909B10A.8090403@thomson.net>
	<200810301538.08032.andreas.aaen@tietoenator.com>
	<4909DEC8.9090102@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909DEC8.9090102-L+G57L1VLRbR7s880joybQ@public.gmane.org> (Vivien Chappelier's message of
	"Thu, 30 Oct 2008 17:20:24 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org> writes:

> To bring back the discussion you had with Eric W. Biederman, it seems to 
> me that the only real issue is on the addition of the global nsid index 
> that is not really fit to be used hierarchically. However, I don't 
> understand why having both this global nsid interface and the pid 
> interface would hurt, as the goals of isolation and VRF-like support are 
> really separate.

A global nsid breaks migration, it breaks nested containers, in general it
just hurts.  So it is a bad choice for an interface.

Personally if I have vrf I want to set up a test environment in a container so
I can isolate it from the rest of the system.   Allowing me to play with the
user space side of the functionality without  So these things are not completely
separate concerns.

So from a design point of view I see the following questions.
1) How do we pin a network namespace to allow for routing when no process uses it?
2) How do we create sockets into that pinned network namespace?
3) How do we enter that network namespace so that sockets by default are created in it?

All of these are technically easy things to implement and design wise a challenge.

The best solution I see at the moment is to have something (a fs) we can mount in
the filesystem, keeping the network namespace alive as long as it is mounted.

i.e
mount -t netns none /dev/nets/1
mount -t netns -o newinstance none /dev/nets/2

(The new instance parameter creates the network namespace as well as capturing the
 current one)

char netns[] = "/dev/nets/2"
fd = socket();
err = setsockopt(fd, SOL_SOCKET, SO_NETPATH, netns, strlen(netns) + 1);

Eric
