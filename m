From: Evgeny Kuznetsov <EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] cgroups: strcpy destination string overflow
Date: Tue,  5 Oct 2010 12:38:05 +0400
Message-ID: <2acb25707f916de866aa520b1a9f04f0f48c949c.1286193571.git.EXT-Eugeny.Kuznetsov__9505.01243719391$1286268276$gmane$org@nokia.com>
References: <cover.1286193571.git.EXT-Eugeny.Kuznetsov@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1286193571.git.EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
In-Reply-To: <cover.1286193571.git.EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
References: <cover.1286193571.git.EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, ext-eugeny.kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

From: Evgeny Kuznetsov <ext-eugeny.kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

Function "strcpy" is used without check for maximum allowed source
string length and could cause destination string overflow.
Check for string length is added before using "strcpy".
Function now is return error if source string length is more than
a maximum.

Signed-off-by: Evgeny Kuznetsov <EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c9483d8..82bbede 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1883,6 +1883,8 @@ static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
 				      const char *buffer)
 {
 	BUILD_BUG_ON(sizeof(cgrp->root->release_agent_path) < PATH_MAX);
+	if (strlen(buffer) >= PATH_MAX)
+		return -EINVAL;
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
 	strcpy(cgrp->root->release_agent_path, buffer);
-- 
1.6.3.3
