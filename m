From: Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>
Subject: Netfilter owner matching inside user namespace
Date: Tue, 20 May 2014 17:16:54 +0100
Message-ID: <537B7FF6.9050103@elastichosts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

I am trying to run the following command inside an image using user
namespaces via contain [1], a very simplistic implementation of linux
containers:
  contain /path/to/image /bin/bash

Although the host kernel does have support for owner matching and it
works with no errors, running the following iptables command inside the
container:
  iptables -A OUTPUT -m owner --uid-owner root -j ACCEPT
returns the error "Invalid argument".

The last commit for the netfilter xt_owner module is exactly Eric's
basic support for user namespaces, but there might be some other recent
changes either in the namespaces area or netfilter in general, which
brought the module in an unusable state inside containers - at least for
the above command usage.

I can try to send the image I used for testing to anyone who desires,
but a handy shortcut should be "deboostrap trusty /path/to/image" and
"chroot /path/to/image apt-get install iptables".

The host kernel is 3.14.4, iptables version on the host is 1.4.15 and
inside the Ubuntu container is 1.4.18. I have tried with Ubuntu 13.* and
Ubuntu 14.04, but I don't think the userspace has anything to do with this.

I can provide with any additional information needed.

Any insights on this?

Cheers,
Alin.

[1] https://github.com/arachsys/containers
