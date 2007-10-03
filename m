From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Wed, 3 Oct 2007 08:51:41 -0700
Message-ID: <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758542AbXJCPv7@vger.kernel.org>
In-Reply-To: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 10/3/07, Paul Jackson <pj@sgi.com> wrote:
> From: Paul Jackson <pj@sgi.com>
>
> The code in kernel/cgroup.c attach_task() which skips the
> attachment of a task to the group it is already in has to be
> removed.  Cpusets depends on reattaching a task to its current
> cpuset, in order to trigger updating the cpus_allowed mask in the
> task struct.

Can you explain a bit more about why this is needed? (i.e. specific
scenarios where cpusets will break without this change).

What triggers the reattach in normal use? Something from userspace?

Paul
