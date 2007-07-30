From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [PATCH 01/10] Task Containers(V11): Basic task container
 framework
Date: Mon, 30 Jul 2007 13:00:00 +0900 (JST)
Message-ID: <20070730040000.5EF111BF6B4@siro.lan>
References: <20070720191247.388947000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755200AbXG3EAV@vger.kernel.org>
In-Reply-To: Your message of "Fri, 20 Jul 2007 11:31:53 -0700"
	<20070720191247.388947000@menage.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: menage@google.com
Cc: akpm@linux-foundation.org, dev@sw.ru, xemul@sw.ru, serue@us.ibm.com, vatsa@in.ibm.com, ebiederm@xmission.com, haveblue@us.ibm.com, svaidy@linux.vnet.ibm.com, balbir@in.ibm.com, pj@sgi.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, rohitseth@google.com
List-Id: containers.vger.kernel.org

> +extern void container_init_smp(void);

> +static inline void container_init_smp(void) {}

stale prototypes?

YAMAMOTO Takashi
