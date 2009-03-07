From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7][v8] Container-init signal semantics
Date: Sat, 7 Mar 2009 11:04:28 -0800
Message-ID: <20090307190428.GA30594@us.ibm.com>
References: <20090219030207.GA18783@us.ibm.com> <499D73C8.3090209@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756045AbZCGTGK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499D73C8.3090209@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, Greg Kurz <gkurz@fr.ibm.com>
List-Id: containers.vger.kernel.org

> Gregory Kurz proposed a solution:
>    * when shutdown is called and we are not in the init pidns, then we kill 
> the process 1 of the pidnamespace.
>    * when reboot is called and we are not in the init pidns, then we reexec 
> the init process, using the same command line. I guess this one could be 
> easily retrieved if we are able to display /proc/1/cmdline ;)
>
> IMHO, this is a good proposition because it is generic and intuitive, no ?
>
> What do you thing ?

Yes, I think it makes sense. Do we have any prototype patches that
implement this behavior ?
