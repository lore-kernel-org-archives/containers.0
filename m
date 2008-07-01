From: "Paul Menage" <menage@google.com>
Subject: Re: Attaching PID 0 to a cgroup
Date: Tue, 1 Jul 2008 12:01:27 -0700
Message-ID: <6599ad830807011201g1e6cba65w5cb6554073988d3e@mail.gmail.com>
References: <20080701094545.GD3925@linux.vnet.ibm.com>
	 <20080701094734.GE3925@linux.vnet.ibm.com>
	 <486A06B7.7020906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758144AbYGATBr@vger.kernel.org>
In-Reply-To: <486A06B7.7020906@cn.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>, containers@lists.osdl.org, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

On Tue, Jul 1, 2008 at 3:28 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> Why is it unexpected? it follows the behavior of cpuset, so this patch will
> break backward compatibility of cpuset.

Agreed. I think we want to keep this behaviour.

Paul
