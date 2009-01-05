From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals
Date: Mon, 5 Jan 2009 13:24:23 +0100
Message-ID: <20090105122423.GA3313@redhat.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115229.GE8020@us.ibm.com> <20081224160931.GC11593@redhat.com> <20081231000445.CEBC8FC278@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754239AbZAEM0h@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081231000445.CEBC8FC278@magilla.sf.frob.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Roland McGrath <roland@redhat.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, ebiederm@xmission.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 12/30, Roland McGrath wrote:
>
> > > + * If @signal refers to a container-init and @signr is neither SIGKILL nor
> > > + * SIGSTOP, it was queued because it was blocked when it was posted.
> >
> > This is not right too. It is possible that init had a handler when
> > the signal was sent, and the handler was set to SIG_DFL before the
> > signal was dequeued.
>
> do_sigaction's sig_handler_ignored() should exclude that.

Yes sure, but sig_handler_ignored(sig) can be false, it doesn't take
SIGNAL_UNKILLABLE into account.

Oleg.
