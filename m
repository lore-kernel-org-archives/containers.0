From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Sat, 21 Jun 2008 22:34:37 +0530
Message-ID: <485D34A5.4040000@linux.vnet.ibm.com>
References: <6599ad830806210056n44c7ff37g7cd643f95aef4aa0@mail.gmail.com> <485CC255.9010504@linux.vnet.ibm.com> <20080621180530.E82D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <6599ad830806210848q1a1538bcw79c2f3217dd49303@mail.gmail.com> <2f11576a0806211001w375d440dua42b56edce25bfda@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753278AbYFURFM@vger.kernel.org>
In-Reply-To: <2f11576a0806211001w375d440dua42b56edce25bfda@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

KOSAKI Motohiro wrote:
> Or, if you strongly want to task_limit subsystem use res_counter,
> I can be working on improve to res_counter performance instead.

I would prefer that as it would help a common cause and avoid
duplication/maintenance overhead.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
