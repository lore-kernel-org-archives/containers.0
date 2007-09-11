From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [Devel] Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 11 Sep 2007 10:14:43 +0530
Message-ID: <20070911044443.GD16222@linux.vnet.ibm.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com> <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr> <20070910172334.GB19100@linux.vnet.ibm.com> <6599ad830709101138q7528eba7ia4fb618b8fe158cc@mail.gmail.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761270AbXIKEeT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830709101138q7528eba7ia4fb618b8fe158cc@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Jan Engelhardt <jengelh@computergmbh.de>, containers@lists.osdl.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ckrm-tech@lists.sourceforge.net
List-Id: containers.vger.kernel.org

On Mon, Sep 10, 2007 at 11:38:10AM -0700, Paul Menage wrote:
> By definition any container (about to be renamed control group)
> subsystem is some kind of "controller" so that bit seems a bit
> redundant.
> 
> Any reason not to just call it "cpu" or "cpu_sched"

Done (in the latest patch I sent a while back)!

-- 
Regards,
vatsa
