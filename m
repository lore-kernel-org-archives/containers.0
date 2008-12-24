From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals
Date: Wed, 24 Dec 2008 13:25:06 -0800
Message-ID: <20081224212506.GE13502@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115229.GE8020@us.ibm.com> <20081224160931.GC11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752070AbYLXV0v@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224160931.GC11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

| Personally, I'd prefer to retain this check inline with a small
| comment
| 
| 		/* SMALL COMMENT ;) */
| 		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
| 		    !sig_kernel_only(signr))
| 			continue;

Ok. :-)
