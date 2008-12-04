From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [RFC][PATCH 2/5] pid: Generalize task_active_pid_ns
Date: Thu, 4 Dec 2008 13:58:50 +0100
Message-ID: <20081204125850.GC31061@wavehammer.waldi.eu.org>
References: <20081126034242.GA23120@us.ibm.com> <20081126034528.GB23238@us.ibm.com> <20081127011738.GC13545@wavehammer.waldi.eu.org> <1227820765.5108.20.camel@bahia.kalilou.org> <20081201211518.GB15004@us.ibm.com> <20081202115729.GB1132@wavehammer.waldi.eu.org> <20081203074103.GA8487@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756337AbYLDM7I@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081203074103.GA8487@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, oleg@redhat.com, ebiederm@xmission.com, containers@lists.osdl.org, roland@redhat.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Tue, Dec 02, 2008 at 11:41:03PM -0800, Sukadev Bhattiprolu wrote:
> Bastian Blank [bastian@waldi.eu.org] wrote:
> | On Mon, Dec 01, 2008 at 01:15:18PM -0800, Sukadev Bhattiprolu wrote:
> | > Greg Kurz [gkurz@fr.ibm.com] wrote:
> | > | On Thu, 2008-11-27 at 02:17 +0100, Bastian Blank wrote:
> | > | > On Tue, Nov 25, 2008 at 07:45:28PM -0800, Sukadev Bhattiprolu wrote:
> | > | > > Currently task_active_pid_ns is not safe to call after a
> | > | > > task becomes a zombie and exit_task_namespaces is called,
> | > | > > as nsproxy becomes NULL.
> | > | > Why do you need to be able to get the pid namespace from zombie
> | > | > processes?
> | > After exiting namespaces, the process notifies parent. With new changes
> | > to signals (in this patchset), the signal code may need to determine
> | > the namespace of sender (the exiting child in this case).
> | So the parent of a process with a new pid namespace will never get a
> | SIGCHLD?
> I am wondering what I said that leads to that conclusion :-) If parent
> has a handler the handler will be called as usual otherwise SIGCHLD
> will be ignored.

You said you need a way to check the namespace of a zombie process. The
only signal a zombie can issue is the SIGCHLD to the parent.

> | What I read in the kernel source (kernel/signal.c:do_notify_parent,
> | include/asm-generic/siginfo.h:CLD_EXITED) is that the exit signals
> | (SIGCHLD) are describes as sent by the kernel. 
> 
> Yes. Are you suggesting a check like
> 
> 	if (!is_si_special(info) && !SI_FROMKERNEL(info)) ?
> 		/* must be from user, safe to check ns */

If "is_si_special(info) && SI_FROMKERNEL(info)" is true, there is no
need to check anything. The double negations makes this not easier to
read.

Bastian

-- 
Klingon phaser attack from front!!!!!
100% Damage to life support!!!!
