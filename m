From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] Payloads and transient filesystem support for user-cr
Date: Wed,  2 Mar 2011 13:35:22 -0800
Message-ID: <1299101725-17603-1-git-send-email-danms@us.ibm.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This adds payload support to user-cr for stashing things in the image.
The first type of payload supported is a transient filesystem image,
for things like /dev/shm.

When I put "/dev/shm" into args.save_fs[] (and restore_fs), I am able
to checkpoint and restart programs that are using POSIX sem_* operations
successfully.

Note that this is really only compile-tested against the current HEAD
of the tree, and may or may not work exactly in this form.  It depends
on setns(), which is not in the tree right now, and thus won't even
compile all the way.  I wanted to show what I was doing and (hopefully)
justify setns()'s place in the tree.  If it goes in, I'll be happy to
resubmit this having been tested and actually ready to go :)
