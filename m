From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG]: Crash with CONFIG_FAIR_CGROUP_SCHED=y
Date: Fri, 9 Nov 2007 11:25:23 +0100
Message-ID: <20071109102523.GA10903@elte.hu>
References: <20071108234805.GA2240@us.ibm.com> <20071109070214.GO3143@linux.vnet.ibm.com> <b647ffbd0711090045o5ebf4681q78f939f5c1e71fe1@mail.gmail.com> <20071109101437.GA22544@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754134AbXKIKc5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071109101437.GA22544@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>, sukadev@us.ibm.com, balbir@in.ibm.com, Containers <containers@lists.osdl.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, efault@gmx.de
List-Id: containers.vger.kernel.org


* Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:

> With the patch below, I could run ns_exec() fine w/o a crash.
> 
> Suka, can you verify whether this patch fixes your problem?

thanks, applied. I'll wait for confirmation from Suka before sending it 
to Linus.

	Ingo
