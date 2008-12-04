From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 4 Dec 2008 08:22:42 -0800
Message-ID: <20081204162242.GA23906@us.ibm.com>
References: <20081204052638.425740534@goodmis.org> <20081204052735.175697908@goodmis.org> <m11vwoumjn.fsf@frodo.ebiederm.org> <alpine.DEB.1.10.0812040921410.5240@gandalf.stny.rr.com> <m1abbct3hk.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756112AbYLDQXW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1abbct3hk.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

| find_get_pid is the right one.
| 
| Sorry.  We have a stupid inconsistency in the naming here,
| If we were consistent it would be find_get_vpid.

Yes, its inconsistent, but maybe find_vpid() should be find_pid()
since there is no 'virtual struct pid' only a virtual pid number.

Sukadev
