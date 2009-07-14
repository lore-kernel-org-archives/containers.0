From: Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Subject: [PATCH 0/2] Memory usage limit notification feature (v3)
Date: Mon, 13 Jul 2009 17:16:19 -0700
Message-ID: <1247530581-31416-1-git-send-email-vbuzov__19413.7692139067$1247530833$gmane$org@embeddedalley.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246998310-16764-1-git-send-email-vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux memory management list <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


The following sequence of patches introduce memory usage limit notification
capability to the Memory Controller cgroup.

This is v3 of the implementation. The major difference between previous
version is it is based on the the Resource Counter extension to notify the
Resource Controller when the resource usage achieves or exceeds a configurable
threshold.

TODOs:

1. Another, more generic notification mechanism supporting different  events
   is preferred to use, rather than creating a dedicated file in the Memory
   Controller cgroup.


Thanks,
Vlad.
