From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
Date: Tue, 4 Sep 2007 00:19:22 -0700
Message-ID: <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
	 <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
	 <46DC6543.3000607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752547AbXIDHTm@vger.kernel.org>
In-Reply-To: <46DC6543.3000607@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-Id: containers.vger.kernel.org

On 9/3/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Paul Menage wrote:
> > On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> -       s += sprintf(s, "%lu\n", *val);
> >> +       if (read_strategy)
> >> +               s += read_strategy(*val, s);
> >> +       else
> >> +               s += sprintf(s, "%lu\n", *val);
> >
> > This would be better as %llu
> >
>
> Hi, Paul,
>
> This does not need fixing, since the other counters like failcnt are
> still unsigned long
>

But val is an unsigned long long*. So printing *val with %lu will
break (at least a warning, and maybe corruption if you had other
parameters) on 32-bit archs.

Paul
