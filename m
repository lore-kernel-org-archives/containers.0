From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 03/33] task containersv11 add tasks file interface
Date: Wed, 3 Oct 2007 11:15:57 -0700
Message-ID: <6599ad830710031115g3a45e996j30bd7b5e8d77a035@mail.gmail.com>
References: <20070917210307.116234000@menage.corp.google.com>
	 <20070917210426.579524000@menage.corp.google.com>
	 <20071003010923.c606c176.pj@sgi.com>
	 <6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
	 <20071003105157.254c51a4.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758707AbXJCSQV@vger.kernel.org>
In-Reply-To: <20071003105157.254c51a4.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, serue@us.ibm.com, clg@fr.ibm.com, ebiederm@xmission.com, xemul@openvz.org, rientjes@google.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 10/3/07, Paul Jackson <pj@sgi.com> wrote:
>
> So after changing the 'cpus' of a cpuset, you (something in
> user space) then has to rewrite every pid in that cpusets
> tasks file back to that same tasks file, in order to get the
> change to be applied to each of those tasks, and get them to
> start running on their new CPUs.

What happens to the new child that got forked right between userspace
reading the 'tasks' file and writing back the pids?

Paul
