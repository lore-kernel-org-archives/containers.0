From: sukadev@us.ibm.com
Subject: Re: [PATCH] Use same_thread_group() in signalfd.c
Date: Wed, 29 Aug 2007 14:18:59 -0700
Message-ID: <20070829211859.GB18542@us.ibm.com>
References: <46D57274.3040802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760039AbXH2VTV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46D57274.3040802@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Pavel Emelianov [xemul@openvz.org] wrote:
| This is a lost hunk of previous patch that isolated the
| explicit usage of task->tgid in some places. The signalfd
| code uses the tsk->tgid comparison.
| 
| Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>

| 
| ---
| 
| diff --git a/fs/signalfd.c b/fs/signalfd.c
| index a8e293d..5bfd2c5 100644
| --- a/fs/signalfd.c
| +++ b/fs/signalfd.c
| @@ -64,7 +64,7 @@ static int signalfd_lock(struct signalfd
| 		return 0;
| 	}
| 
| -	if (lk->tsk->tgid == current->tgid)
| +	if (same_thread_group(lk->tsk, current->tgid))
| 		lk->tsk = current;
| 
| 	return 1;
