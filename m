From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [FS/MM TOPIC]  Support for checkpoint/restart in fs/mm
Date: Thu, 29 Jul 2010 19:28:23 -0400
Message-ID: <4C520E97.4010703__25921.5918639258$1280446247$gmane$org@cs.columbia.edu>
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
To: lsf10-pc-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

[Topic]
Support for checkpoint/restart in fs/mm.

[Abstract]
Linux-CR implements transparent application checkpoint-restart
aiming for inclusion in the mainline kernel. We'd like to briefly
present our approach, and discuss pending issues. (for more info
on linux-cr: http://www.linux-cr.org/)

* Quick review of the approach:

Checkpoint: we add .checkpoint method to 'struct file_operations",
(which so far simply calls a generic checkpoint function).
Restart: to restore the state of an open fd we reopen it based on
the pathname saved during checkpoint, and then some adjustments.

* Handling of unlinked files:

Unlinked files are accessible by their open fd only, but at
restart the fd cannot be restored (re-opened) since the original
pathname is gone. We'd like to suggset a .relink filesystem
method to attach a (new) pathname to an existing inode.

* Handling of fsnotify/inotify:

Both fsnotify/inotify track inode(s) directly without respective
dentry(s). However, to restore an inotify fd, we need to have had
recorded the pathname to that inode to re-add the watch at restart.
We'd like to discuss possibilities for doing so.

* Tracking of mm/pages modification per-process:

We envision two optimizations - pre-copy (for fast live-migration)
and incremental checkpoints. Both require tracking memory changes
such as mm layout and modified pages. Tracking needs to be done on
a per-process basis. We'd like to discuss possible approaches.

Thanks,

Oren.
