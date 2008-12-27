From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/7][v4] Define siginfo_from_ancestor_ns()
Date: Sat, 27 Dec 2008 12:38:36 -0800
Message-ID: <20081227203836.GA25736@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115124.GC8020@us.ibm.com> <20081224162823.GE11593@redhat.com> <20081224212426.GD13502@us.ibm.com> <20081224220358.GA3851@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754598AbYL0Uke@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224220358.GA3851@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 12/24, Sukadev Bhattiprolu wrote:
| >
| > Oleg Nesterov [oleg@redhat.com] wrote:
| > | And, SI_ASYNCIO only matters when we send the signal to the subnamespace,
| > | and in that case we will probably mangle .si_pid. So why don't we warn
| > | when .si_code == SI_USER?
| >
| > I was wondering if I should there too :-) But what do you think ?
| 
| Well, if you ask me, I'd suggest to document the problems with
| sigqueueinfo() and forget. Whatever we do, we can't be always
| right.

Ok.  According to
http://www.kernel.org/doc/man-pages/online/pages/man2/rt_sigqueueinfo.2.html.
rt_sigqueueinfo() is not directly published to users and users can't be
passing in siginfo_t directly. So no man page update is needed either ? 

Sukadev
