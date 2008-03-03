From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Mon, 3 Mar 2008 01:11:51 -0800
Message-ID: <6599ad830803030111w5d6aa07fj761b988f15a4a111@mail.gmail.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	 <47C7EEAC.7010907@amln.net> <47CBA787.8020100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758556AbYCCJMU@vger.kernel.org>
In-Reply-To: <47CBA787.8020100@cn.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>, Xpl++ <xpl@amln.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pavel Emelianov <xemul@openvz.org>P
Cc: Linux Containers <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

So, there have been various options suggested over the course of this thread:

--

1) no code changes, just stake out all names matching a certain regexp
(e.g. "[a-z].*") as being potentially used by the kernel in the
future; document this, and let users who are worried about name
clashes avoid these names

pros: no work involved, avoids potentially complex changes to solve a
possibly non-problem.

cons: leaves an intermingled namespace; since this would be a
convention rather than an enforced rule, users might be unaware that
they're setting themselves up for a fall

--

2) separate out the kernel-generated names and user-generated names by
putting the user-generated names in a "groups" sub-directory (can be a
mount option that's automatically disabled for cpusets).

pros: completely solves problem of intermingled namespaces; makes it
easier to see sub-groups at a glance

cons: extra code, slightly more awkward to deal with in the general
case, is incompatible with the code that was in mainline in the brief
period of time since 2.6.24 was finalized.

--

3) prefix all cgroup-provided files with "cgroup."

pros: hardly any extra code; mostly solves the namespace problem since
user names are much less likely to begin with "cgroup."

cons: changes name of "tasks" file visible in 2.6.24; doesn't help if
a future new subsystem is introduced with a commonly-used name that
might clash with existing user-generated names.

--

4) prefix all future cgroup files with "cgroup." (possibly including
existing notify_on_release and release_agent files?)

pros: no extra code, just involves slightly longer strings for future
new files; no incompatibility issues

cons: ugly inconsistency between new cgroup files and grandfathered
old ones, plus same clash problems as option 3

--

Paul
