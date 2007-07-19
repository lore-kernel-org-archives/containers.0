From: sukadev@us.ibm.com
Subject: [PATCH 0/5][V2] Misc helper patches for pid namespaces
Date: Thu, 19 Jul 2007 00:12:06 -0700
Message-ID: <20070719071206.GE10195@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933981AbXGSHMV@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: Pavel Emelianov <xemul@openvz.org>, Oleg Nesterov <oleg@tv-sign.ru>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Some helper patches to support multiple pid namespaces. These
were posted earlier on Containers@ mailing list. 

	[PATCH 1/5] Define and use task_active_pid_ns() wrapper
	[PATCH 2/5] Rename child_reaper() function.
	[PATCH 3/5] Use task_pid() to find leader's pid
	[PATCH 4/5] Define is_global_init() and is_container_init().
	[PATCH 5/5] Move alloc_pid() to copy_process()

Changelog:

	- Addressed Oleg Nesterov's comments on [V1] of this patchset.
