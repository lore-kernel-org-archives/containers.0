From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Hookup group-scheduler with task container
	infrastructure
Date: Fri, 14 Sep 2007 11:41:58 +0200
Message-ID: <20070914094158.GA1990@elte.hu>
References: <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr> <20070910172334.GB19100@linux.vnet.ibm.com> <20070910102259.dc45a481.akpm@linux-foundation.org> <20070910174649.GA16222@linux.vnet.ibm.com> <b647ffbd0709101528i7440a0f9m9837065a43e4a720@mail.gmail.com> <20070911044145.GC16222@linux.vnet.ibm.com> <b647ffbd0709110253y7d9564c4j88aa134330e2a292@mail.gmail.com> <20070912114202.GA30385@linux.vnet.ibm.com> <b647ffbd0709120925i690ecb11i975149037fc72979@mail.gmail.com> <20070913123324.GA6214@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754206AbXINJnV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070913123324.GA6214@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, dhaval@linux.vnet.ibm.com, menage@google.com
List-Id: containers.vger.kernel.org


* Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:

> Add interface to control cpu bandwidth allocation to task-groups.

btw., just in case it was not obvious, i'll repeat my older assessment 
of your patch: the general picture approach looks good to me and the 
code is upstream-worthy.

( suggestion: if you want more people to test it then you might want to 
  do some add-on "put all users into separate groups" patch and .config 
  option - which could be tried without people having to know anything 
  about container setup. )

	Ingo
