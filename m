From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 3/8] Memory controller accounting setup (v3)
Date: Fri, 20 Jul 2007 13:39:58 -0700
Message-ID: <6599ad830707201339u413d860co739dc301fb6c9405@mail.gmail.com>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082429.20752.63919.sendpatchset@balbir-laptop>
	 <6599ad830707201333s527f20eeuc39424c7b79626@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964876AbXGTUky@vger.kernel.org>
In-Reply-To: <6599ad830707201333s527f20eeuc39424c7b79626@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

On 7/20/07, Paul Menage <menage@google.com> wrote:
> On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > +       mem = mem_container_from_cont(task_container(p,
> > +                                       mem_container_subsys_id));
> > +       css_get(&mem->css);
>
> The container framework won't try to free a subsystem's root container
> state, so this isn't needed.

Sorry, this was a reply to the wrong patch hunk.

The css_get() in mem_container_create() is the unnecessary one.

Also, rather than doing something like:

mem_container_from_cont(task_container(p, mem_container_subsys_id))

you'd be better off defining a similar wrapper to
mem_container_from_cont() called mem_container_from_task() that uses
task_subsys_state() rather than container_subsys_state() - you'll save
a few indirections.

Paul
