From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/7][v4] Protect init from unwanted signals more
Date: Wed, 24 Dec 2008 13:11:37 -0800
Message-ID: <20081224211137.GC13502@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115047.GB8020@us.ibm.com> <20081224163503.GF11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751974AbYLXVNX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224163503.GF11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| Or, we can do
| 
| 	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
| 			 handler == SIG_DFL)
| 		return 1;
| 	return sig_handler_ignored(handler, sig);
| 
| because sig_handler_ignored() checks SIG_IGN too.

Yes it more optimal. I will change.
