From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 00/13][RFC] Checkpoint/restart code reshuffle
Date: Fri, 26 Feb 2010 00:45:01 -0800
Message-ID: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
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

This patch series moves checkpoint/restart code alongside the kernel code
that manages the checkpointed data under less exotic circumstances. This
is an attempt to improve the maintenance of the code. For example, all of
checkpoint/signal.c gets moved into kernel/signal.c.

Unfortunately this requires a giant #ifdef CONFIG_CHECKPOINT block
inside kernel/signal.c. Normaly this is frowned upon however there is no
alternative that I can see because most of the checkpoint functions
clearly don't belong as static inlines in in headers.

By distributing their contents this way I was able to get rid of:

	checkpoint/signal.c
	checkpoint/memory.c
	checkpoint/namespace.c

and I was able to move some of the contents from checkpoint/objhash.c
into the relevant files. The rest seemed appropriately collected in
checkpoint/ but they were core kernel pieces so I simply moved them
to kernel/checkpoint/.

This is a taste of what's possible. Assuming this series is preferrable
to maintainers, or if someone can identify a better way than some large
#ifdefs in .c files, it shold be possible to further distribute

	fs/checkpoint.c (to fs/file_table.c for example)
	checkpoint/objhash.c (to the various namespace and other files)
	include/linux/checkpoint.h (e.g. one for the objhash functions)

and maybe:
	checkpoint/process.c (I need to consider this one some more..)

The series survives crude compile testing. There should be no functional
changes to c/r except for the case where userns is not configured -- in
that case, this version fails to restart checkpoint images with user
namespaces. This can be fixed at the cost of restoring
checkpoint/namespace.c or perhaps by adding the userns portion to a new
file called kernel/no_user_namespace.c (or similar).

I'd like to know if folks think this will make the checkpoint/restart
code more maintainable. I would also be glad to get rid of the #ifdefs if
anyone has some better recommendations.

Cheers,
	-Matt Helsley
