From: Roland McGrath <roland@redhat.com>
Subject: Re: [RFC][PATCH] SEND_SIG_NOINFO: Set si_pid to tgid instead of pid
Date: Tue, 16 Dec 2008 19:20:32 -0800 (PST)
Message-ID: <20081217032032.83C30FC3BC@magilla.sf.frob.com>
References: <20081217020601.GB2866@us.ibm.com>
	<20081217031730.F2767FC3BC@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758554AbYLQDVX@vger.kernel.org>
In-Reply-To: Roland McGrath's message of  Tuesday, 16 December 2008 19:17:30 -0800 <20081217031730.F2767FC3BC@magilla.sf.frob.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, oleg@redhat.com, ebiederm@xmission.com, daniel@hozac.com, bastian@waldi.eu.org, xemul@openvz.org, containers@lists.osdl.org, linux-ke
List-Id: containers.vger.kernel.org

Arguably these deserve a heads-up to linux-abi, not that whether si_pid was
tid or tgid was probably actually documented before (and I presume the
wrong-namespace issue just doesn't need to be).

Thanks,
Roland
