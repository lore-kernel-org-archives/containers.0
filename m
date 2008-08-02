From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Control groups and Resource Management notes (part II)
Date: Sat, 02 Aug 2008 06:40:45 +0530
Message-ID: <4893B415.9070906@linux.vnet.ibm.com>
References: <489315B2.2080506@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755151AbYHBBK7@vger.kernel.org>
In-Reply-To: <489315B2.2080506@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>
Cc: linux kernel mailing list <linux-kernel@vger.kernel.org>, libcg-devel <libcg-devel@lists.sourceforge.net>
List-Id: containers.vger.kernel.org

Here's part II (part I can be found at
(https://lists.linux-foundation.org/pipermail/containers/2008-August/012128.html)

Resource management (cont'd)
============================
7. Disk IO controller - There was a general discussion on the various disk IO
controllers
	a. DM - IOBand
	b. IO throttle
	c. Anticipatory
	d. CFQ

It was decided that it would be best for all the stake holders to work together
and let Jens Axboe and the block layer experts figure out what would be right
for the Linux kernel

8. Network traffic control - Paul discussed network traffic control and the
approach followed by Google. The existing classifier mechanism can be easily
extended by adding a classifier id (based on the control group). This is used in
combination with netfilters. Balbir mentioned that Thomas Graf was also looking
at something similar and raised the issue of input bandwidth control. Balbir
also pointed people to CKRM where the solution has been implemented. The OpenVZ
and Google team will post their patches

9. Network permissions - There was a recommendation to use security hooks for
network permissions. Paul explained what they use permissions with
	a. connect
	b. bind
	c. accept

The issue of using netlabels was brought up.

10. Freezer subsystem - The freezer system was discussed briefly. Serge
mentioned the patches and wanted to collect feedback (if any) on them.

11. OOM Handler - The OOM handler was discussed in detail. Balbir mentioned
certain short comings of the OOM handler
	a. Logic - it is based on total_vm, is that the correct metric for
                   OOMing?
	b. Concurrency - it kills several tasks at once

There was a discussion on moving the policy for OOM handling to user space. Paul
described how the OOM handler has been modified at google to notify user space
when a CPUSet runs out of memory. Balbir asked if OOMing on reaching limits is a
good idea, it was generally discussed that it might not be such a good idea.

Control group library
=====================
Dhaval and Balbir introduced libcgroups and the purpose of the library and the
goals. Balbir described on paper what the current design looks like, it consists of

	1. API
	2. Test framework
	3. A configuration subsystem

Dhaval discussed configuration syntax of XML versus home made. The issue of
classification of tasks was brought up. The reason that we want to classify
tasks is that we want them to move at fork/exec time to the correct cgroup so that

1. They don't consume resources in the parents group
2. The movement is automatic

It was generally agreed upon that the classification should take place in user
space. Eric and others suggested having a wrapper to start the application in
the correct cgroup (wrapper around fork/exec). Dave suggested that one might
even go the extent of hacking, such that a process is ptraced after fork/exec,
moved to the correct group and resumed. Using SELinux contexts was also recommended.

Vivek brought up using PAM plugins to do classifications, this suggestion was
nicely received. The decision was to do classification in user space and then
think of kernel space if it cannot be done in user space. Denis suggested that
classification is useful. In OpenVZ they classify all apache children to a
different group. Balbir asked Denis to post their classification infrastructure
as RFC.

Balbir asked for contributions to libcgroup. Libcgroup will effect system design
 and both administrators and application administrators. Now is a good time to
get *involved*.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
