From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Wed, 3 Oct 2007 13:58:26 -0700
Message-ID: <6599ad830710031358w515eb90do2596c0766f989783@mail.gmail.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	 <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	 <20071003105817.7adf6516.pj@sgi.com>
	 <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	 <20071003131632.fed4b848.pj@sgi.com>
	 <6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	 <20071003135232.af01a624.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758699AbXJCU6n@vger.kernel.org>
In-Reply-To: <20071003135232.af01a624.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 10/3/07, Paul Jackson <pj@sgi.com> wrote:
>
> But now (correct me if I'm wrong here) cgroups has a per-cgroup task
> list, and the above loop has cost linear in the number of tasks
> actually in the cgroup, plus (unfortunate but necessary and tolerable)
> the cost of taking a global css_set_lock, right?

Yes.

>
> And I take it the above code snipped is missing the cgroup_iter_start,
> correct?

Oops, yes.

Paul
