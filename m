From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] [1/2] Simple stats for cpu resource controller
Date: Wed, 26 Mar 2008 12:00:45 -0700
Message-ID: <6599ad830803261200w5c5749fcx6211f06d5d91c1c9@mail.gmail.com>
References: <200803262348.45219.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761970AbYCZTBP@vger.kernel.org>
In-Reply-To: <200803262348.45219.balajirrao@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: linux-kernel@vger.kernel.org, balbir@in.ibm.com, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Wed, Mar 26, 2008 at 11:18 AM, Balaji Rao <balajirrao@gmail.com> wrote:
>  +
>  +static s64 cpu_cgroup_read_stat(struct cpu_cgroup_stat *stat,
>  +               enum cpu_cgroup_stat_index idx)
>  +{
>  +       int cpu;
>  +       s64 ret = 0;
>  +       for_each_possible_cpu(cpu)
>  +               ret += stat->cpustat[cpu].count[idx];

On a 32-bit architecture I think this could race with a non-atomic
update that crosses a 32-bit boundary and get a corrupted result.

Paul
