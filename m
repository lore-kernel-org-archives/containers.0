From: Pierre Peiffer <Pierre.Peiffer-6ktuUTfB/bM@public.gmane.org>
Subject: [RFC][PATCH 0/2] New API to change the IDs of an existing IPC
Date: Fri, 28 Sep 2007 16:58:29 +0200
Message-ID: <20070928165829.5da76796.Pierre.Peiffer@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

	As I'm seeing some discussion/interest about IPC, I would like to propose these patches, which provide an easy way to change the ID of an exiting IPC.
This work is done around the checkpoint/restart of applications. In the case of the IPCs, we need (among others) this functionality.

May be there is some other interest about this, so, the RFC concerns both the coding and the interest.

The first patch provide the functionality in kernel side, the second export it in user space. They apply on top of the latest -rc8 kernel. I can adapt them for the latest -mm.

Thanks,

-- 
Pierre
