From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] cgroup: list_del_init() on removed events
Date: Wed, 28 Nov 2012 13:50:45 -0800
Message-ID: <1354139445-6685-2-git-send-email-gthelen@google.com>
References: <1354139445-6685-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354139445-6685-1-git-send-email-gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Use list_del_init() rather than list_del() to remove events from
cgrp->event_list.  No functional change.  This is just defensive
coding.

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a0d75bb..44c319d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3766,7 +3766,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 	if (flags & POLLHUP) {
 		__remove_wait_queue(event->wqh, &event->wait);
 		spin_lock(&cgrp->event_list_lock);
-		list_del(&event->list);
+		list_del_init(&event->list);
 		spin_unlock(&cgrp->event_list_lock);
 		/*
 		 * We are in atomic context, but cgroup_event_remove() may
@@ -4340,7 +4340,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	list_splice_init(&cgrp->event_list, &tmp_list);
 	spin_unlock(&cgrp->event_list_lock);
 	list_for_each_entry_safe(event, tmp, &tmp_list, list) {
-		list_del(&event->list);
+		list_del_init(&event->list);
 		remove_wait_queue(event->wqh, &event->wait);
 		eventfd_signal(event->eventfd, 1);
 		schedule_work(&event->remove);
-- 
1.7.7.3
