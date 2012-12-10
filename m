From: Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Subject: performance drop after using blkcg
Date: Mon, 10 Dec 2012 20:28:54 +0800
Message-ID: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I plan to use blkcg(proportional BW) in my system. But I encounter
great performance drop after enabling blkcg.
The testing tool is fio(version 2.0.7) and both the BW and IOPS fields
are recorded. Two instances of fio program are carried out simultaneously,
each opearting on a separate disk file (say /data/testfile1,
/data/testfile2).
System environment:
kernel: 3.7.0-rc5
CFQ's slice_idle is disabled(slice_idle=0) while group_idle is
enabled(group_idle=8).

FIO configuration(e.g. "read") for the first fio program(say FIO1):

[global]
description=Emulation of Intel IOmeter File Server Access Pattern

[iometer]
bssplit=4k/30:8k/40:16k/30
rw=read
direct=1
time_based
runtime=180s
ioengine=sync
filename=/data/testfile1
numjobs=32
group_reporting


result before using blkcg: (the value of BW is KB/s)

           FIO1 BW/IOPS    FIO2 BW/IOPS
---------------------------------------
read       26799/2911      25861/2810
write      138618/15071    138578/15069
rw         72159/7838(r)   71851/7811(r)
           72171/7840(w)   71799/7805(w)
randread   4982/543        5370/585
randwrite  5192/566        6010/654
randrw     2369/258(r)     3027/330(r)
           2369/258(w)     3016/328(w)

result after using blkcg(create two blkio cgroups with
default blkio.weight(500) and put FIO1 and FIO2 into these
cgroups respectively)

           FIO1 BW/IOPS    FIO2 BW/IOPS
---------------------------------------
read       36651/3985      36470/3943
write      75738/8229      75641/8221
rw         49169/5342(r)   49168/5346(r)
           49200/5348(w)   49140/5341(w)
randread   4876/532        4905/534
randwrite  5535/603        5497/599
randrw     2521/274(r)     2527/275(r)
           2510/273(w)     2532/274(w)

Comparing with those results, we found greate performance drop
(30%-40%) in some test cases(especially for the "write", "rw" case).
Is it normal to see write/rw bandwidth decrease by 40% after using
blkio-cgroup? If not, any way to improve or tune the performace?

Thanks.

-- 
Regards,
Zhao Shuai
