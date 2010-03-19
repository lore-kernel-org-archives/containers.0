From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/14][user-cr] Enable linking with LIBLXC
Date: Thu, 18 Mar 2010 23:26:59 -0700
Message-ID: <20100319062659.GA23838@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Patches to enable linking LIBLXC with USERCR.

Patches 1 through 9 are simply rebased patches due to the dropping of one
of the earlier patches (Oren had nacked one patch in my earlier set. See

https://lists.linux-foundation.org/pipermail/containers/2010-March/023564.html

Patches 10 through 14 are additional changes needed to get LXC checkpoint
and restart to work.

	[PATCH 01/14] Add app_restart_args->debug
	[PATCH 02/14] Add app_restart_args->verbose
	[PATCH 03/14] Add app_restart_args->ulogfd
	[PATCH 04/14] Add app_restart_args->uerrfd
	[PATCH 05/14] Define INIT_SIGNAL_ARRAY
	[PATCH 06/14] Create common.h
	[PATCH 07/14] Create app-checkpoint.h
	[PATCH 08/14] restart: Move main() to restart-main.c
	[PATCH 09/14] checkpoint: Move main() to checkpoint-main.c

	[PATCH 10/14] Have app_restart() return pid
	[PATCH 11/14] restart: Define process_args()
	[PATCH 12/14] app_restart(): mnt-pty implies mntns
	[PATCH 13/14] restart: Move args checking to app_restart()
	[PATCH 14/14] Minimize unshare() calls

With these patches, USERCR exports app_checkpoint() and app_restart() 
functions in checkpoint.o and restart.o. LXC links directly with these
.o files to checkpoint/restart its containers.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
