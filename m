From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Adding a mount after container is running?
Date: Wed, 03 Nov 2010 12:52:59 +0300
Message-ID: <4CD130FB.9060408@msgid.tls.msk.ru>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello.

What is the way to add a new filesystem mount to
an already running container?  I want to "propagate"
a newly created filesystem, or another part of host
filesystem, to a container without restarting it.

I can imagine a way to "propagate" a new filesystem -
by (maybe temporarily) granting access for the
block device in question to the container and
doing a real mount from there.  I'm not sure if
it's equivalent to a bind-mount in terms of
resulting behavour (I sent this question to
lkml a few mins ago), but at least this is
easily doable.

But if I want to add a part of existing filesystem
tree to my container, things becomes somewhat less
clean.  Still doable in a similar way - by mounting
it in container in a temp place, bind-mounting a
needed part to the right place, and umounting the
temp one.  But it's not clean ;)

Is there a better way?

Thanks!

/mjt
