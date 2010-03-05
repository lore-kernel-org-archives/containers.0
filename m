From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/12][user-cr]: Second set of cleanups
Date: Fri, 5 Mar 2010 14:34:39 -0800
Message-ID: <20100305223439.GA15300@us.ibm.com>
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
Cc: sukadev-6JnAsaTVvkgX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Second set of cleanup patches. With these patches, LXC will be able
to compile/link directly using restart.o and app-checkpoint.h from
the user-cr directory. Something like:

	USER_CR=/home/suka/user-cr make lxc_restart

After having more detailed discussions on the API, we could install
restart.o in /lib/libcheckpoint.a and app-checkpoint.h in /usr/include.

	[PATCH 01/12][user-cr] restart: Mark globals as static
	[PATCH 02/12][user-cr] restart: Add args->send_sigint
	[PATCH 03/12][user-cr] Add app_restart_args->debug
	[PATCH 04/12][user-cr] Add app_restart_args->verbose
	[PATCH 05/12][user-cr] Add app_restart_args->ulogfd
	[PATCH 06/12][user-cr] Add app_restart_args->uerrfd
	[PATCH 07/12][user-cr] Define INIT_SIGNAL_ARRAY
	[PATCH 08/12][user-cr] Create common.h 
	[PATCH 09/12][user-cr] Create app-checkpoint.h
	[PATCH 10/12][user-cr] restart: Move main() to restart-main.c
	[PATCH 11/12][user-cr] checkpoint: Move main() to checkpoint-main.c
	[PATCH 12/12][user-cr] Have app_restart() return pid

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
