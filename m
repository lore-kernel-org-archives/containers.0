From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Sat, 7 Feb 2009 13:20:22 -0800
Message-ID: <20090207212022.GA25353@us.ibm.com>
References: <20090117202638.GA11825@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755071AbZBGVZ3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090117202638.GA11825@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu [sukadev@linux.vnet.ibm.com] wrote:
| Patches in this set:
| 
| 	[PATCH 1/7] Remove 'handler' parameter to tracehook functions
| 	[PATCH 2/7] Protect init from unwanted signals more
| 	[PATCH 3/7] Add from_ancestor_ns parameter to send_signal()
| 	[PATCH 4/7] Protect cinit from unblocked SIG_DFL signals
| 	[PATCH 5/7] Protect cinit from blocked fatal signals
| 	[PATCH 6/7] SI_USER: Masquerade si_pid when crossing pid ns boundary
| 	[PATCH 7/7] proc: Show SIG_DFL signals to init as "ignored" signals

Roland, Eric, Daniel, Pavel

Any comments on this patchset ? We are not sure about patch 7, but should
I send the rest to Andrew ?

Sukadev
