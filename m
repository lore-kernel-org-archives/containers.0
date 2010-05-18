From: Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: NFS Kernel server inside a container
Date: Tue, 18 May 2010 11:51:43 -0700 (PDT)
Message-ID: <259227.79616.qm@web36101.mail.mud.yahoo.com>
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

Hello,

I was wondering if it is possible to run an NFS kernel server inside a linux container?

I tried setting one up on a debian (vserver enabled) kernel, and it seems to start the portmap, rpc.statd, rpc.idmapd rpc.mountd daemons inside the container, but I cannot seem to mount the filesystem from a client.  I do get the following error message on server startup:

  FATAL: Could not load /lib/modules/2.6.32-trunk-vserver-686/modules.dep: No such file or directory


When trying to mount on the client, after blocking on the mount for a while, I get:

  mount.nfs: mount system call failed

Any thoughts?  Has anyone else done this?  Should this be possible in the first place?  Thanks,

-Martin
