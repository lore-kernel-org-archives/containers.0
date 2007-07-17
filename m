From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 3/5] Use task_pid() to find leader's pid
Date: Tue, 17 Jul 2007 17:44:15 +0400
Message-ID: <20070717134415.GA226@tv-sign.ru>
References: <20070715121750.GA173@tv-sign.ru> <20070716195952.GG25053@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759304AbXGQNnI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070716195952.GG25053@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Cedric Le Goater <clg@fr.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Herbert Poetzel <herbert@13thfloor.at>, Pavel Emelianov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 07/16, sukadev@us.ibm.com wrote:
>
> Oleg Nesterov [oleg@tv-sign.ru] wrote:
> | 
> | Stupid question: why do we need to put the pid namespace into the struct
> | pid? Isn't it better if the user of the struct pid should know its ns?
> | For example, if /proc does put_pid(), that pid should be from the active
> | namespace.
> 
> Not sure I fully understand this. A process, and by extension its 'struct
> pid' is visible in multiple namespaces and we maintain this list of
> namespaces in each 'struct pid'.
> 
> Are you suggesting having a pid_namespace with a list of all 'struct pids'
> that are visible in it ?

I thought that the plan is: if the task is visible in some namespace, it has
a separate pid_t in that namespace.

OK, the question was relly stupid, please ignore. I'll wait for other patches
to understand what's going on.

Oleg.
