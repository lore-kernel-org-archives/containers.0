From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] pid: Generalize task_active_pid_ns
Date: Mon, 1 Dec 2008 13:15:18 -0800
Message-ID: <20081201211518.GB15004@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034528.GB23238@us.ibm.com> <20081127011738.GC13545@wavehammer.waldi.eu.org> <1227820765.5108.20.camel@bahia.kalilou.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753626AbYLAVP7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1227820765.5108.20.camel@bahia.kalilou.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Bastian Blank <bastian@waldi.eu.org>, linux-kernel@vger.kernel.org, oleg@redhat.com, ebiederm@xmission.com, containers@lists.osdl.org, roland@redhat.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

Greg Kurz [gkurz@fr.ibm.com] wrote:
| On Thu, 2008-11-27 at 02:17 +0100, Bastian Blank wrote:
| > On Tue, Nov 25, 2008 at 07:45:28PM -0800, Sukadev Bhattiprolu wrote:
| > > Currently task_active_pid_ns is not safe to call after a
| > > task becomes a zombie and exit_task_namespaces is called,
| > > as nsproxy becomes NULL.
| > 
| > Why do you need to be able to get the pid namespace from zombie
| > processes?

After exiting namespaces, the process notifies parent. With new changes
to signals (in this patchset), the signal code may need to determine
the namespace of sender (the exiting child in this case).

| Also according to nsproxy.h this access variant is only
| > allowed for the current task, anything else needs to take a rcu lock.

and sender still is 'current' (the exiting child).

| > 
| 
| That doesn't save ->nsproxy to be NULL... as shown in the very same
| example you're talking about.
| 
| I agree with Eric and Sukadev that task_active_pid_ns() is unsafe. There
| isn't even a /* don't use with zombies */ in pid_namespace.h...

Hmm. Its not unsafe at present. It would become unsafe if the signals code
tries to determine the namespace of sender.
