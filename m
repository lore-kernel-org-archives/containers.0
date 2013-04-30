From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v0.5
Date: Tue, 30 Apr 2013 21:30:55 +0400
Message-ID: <517FFFCF.4080301@parallels.com>
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
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Ladies and Gentlemen,

I'm glad to announce the 5th release of the checkpoint-restore tool!

This release is mostly about the tool itself. The v3.9 kernel, with which the
new CRIU tool should be used, only contains a couple of bug fixes related to
the C/R project and no new related features. As for the tool itself, there's
a lot of bugs fixed, thanks to new users that come to try the CRIU tool :)

The biggest "new-feature" change so far is about dumping the applications memory.
We have two enhancements in this area:

* memory dumps can be directly sent to the remote node, to speed live migration up;

and

* with the custom crkernel (patches are expected to get merged in Linux-3.10) one
  can track the memory changes, which in turn allows to do e.g. incremental dumps
  or optimize the live migration by sending memory to remote host before freezing
  the application.

The full list of changes is here: http://criu.org/Download/criu/0.5

Have fun!

Thanks,
Pavel
