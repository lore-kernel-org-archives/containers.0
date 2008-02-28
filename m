From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 14:06:30 -0800
Message-ID: <6599ad830802281406t38e486d8g267df1873bc754c2@mail.gmail.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	 <20080228132142.4d4b1eef.akpm@linux-foundation.org>
	 <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
	 <20080228134027.05b2aa87.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762129AbYB1WG5@vger.kernel.org>
In-Reply-To: <20080228134027.05b2aa87.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org, pj@sgi.com
List-Id: containers.vger.kernel.org

On Thu, Feb 28, 2008 at 1:40 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
>  Maybe cgroups shouldn't be putting kernel-generated files in places where
>  user-specified files appear?
>

Well, that API (mixing control files and group directories in the same
directory namespace) was inherited directly from cpusets.

It wouldn't be hard to throw that away and move all the user-created
group directories into their own subdirectory, i.e. change the
existing directory layout from something like:

/mnt/cgroup/
    tasks
    cpu.shares
    memory.limit_in_bytes
    memory.usage_in_bytes
    user_created_groupname1/
        tasks
        cpu.shares
        memory.limit_in_bytes
        memory.usage_in_bytes
    user_created_groupname2/
        tasks
        cpu.shares
        memory.limit_in_bytes
        memory.usage_in_bytes

to something like:

/mnt/cgroup/
    tasks
    cpu.shares
    memory.limit_in_bytes
    memory.usage_in_bytes
    groups/
        user_created_groupname1/
            tasks
            cpu.shares
            memory.limit_in_bytes
            memory.usage_in_bytes
            groups/
        user_created_groupname2/
            tasks
            cpu.shares
            memory.limit_in_bytes
            memory.usage_in_bytes
            groups/

That would completely solve the namespace problem, at the cost of a
little extra verbosity/inelegance for human users (I suspect
programmatic users would prefer it), and lack of compatibility with
2.6.24. I'd also need to make the existing model a mount option so
that we could keep compatibility with the cpusets filesystem API.

>  (Am still thrashing around a bit here without an overview of the overall
>  layout and naming).

Pretty much the same as cpusets, other than the additional
kernel-generated files in each directory, as provided by the resource
subsystems. So the same potential problem faced cpusets, but the fact
that new cpuset features weren't being developed quickly meant the
problem was less likely to actually bite people.

Paul
