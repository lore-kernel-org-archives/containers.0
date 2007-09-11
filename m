From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 11 Sep 2007 09:20:33 +0200
Message-ID: <46E641C1.8000808@fr.ibm.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com> <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr> <20070910172334.GB19100@linux.vnet.ibm.com> <20070910102259.dc45a481.akpm@linux-foundation.org> <20070910174649.GA16222@linux.vnet.ibm.com> <b647ffbd0709101537l9af4dc8x743b25c96e0f5235@mail.gmail.com> <6599ad830709101545s66fd338dob6932407db4e1002@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966039AbXIKHUy@vger.kernel.org>
In-Reply-To: <6599ad830709101545s66fd338dob6932407db4e1002@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>, vatsa@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 9/10/07, Dmitry Adamushko <dmitry.adamushko@gmail.com> wrote:
>> On 10/09/2007, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
>>> On Mon, Sep 10, 2007 at 10:22:59AM -0700, Andrew Morton wrote:
>>>> objection ;)  "cpuctlr" isn't memorable.  Kernel code is write-rarely,
>>>> read-often.  "cpu_controller", please.  The extra typing is worth it ;)
>>> Ok! Here's the modified patch (against 2.6.23-rc4-mm1).
>> as everyone seems to be in a quest for a better name... I think, the
>> obvious one would be just 'group_sched'.
>>
> 
> But "sched" on its own could refer to CPU scheduling, I/O scheduling,
> network scheduling, ...
> 
> And "group" is more or less implied by the fact that it's in the
> containers/control groups filesystem.

"control groups" is the name of your framework. right ?

> So "group_sched" isn't really all that informative. The name should
> definitely contain either "cpu" or "cfs".

"cfs" control group subsystem.

"cfs" looks good enough to identify the subsystem.

C. 
