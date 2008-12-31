From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 4/6][v5] Protect cinit from unblocked SIG_DFL signals
Date: Tue, 30 Dec 2008 16:19:42 -0800 (PST)
Message-ID: <20081231001942.F35E2FC278@magilla.sf.frob.com>
References: <20081227204658.GA27197@us.ibm.com>
	<20081227205319.GC27337@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753166AbYLaAUe@vger.kernel.org>
In-Reply-To: Sukadev Bhattiprolu's message of  Saturday, 27 December 2008 12:53:19 -0800 <20081227205319.GC27337@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Since you didn't add the sig_task_unkillable() helper for its one simple
condition in patch 2/6, I don't think you need it here either for two.
Just add '&& !from_ancestor_ns' inline.

This patch has more stray whitespace changes.  
I think checkpatch.pl will spot those for you.

I'd just make the flag a parameter to send_signal() directly.
Then you can just change kill_pid_info_as_uid (or its replacement)
to call send_signal() with that new flag (and the 'group' flag) 
directly instead of using the trivial __group_send_sig_info wrapper.


Thanks,
Roland
