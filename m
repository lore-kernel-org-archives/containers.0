From: Roland McGrath <roland@redhat.com>
Subject: Re: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals
Date: Tue, 30 Dec 2008 16:04:45 -0800 (PST)
Message-ID: <20081231000445.CEBC8FC278@magilla.sf.frob.com>
References: <20081224114414.GA7879@us.ibm.com>
	<20081224115229.GE8020@us.ibm.com>
	<20081224160931.GC11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753109AbYLaAFh@vger.kernel.org>
In-Reply-To: Oleg Nesterov's message of  Wednesday, 24 December 2008 17:09:31 +0100 <20081224160931.GC11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, ebiederm@xmission.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

> > + * If @signal refers to a container-init and @signr is neither SIGKILL nor
> > + * SIGSTOP, it was queued because it was blocked when it was posted.
> 
> This is not right too. It is possible that init had a handler when
> the signal was sent, and the handler was set to SIG_DFL before the
> signal was dequeued.

do_sigaction's sig_handler_ignored() should exclude that.


Thanks,
Roland
