From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Thu, 21 Jan 2010 07:38:29 -0800
Message-ID: <878wbrpix6.fsf@caffeine.danplanet.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-4-git-send-email-danms@us.ibm.com>
	<4B57751A.5080506@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> Would this compile without CONFIG_NET ?  without CONFIG_NET_NS ?

Nope, but it does depend on CONFIG_CHECKPOINT, of course.  I'll add
some Kconfig magic to try to straighten that out.

OL> How can a user ask to not checkpoint the network-ns ?  (e.g. in
OL> a subtree checkpoint)

Do we really want to start adding fine-grained control over everything
that we checkpoint?  Can you ask it to not checkpoint the ipc_ns,
uts_ns, etc?  The previous example of this was connected sockets,
which I think is different, given the potential for a long delay
before restart ensuring the sockets will be dead anyway.

OL> Is there a reason not to collect all addresses into one buffer
OL> (can there be more than a page worth of them ?) and write in one
OL> go ?

I don't really see anywhere that the list is bounded.  I'd say that in
most cases each interface will only have one address anyway.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
