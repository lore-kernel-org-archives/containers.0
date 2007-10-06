From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Sat, 6 Oct 2007 14:11:43 -0700
Message-ID: <6599ad830710061411l3fb9368al319a80469d54946e@mail.gmail.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	 <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	 <20071003105817.7adf6516.pj@sgi.com>
	 <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	 <20071003131632.fed4b848.pj@sgi.com>
	 <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	 <20071006012437.c0fd3a8a.pj@sgi.com>
	 <alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764690AbXJFVMF@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 10/6/07, David Rientjes <rientjes@google.com> wrote:
> The getting and putting of the tasks will prevent them from exiting or
> being deallocated prematurely.  But this is also a critical section that
> will need to be protected by some mutex so it doesn't race with other
> set_cpus_allowed().

Is that necessary? If some other process calls set_cpus_allowed()
concurrently with a cpuset cpus update, it's not clear that there's
any defined serialization semantics that have to be achieved, as long
as the end result is that the task's cpus_allowed are within the
cpuset's cpus_allowed.

Paul
