From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Sat, 21 Jun 2008 00:56:07 -0700
Message-ID: <6599ad830806210056n44c7ff37g7cd643f95aef4aa0@mail.gmail.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <6599ad830806110045n6aec52ddkfb4be91b685357fe@mail.gmail.com>
	 <20080616103035.788A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753770AbYFUH43@vger.kernel.org>
In-Reply-To: <20080616103035.788A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sun, Jun 15, 2008 at 6:32 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> honestly, I used res_counter on early version.
> but I got bad performance.

Bad performance on the charge/uncharge?

The only difference I can see is that res_counter uses
spin_lock_irqsave()/spin_unlock_irqrestore(), and you're using plain
spin_lock()/spin_unlock().

Is the overhead of a pushf/cli/popf really going to matter compared
with the overhead of forking/exiting a task?

Or approaching this from the other side, does res_counter really need
irq-safe locking, or is it just being cautious?

Paul
