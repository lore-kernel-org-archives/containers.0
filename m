From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/2] Add ipc_namespace to struct sem_undo_list
Date: Thu, 05 Aug 2010 18:42:10 -0400
Message-ID: <4C5B3E42.5040802@cs.columbia.edu>
References: <1281031026-2357-1-git-send-email-danms@us.ibm.com>
	<1281031026-2357-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281031026-2357-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


On 08/05/2010 01:57 PM, Dan Smith wrote:
> Checkpoint/Restart needs to have a pointer to the ipc_namespace that the
> sem_undo_list applies to in order to properly bring up and tear down
> the object hash.  This patch adds a pointer to the namespace to the list
> structure, as well as breaks out the allocation of the undo list to a
> separate function (which is needed in a later C/R patch anyway).
>
> Signed-off-by: Dan Smith<danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
