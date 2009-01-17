From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7][v6] Container-init signal semantics
Date: Sat, 17 Jan 2009 12:46:11 -0800
Message-ID: <20090117204611.GA12283@us.ibm.com>
References: <20090107074558.GA27881@us.ibm.com> <20090111060452.GA9014@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933328AbZAQUtp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090111060452.GA9014@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| Eric, Roland, what do you think ?
| 
| The whole series looks good to me. I think it adds minimal
| complications to solove the problem.

Thanks Oleg.

I made a small style update - basically removed the helpers
siginfo_from_user() and siginfo_from_ancestor_ns() and moved their
logic into send_signal() (merged patch 4 and 5 from [v6] patchset). 

Also added a patch to update /proc/pid/status to include SIG_DFL
signals and removed a pending todo for the patchset.

Roland, Eric, Daniel, Bastian, can you please comment on the [v7]
patchset ?

Thanks,

Sukadev
