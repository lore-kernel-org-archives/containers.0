From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 0/7] introduce bio-cgroup into io-throttle
Date: Thu, 20 Nov 2008 19:05:00 +0800
Message-ID: <4925445C.10302__2123.49105063385$1227179437$gmane$org@cn.fujitsu.com>
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
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi all,

For the moment, io-throttle can trace buffered-io by means of memcg. This 
patchset introduces bio-cgroup into io-throttle, and splits it from memcg.
For the current implemetation, there are two ways can be used to trace
buffered-io. The first is mount io-throttle and bio-cgroup together.
This is a aggressive way, because there might have some troubles if other
subsystem also want to use bio-cgroup.
The other way is more gentle, io-throttle can use the bio-cgroup id to 
associate with a given bio-cgroup. If an association is created, synchronization 
between two groups will be performed automatically. This means if one task
adds into or removes from an associated bio-cgroup group, the corresponding 
io-throttle group will also add or remove this task.
If one io-throttle associates with a bio-cgroup group, tasks moving in this 
io-throttle group is forbidden.
A new io-throttle file blockio.bio_id is added. This file is used to create or remove an 
association. blockio.bio_id accessing in root hierarchy is not allowed. Following command
is valid.
$echo 1 > /mnt/throttle/group1/blockio.bio_id (associate this io-throttle group with bio-cgroup 1)
$echo -1 > /mnt/throttle/group1/blockio.bio_id (remove association between this io-throttle group and bio-cgroup 1)

One bio-cgroup group can't be associated twice. If you do so, error message will show.
If io-throttle has been mounted with bio-cgroup, all blockio.bio_id related actions are of no effect.

Dependency checking callback is introduced into cgroup.
You can't mount io-throttle with other subsystems except bio-cgroup. Beacuse other subsystem might break
the association between io-throttle and bio-cgroup.

This patchset is against 2.6.28-rc2-mm1.

-- 
Regards
Gui Jianfeng
